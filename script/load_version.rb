require 'open3'
require 'open-uri'
require 'pg'
require 'fileutils'

update_id = ARGV[0]

cache_folder_path = "/Users/matus/Programming/88mph/cache/#{update_id}"
exit unless File.exists? cache_folder_path

ownet_client_path = '../ownet/build-debug/OwNetClient/OwNetClient.app/Contents/MacOS/OwNetClient'
STDERR.sync = true
Open3.popen3(
  {
    "LISTEN_PORT" => "8888",
    "CACHE_FOLDER" => cache_folder_path,
    "NO_GUI" => "1",
    "DONT_USE_DB_FOR_CACHE" => "1",
    "DONT_WRITE_TO_CACHE" => "1"
  }, "#{ownet_client_path}") { |stdin, stdout, stderr, th|
  Process::waitpid(th.pid) rescue nil
}
