require 'open3'
require 'open-uri'
require 'fileutils'

class Update < ActiveRecord::Base
  belongs_to :page

  def download(port = 8081, cache_only = false)
    self.cache_folder_name = "#{page.id}/#{Time.now.to_i}" if self.cache_folder_name.nil?
    cache_folder_path = Update.get_cache_folder_path self.cache_folder_name
    FileUtils.mkpath cache_folder_path

    STDERR.sync = true
    args = {
      "LISTEN_PORT" => port.to_s,
      "CACHE_FOLDER" => cache_folder_path,
      "NO_GUI" => "1",
      "DONT_USE_DB_FOR_CACHE" => "1"
    }
    args["CACHE_ONLY"] = "1" if cache_only
    Open3.popen3(args, "#{Rails.application.config.proxy_app_path}") do |stdin, stdout, stderr, th|
      while !stderr.eof? do
        line = stderr.readline.strip
        if line.to_s == '"READY"'
          Thread.new do
            parts = `#{Rails.application.config.phantomjs_path} --proxy=localhost:#{port} /script/phantomjs/content.js #{page.url}`.split('<we_dont_need_roads>')
            if parts.count > 1
              parts = parts[1].split('</we_dont_need_roads>')
              self.content = parts.first
              self.text = parts.last
              sleep(1)
            end

            begin
              open('http://my.ownet/api/app/quit', { :proxy => "http://localhost:#{port}/" })
            rescue
            end
          end

          break
        end
      end

      while !stderr.eof? do
        stderr.readline.strip
      end
    end
  end

  def create_changed_blocks(previous_text)
    added_blocks, removed_blocks, moved_blocks = get_changed_lines previous_text
    [[added_blocks, :added], [removed_blocks, :removed], [moved_blocks, :moved]].each do |pair|
      pair.first.each do |text|
        block = ChangedBlock.new
        block.update = self
        block.text = text
        block.change_type = pair.last
        block.save
      end
    end
    self.text_changed = added_blocks.count > 0 || removed_blocks.count > 0
  end

  def get_changed_lines(previous_text)
    added_lines = []
    removed_lines = []
    line_indices = {}
    i = -1
    Diffy::Diff.new(previous_text, self.text).each do |line|
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
        next if line.strip == ''
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

  def process_cache
    self.cache_folder_name = UnprocessedCache.process_cache_folder self.cache_folder_name
    self.save
  end

  def self.get_cache_folder_path(folder_name)
    "#{Rails.application.config.cache_folder}#{folder_name}"
  end
end
