noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

expect = chai.expect unless expect


describe 'SliceArray', ->

  c = null

  loader = null

  before ->
    loader = new noflo.ComponentLoader baseDir

  beforeEach (done) ->
    @timeout 4000
    loader.load 'objects/SliceArray', (err, instance) ->
      return done err if err
      c = instance
      done()

  describe 'inPorts', ->

    it 'should include "in"', ->
      expect(c.inPorts.in).to.be.an 'object'

    it 'should include "begin"', ->
      expect(c.inPorts.begin).to.be.an 'object'

    it 'should include "end"', ->
      expect(c.inPorts.end).to.be.an 'object'


  describe 'outPorts', ->

    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

    it 'should include "error"', ->
      expect(c.outPorts.out).to.be.an 'object'
