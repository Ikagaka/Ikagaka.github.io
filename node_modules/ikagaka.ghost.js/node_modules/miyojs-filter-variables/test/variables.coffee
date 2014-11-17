chai = require 'chai'
chai.should()
expect = chai.expect
sinon = require 'sinon'
Miyo = require 'miyojs'
MiyoFilters = require '../variables.js'
fs = require 'fs'

describe 'variables_initialize', ->
	ms = null
	request = null
	entry = null
	beforeEach ->
		ms = new Miyo()
		for name, filter of MiyoFilters
			ms.filters[name] = filter
		request = sinon.stub()
		entry =
			filters: ['variables_initialize']
			argument:
				value: 'dummy'
	it 'should return original argument', ->
		return_argument = ms.call_filters entry, null, '_load'
		return_argument.should.be.deep.equal entry.argument
	it 'should define variables and methods', ->
		ms.call_filters entry, null, '_load'
		ms.variables.should.be.instanceof Object
		ms.variables_temporary.should.be.instanceof Object
		ms.variables_save.should.be.instanceof Function
		ms.variables_load.should.be.instanceof Function
	it 'should set miyo_template_stash', ->
		ms.filters.miyo_template_stash = {}
		ms.call_filters entry, null, '_load'
		ms.variables.dummy = 'dummy'
		ms.variables_temporary.dummy = 'dummy'
		ms.filters.miyo_template_stash.should.have.property 'v'
		ms.filters.miyo_template_stash.v.should.be.instanceof Function
		ms.filters.miyo_template_stash.v.call(ms, request, 'OnTest').should.be.deep.equal ms.variables
		ms.filters.miyo_template_stash.should.have.property 'vt'
		ms.filters.miyo_template_stash.vt.should.be.instanceof Function
		ms.filters.miyo_template_stash.vt.call(ms, request, 'OnTest').should.be.deep.equal ms.variables_temporary

describe 'variables_load', ->
	ms = null
	request = null
	beforeEach ->
		ms = new Miyo()
		for name, filter of MiyoFilters
			ms.filters[name] = filter
		request = sinon.stub()
	it 'should read', ->
		entry =
			filters: ['variables_initialize']
		ms.call_filters entry, null, '_load'
		ms.variables_load('test/variables.json')
		ms.variables.should.be.deep.equal {
			var: 23
			nest:
				a: 1
				b: 1
		}
	it 'should called from filter', ->
		entry =
			filters: ['variables_initialize', 'variables_load']
			argument:
				variables_load: 'test/variables.json'
		ms.call_filters entry, null, '_load'
		ms.variables.should.be.deep.equal {
			var: 23
			nest:
				a: 1
				b: 1
		}
	it 'should throw with filter no argument', ->
		entry =
			filters: ['variables_initialize', 'variables_load']
		(-> ms.call_filters entry, null, '_load').should.throw /argument.variables_load undefined/
		entry =
			filters: ['variables_initialize', 'variables_load']
			argument: {}
		(-> ms.call_filters entry, null, '_load').should.throw /argument.variables_load undefined/

describe 'variables_save', ->
	ms = null
	request = null
	entry = null
	writeFileSync = null
	beforeEach ->
		ms = new Miyo()
		for name, filter of MiyoFilters
			ms.filters[name] = filter
		request = sinon.stub()
		writeFileSync = sinon.stub fs, 'writeFileSync'
	afterEach ->
		writeFileSync.restore()
	it 'should write', ->
		entry =
			filters: ['variables_initialize']
		ms.call_filters entry, null, '_load'
		ms.variables = {
			var: 23
			nest:
				a: 1
				b: 1
		}
		ms.variables_save('test/variables.json')
		writeFileSync.calledOnce.should.be.true
		writeFileSync.firstCall.calledWith 'test/variables.json', JSON.stringify ms.variables, 'utf8'
	it 'should called from filter', ->
		entry =
			filters: ['variables_initialize']
		ms.call_filters entry, null, '_load'
		ms.variables = {
			var: 23
			nest:
				a: 1
				b: 1
		}
		entry =
			filters: ['variables_save']
			argument:
				variables_save: 'test/variables.json'
		ms.call_filters entry, null, '_unload'
		writeFileSync.calledOnce.should.be.true
		writeFileSync.firstCall.calledWith 'test/variables.json', JSON.stringify ms.variables, 'utf8'
	it 'should throw with filter no argument', ->
		entry =
			filters: ['variables_initialize']
		ms.call_filters entry, null, '_load'
		entry =
			filters: ['variables_save']
		(-> ms.call_filters entry, null, '_unload').should.throw /argument.variables_save undefined/
		entry =
			filters: ['variables_save']
			argument: {}
		(-> ms.call_filters entry, null, '_unload').should.throw /argument.variables_save undefined/
