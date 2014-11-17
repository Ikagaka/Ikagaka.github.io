### (C) 2014 Narazaka : Licensed under The MIT License - http://narazaka.net/license/MIT?2014 ###

unless MiyoFilters?
	MiyoFilters = {}

MiyoFilters.variables_initialize = type: 'through', filter: (argument, request, id, stash) ->
	@variables = {}
	@variables_temporary = {}
	@variables_load = (file) =>
		fs = require 'fs'
		path = require 'path'
		file_path = path.join process.cwd(), file
		try
			json_str = fs.readFileSync file_path, 'utf8'
			@variables = JSON.parse json_str
		catch
			return
	@variables_save = (file) =>
		fs = require 'fs'
		path = require 'path'
		file_path = path.join process.cwd(), file
		json_str = JSON.stringify @variables
		fs.writeFileSync file_path, json_str, 'utf8'
	if @filters.miyo_template_stash?
		@filters.miyo_template_stash.v = (value, request, id) -> @variables
		@filters.miyo_template_stash.vt = (value, request, id) -> @variables_temporary
	argument

MiyoFilters.variables_load = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_load?
		throw 'argument.variables_load undefined'
	@variables_load argument.variables_load
	argument

MiyoFilters.variables_save = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_save?
		throw 'argument.variables_save undefined'
	@variables_save argument.variables_save
	argument

MiyoFilters.variables_set = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_set?
		throw 'argument.variables_set undefined'
	for name of argument.variables_set
		pname = name.replace /\.[^.]+$/
		@variables[name] = @property argument.variables_set, pname, request, id, stash
	argument

MiyoFilters.variables_delete = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_delete?
		throw 'argument.variables_delete undefined'
	for name in argument.variables_delete
		delete @variables[name]
	argument

MiyoFilters.variables_temporary_set = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_temporary_set?
		throw 'argument.variables_temporary_set undefined'
	for name, value of argument.variables_temporary_set
		pname = name.replace /\.[^.]+$/
		@variables_temporary[name] = @property argument.variables_temporary_set, pname, request, id, stash
	argument

MiyoFilters.variables_temporary_delete = type: 'through', filter: (argument, request, id, stash) ->
	unless argument?.variables_temporary_delete?
		throw 'argument.variables_temporary_delete undefined'
	for name in argument.variables_temporary_delete
		delete @variables_temporary[name]
	argument

if module? and module.exports?
	module.exports = MiyoFilters
