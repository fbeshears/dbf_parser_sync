Readme Notes:

You need to have node.js installed, which will also install the node package manager - npm.

To use the coffee-script version of dbf_parser_sync,
you should also have CoffeeScript installed globally.

To do so, use: 
npm install coffee-script -g

Note: Since this is a synchronous dbf file parser,
it is intened for use in command line shell scripts.

Someday I may get around to writing an asychronous
version that can be used on the serer side of a
web app.


------------------------------
0. dbf_parser_sync leaves Date and Boolean fields as strings

A date such as March 5th 1977 would be represented as a string with the value:
"19770305"

A true boolean value will be "1" while a false boolean value will be "0"

-----------------------------
1. Using dbf_parser_sync

To use with CoffeeScript, place the dbf_parser_sync.coffee file in the src directory
in a directory with your code. Include it in your coffeescirpt code with:

dps = require './dbf_parser_sync'

To use with JavaScript, place the dbf_parser_sync.js file in the lib directory
in a directory with your code. Include it in your JavaScript code with:

var dps = require('./dbf_parser_sync');

----------------------------
2. Parse and write

You can parse a dbf file and write the result into a json file with
the following.

dps.makeJson(dbf_file_name, json_file_name)


Note: 
  The dbf_file_name should have a ".dbf" extension.
  The json_file_name should have a ".json" extension.


-------------------------
3. Get json string

Alternatively, you can use the DbfParserSync pseudo-class with the following:

p = new dps.DbfParserSync(dbf_file_name)

# And this will return a stringified object that can be written to a json file
json_str = p.get_json()       


-----------------------
4. Write from parse object
Or, you can use:

p = new dps.DbfParserSync(dbf_file_name)

p.write_json(json_file_name)


-----------------------------------
5. Access the header object and records array

Finally, you can access two objects: one for the dbf file's header, the other
for the dbf file's records. Use the following:

p = new dps.DbfParserSync(dbf_file_name)

header = p.get_header()           # will return an object that defines each record's fields

records = p.get_records()         # will return an array of objects, one for each record

