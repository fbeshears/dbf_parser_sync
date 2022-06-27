
dps = require('../lib/dbf_parser_sync')


fn = 'employees'


dbf_file_name = "#{__dirname}/#{fn}.dbf"
json_file_name1   = "#{__dirname}/#{fn}1.json"
json_file_name2   = "#{__dirname}/#{fn}2.json"

debug = true

dps.makeJson(dbf_file_name, json_file_name1, debug)


try
  p = new dps.DbfParserSync(dbf_file_name)
catch e 
  console.log("Error parsing: #{dbf_file_name}")
  throw e

p.write_json(json_file_name2)