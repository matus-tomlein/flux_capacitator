require 'open3'
require 'open-uri'
require 'pg'
require 'fileutils'

url = ARGV[0]
page_id = 0

conn = PGconn.open 'localhost', 5432, '', '', '88mph_development', 'postgres', ''
conn.exec('SELECT * FROM pages WHERE url = $1', [url]) do |result|
  if result.count > 0
    page_id = result.first["id"]
  else
    page_id = conn.exec('INSERT INTO pages (url) VALUES ($1) RETURNING id', [url]).first['id']
  end
end

update_id = conn.exec('INSERT INTO updates (page_id) VALUES ($1) RETURNING id', [page_id]).first['id']
cache_folder_path = "/Users/matus/Programming/88mph/cache/#{update_id}"
FileUtils.mkpath cache_folder_path

ownet_client_path = '../ownet/build-debug/OwNetClient/OwNetClient.app/Contents/MacOS/OwNetClient'
STDERR.sync = true
Open3.popen3(
  {
    "LISTEN_PORT" => "8888",
    "CACHE_FOLDER" => cache_folder_path,
    "NO_GUI" => "1",
    "DONT_USE_DB_FOR_CACHE" => "1"
  }, "#{ownet_client_path}") { |stdin, stdout, stderr, th|
  t = Thread.new(stderr) do
    while !stderr.eof? do
      line = stderr.readline.strip
      if line.to_s == '"READY"'
        output = `phantomjs --proxy=localhost:8888 phantomjs/content.js #{url}`
        conn.exec('UPDATE updates SET content = $1 WHERE id = $2', [output, update_id])

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
