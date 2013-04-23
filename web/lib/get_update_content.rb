require 'pg'

update_id = ARGV[0]

conn = PGconn.open 'localhost', 5432, '', '', '88mph_development', 'postgres', ''
conn.exec('SELECT * FROM updates WHERE id = $1', [update_id]) do |result|
  print result.first["content"] if result.count > 0
end
