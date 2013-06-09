class UnprocessedCache < ActiveRecord::Base
  belongs_to :update

  ## Executed periodically, processes the first unprocessed update on the stack
  def self.process_planned_caches
    3.times do
      unprocessed_cache = UnprocessedCache.first(:order => 'created_at')
      return if unprocessed_cache.nil?
      update = unprocessed_cache.update
      unprocessed_cache.delete
      update.process_cache
    end
  end

  def self.process_cache_folder(old_folder_name)
    new_folder_name = old_folder_name + "-p"
    new_folder_path = Update.get_cache_folder_path new_folder_name
    old_folder_path = Update.get_cache_folder_path old_folder_name

    begin
      FileUtils.mkpath new_folder_path
      FileUtils.mkpath Update.get_cache_folder_path('contents')

      Dir.foreach(old_folder_path) do |file_name|
        next unless file_name.end_with? '.cache'
        old_file_path = "#{old_folder_path}/#{file_name}"
        new_file_path = "#{new_folder_path}/#{file_name}"

        File.open(old_file_path, "r") do |old_file|
          until old_file.eof? || old_file.readline == "\r\n"
          end
          headers_offset = old_file.pos

          unless old_file.eof?
            hash = Digest::MD5.hexdigest(old_file.read)
            content_file_name = "contents/#{hash}.cache"
            content_file_path = Update.get_cache_folder_path(content_file_name)
            unless File.exist? content_file_path
              File.open(content_file_path, "w") do |file|
                old_file.seek headers_offset, IO::SEEK_SET
                file.write old_file.read
              end
            end
            File.open(Update.get_cache_folder_path("#{new_folder_name}/#{file_name}"), "w") do |file|
              file.write "../../#{content_file_name}\n"
              old_file.seek 0, IO::SEEK_SET
              old_file.readline
              file.write(old_file.read(headers_offset - old_file.pos))
            end
          end
        end
      end
      FileUtils.rm_rf old_folder_path
    rescue => ex
      $stderr.puts ex.message
      FileUtils.rm_rf new_folder_path if File.exist? new_folder_path
      return old_folder_name
    end

    new_folder_name
  end
end
