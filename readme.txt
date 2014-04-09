Readme Notes:

You need to have node.js installed.

To use the coffee-script version in the src directory,
you should also have CoffeeScript installed.

To use with coffee, place the dbf_parser_sync.coffee
file in a directory. Include it in your coffeescirpt code with:

dps = require('./dbf_parser_sync')


You can parse a dbf file and write the result into a json file with
the following.

dps.makeJson(dbf_file_name, json_file_name)


Alternatively, you can use the DbfParserSync pseudo-class with the
following:

p = new DbfParserSync(dbf_file_name)

obj = p.get_json()

json_str = JSON.stringify(obj)
