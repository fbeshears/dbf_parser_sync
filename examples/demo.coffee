#demo.coffee

fs = require('fs')

DbfParserSync = require('../lib/dbf_parser_sync').DbfParserSync

makeJson = (path_from, path_to) ->
  console.log("----------------------------")
  console.log("Parsing dbf file in: #{path_from}")
  console.log "Saving in json file: #{path_to}"
  try
    p = new DbfParserSync(path_from)
  catch e 
    console.log("Error parsing: #{path_from}")
    console.log(e)
    return null

  try
    fs.writeFileSync path_to, JSON.stringify(p.get_json(), undefined, 2)
  catch e
    console.log("Error writing: #{path_to}")
    console.log(e)
    return null
  
  console.log "Finished write to %s", path_to

  return null

fn = 'employees'


path_from = "#{fn}.dbf"
path_to = "#{fn}.json"



makeJson(path_from, path_to)