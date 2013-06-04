require 'open3'
require 'open-uri'
require 'fileutils'

class Update < ActiveRecord::Base
  belongs_to :page

  def download
    cache_folder_name = "#{page.id}/#{Time.now.to_i}"
    cache_folder_path = "#{Rails.application.config.cache_folder}#{cache_folder_name}"
    FileUtils.mkpath cache_folder_path

    STDERR.sync = true
    Open3.popen3(
      {
        "LISTEN_PORT" => "8888",
        "CACHE_FOLDER" => cache_folder_path,
        "NO_GUI" => "1",
        "DONT_USE_DB_FOR_CACHE" => "1"
      }, "#{Rails.application.config.proxy_app_path}") { |stdin, stdout, stderr, th|
      t = Thread.new(stderr) do
        while !stderr.eof? do
          line = stderr.readline.strip
          if line.to_s == '"READY"'
            parts = `phantomjs --proxy=localhost:8888 /script/phantomjs/content.js #{page.url}`.split('</we_dont_need_no_roads>')
            content = parts.first
            text = parts.last
            sleep(1)

            begin
              open('http://my.ownet/api/app/quit', { :proxy => 'http://localhost:8888/' })
            rescue
            end

            break
          end
        end
      end

      Process::waitpid(th.pid) rescue nil

      t.join
    }
  end

  def create_changed_blocks(previous_text)
    added_blocks, removed_blocks, moved_blocks = get_changed_lines previous_text
    [[added_blocks, :added], [removed_blocks, :removed], [moved_blocks, :moved]].each do |pair|
      block = ChangedBlock.new
      block.update = update
      block.text = pair.first
      block.change_type = pair.last
      block.save
    end
    text_changed = added_blocks.count > 0 || removed_blocks.count > 0
  end

  def get_changed_lines(previous_text)
    added_lines = []
    removed_lines = []
    line_indices = {}
    i = -1
    Diffy::Diff.new(previous_text, text).each do |line|
      i += 1
      line = line.chomp.strip
      case line
      when ''
        next
      when /^\+/
        line[0] = ''
        added_lines << line
        line_indices[line] = i
      when /^-/
        line[0] = ''
        removed_lines << line
        line_indices[line] = i
      end
    end
    moved_lines = added_lines & removed_lines
    added_lines = added_lines - moved_lines
    removed_lines = removed_lines - moved_lines

    added_lines.sort! {|x,y| line_indices[x] <=> line_indices[y] }
    removed_lines.sort! {|x,y| line_indices[x] <=> line_indices[y] }
    moved_lines.sort! {|x,y| line_indices[x] <=> line_indices[y] }

    added_blocks = []
    removed_blocks = []
    moved_blocks = []

    i = -2
    [[added_lines, added_blocks], [removed_lines, removed_blocks], [moved_lines, moved_blocks]].each do |pair|
      pair.first.each do |line|
        n = line_indices[line]
        if n - 1 == i
          pair.last.last << "\n#{line}"
        else
          pair.last << line
        end
        i = n
      end
    end

    return added_blocks, removed_blocks, moved_blocks
  end
end
