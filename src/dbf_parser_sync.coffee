#dbfparser_sync.coffee

fs = require 'fs'
path = require 'path'


class DbfParserSync

	constructor: (@dbf_file_name) ->

		buffer = fs.readFileSync @dbf_file_name

		@header = new Header buffer, @get_name()

		sequenceNumber = 0

		@records = []

		loc = @header.start
		while loc < (@header.start + @header.numberOfRecords * @header.recordLength) and loc < buffer.length
				record = parseRecord ++sequenceNumber, buffer.slice(loc, loc += @header.recordLength), @header
				@records.push(record)

		return null

	get_name:  ->
		fn = @dbf_file_name.toLowerCase()				# e.g. "./datadict/filemast.dbf"
		return  path.basename(fn,".dbf")		# e.g. "filemast"

	get_json: ->
		obj = 
			header: @header
			records: @records

		json = JSON.stringify obj, undefined, 2
		
		return json

	get_header: ->
		return @header

	get_records: ->
		return @records

	write_json: (json_file_name) ->
	  try
	    fs.writeFileSync json_file_name, @get_json()
	  catch e
	    console.log("Error writing: #{json_file_name}")
	    throw e






parseRecord = (sequenceNumber, buffer, header) ->
	record = {
		'@sequenceNumber': sequenceNumber
		'@deleted': (buffer.slice 0, 1)[0] isnt 32
	}

	loc = 1
	for field in header.fields
		v = parseField field, buffer.slice(loc, loc += field.length)
		record[field.name] = v if v != ''

	return record




parseField = (field, buffer) ->
	value = (buffer.toString 'utf-8').replace /^\x20+|\x20+$/g, ''

	if field.type is 'Number'

		value = if value in ['', '-99999999.99', '-99999999.990'] then '' else value

		value = value.toString()

		# leave Date and Boolean field types as string

	# to store as Date or Boolean  add:
	# else if field.type in ['Date', 'Boolean']
	#			do conversion here


	else
		value = value.toString()

	return value

#-------------------------------------------

class Header

	constructor: (buffer, @name) ->

		@type = (buffer.slice 0, 1).toString 'utf-8'
		@dateUpdated = parseDate (buffer.slice 1, 4)
		@numberOfRecords = convertBinaryToInteger (buffer.slice 4, 8)
		@start = convertBinaryToInteger (buffer.slice 8, 10)
		@recordLength = convertBinaryToInteger (buffer.slice 10, 12)

		@fields = []
		for i in [32 .. @start - 32] by 32
			f = parseFieldSubRecord buffer.slice i, i+32
			@fields.push(f) if f.name != '' and f.name != '\r'

		return null

		
parseDate = (buffer) ->
		#y2k guess - one hopes that by 2050 dbf format will not use two digits
		#  return ISO format (only first ten chars - i.e. xxxx-xx-xx )
		# note that javascript Date wants a zero based month (but not year and day!)
		two_digit_year = convertBinaryToInteger buffer.slice 0, 1
		start_year = if two_digit_year >= 50 then 1900 else 2000
		year = start_year + two_digit_year	
		month = (convertBinaryToInteger buffer.slice 1, 2) - 1
		day = convertBinaryToInteger buffer.slice 2, 3
		return  (new Date(year, month, day)).toISOString().slice(0,10)

parseFieldSubRecord = (buffer) ->
	header = {
		name: ((buffer.slice 0, 11).toString 'utf-8').replace(/[\u0000]+$/, '').toLowerCase()
		type: getFieldType((buffer.slice 11, 12).toString('utf-8'))
		displacement: convertBinaryToInteger buffer.slice 12, 16
		length: convertBinaryToInteger buffer.slice 16, 17
		decimalPlaces: convertBinaryToInteger buffer.slice 17, 18
	}

convertBinaryToInteger = (buffer) ->
		return buffer.readInt32LE 0, true

getFieldType = (dbf_type_code) ->
	switch dbf_type_code
		when "C", "M"
			ft = "String"
		when "N"
			ft = "Number"
		when "L"
			ft = "Boolean"
		when "D"
			ft = "Date"
		else
			ft = "String"
	return ft


makeJson = (dbf_file_name, json_file_name, debug=false) ->
	if debug
	  console.log("----------------------------")
	  console.log("Parsing dbf file in: #{dbf_file_name}")
	  console.log "Saving in json file: #{json_file_name}"

  try
    p = new DbfParserSync(dbf_file_name)
  catch e 
    console.log("Error parsing: #{dbf_file_name}")
    throw e


  try
    fs.writeFileSync json_file_name, p.get_json()
  catch e
    console.log("Error writing: #{json_file_name}")
    throw e

  console.log("Finished write to %s", json_file_name) if debug

  return null

module.exports = {
	DbfParserSync
	makeJson
}