require "open3"
require 'open-uri'

cmd = '../ownet/build-debug/OwNetClient/OwNetClient.app/Contents/MacOS/OwNetClient'
STDERR.sync = true
Open3.popen3(
  {
    "LISTEN_PORT" => "8888",
    "CACHE_FOLDER" => "/Users/matus/Programming/88mph/cache",
    "NO_GUI" => "1"
  }, "#{cmd}") { |stdin, stdout, stderr, th|
  t = Thread.new(stderr) do
    while !stderr.eof? do
      line = stderr.readline.strip
      if line.to_s == '"READY"'
        output = `phantomjs --proxy=localhost:8888 phantomjs/content.js http://www.apple.com`
        puts output

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
