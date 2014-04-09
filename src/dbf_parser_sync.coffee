#dbfparser_sync.coffee

fs = require 'fs'
path = require 'path'


class DbfParserSync

	constructor: (@file_name) ->

		buffer = fs.readFileSync @file_name

		@header = new Header buffer, @get_name()

		sequenceNumber = 0

		@records = []

		loc = @header.start
		while loc < (@header.start + @header.numberOfRecords * @header.recordLength) and loc < buffer.length
				record = parseRecord ++sequenceNumber, buffer.slice(loc, loc += @header.recordLength), @header
				@records.push(record)

		return null

	get_name:  ->
		fn = @file_name.toLowerCase()				# e.g. "./datadict/filemast.dbf"
		return  path.basename(fn,".dbf")		# e.g. "filemast"

	get_json: ->
		json = 
			header: @header
			records: @records
		
		return json

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


	#else if field.type in ['Date', 'Boolean']
		# leave as string here
		# 
		# But, in sip_record_table method convert_to_type
		# convert date strings to ISO format 
		# and boolean strings to Boolean
		value = value.toString()


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

module.exports.DbfParserSync = DbfParserSync