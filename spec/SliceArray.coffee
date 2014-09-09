noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  SliceArray = require '../components/SliceArray.coffee'
else
  SliceArray = require 'noflo-objects/components/SliceArray.js'

expect = chai.expect unless expect


describe 'SliceArray', ->

  c = null

  beforeEach ->
    c = SliceArray.getComponent()

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
