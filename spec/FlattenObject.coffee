noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  FlattenObject = require '../components/FlattenObject.coffee'
else
  FlattenObject = require 'noflo-objects/components/FlattenObject.js'

describe 'FlattenObject component', ->
  c = null
  ins = null
  map = null
  out = null

  beforeEach ->
    c = FlattenObject.getComponent()
    ins = noflo.internalSocket.createSocket()
    map = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.map.attach map
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.in).to.be.an 'object'

    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'flatten', ->
    tree =
      root:
        branch1: ["leaf1", "leaf2"]
        branch2: ["leaf3", "leaf4"]
        branch3:
          branch4: "leaf5"

    it 'test no map', (done) ->
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
            {value:"leaf1"}
            {value:"leaf2"}
            {value:"leaf3"}
            {value:"leaf4"}
            {value:"leaf5"}
        ]
        done()

      ins.send tree
      ins.disconnect()

    it 'test map depth 0', (done) ->
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
          {value:"leaf1",index:"0"}
          {value:"leaf2",index:"1"}
          {value:"leaf3",index:"0"}
          {value:"leaf4",index:"1"}
          {value:"leaf5",index:"branch4"}
        ]
        done()

      map.send {0:"index"}
      map.disconnect()
      ins.send tree
      ins.disconnect()

    it 'test map depth 1', (done) ->
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
          {value:"leaf1",branch:"branch1"}
          {value:"leaf2",branch:"branch1"}
          {value:"leaf3",branch:"branch2"}
          {value:"leaf4",branch:"branch2"}
          {value:"leaf5",branch:"branch3"}
        ]
        done()

      map.send {1:"branch"}
      map.disconnect()
      ins.send tree
      ins.disconnect()

    it 'test map depth 2', (done) ->
      output = []

      out.on "data", (data) ->
        output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
          {value:"leaf1",root:"root"}
          {value:"leaf2",root:"root"}
          {value:"leaf3",root:"root"}
          {value:"leaf4",root:"root"}
          {value:"leaf5",root:"root"}
        ]
        done()

      map.send {2:"root"}
      map.disconnect()
      ins.send tree
      ins.disconnect()

    it 'test map depth 3', (done) ->
      output = []

      out.on "data", (data) ->
          output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
          {value:"leaf1",nothere:undefined}
          {value:"leaf2",nothere:undefined}
          {value:"leaf3",nothere:undefined}
          {value:"leaf4",nothere:undefined}
          {value:"leaf5",nothere:undefined}
        ]
        done()

      map.send {3:"nothere"}
      map.disconnect()
      ins.send tree
      ins.disconnect()

    it 'test map all', (done) ->
      output = []

      out.on "data", (data) ->
          output.push data

      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [
          {value:"leaf1",index:"0",branch:"branch1",root:"root"}
          {value:"leaf2",index:"1",branch:"branch1",root:"root"}
          {value:"leaf3",index:"0",branch:"branch2",root:"root"}
          {value:"leaf4",index:"1",branch:"branch2",root:"root"}
          {value:"leaf5",index:"branch4",branch:"branch3",root:"root"}
        ]
        done()

      map.send {0:"index",1:"branch",2:"root"}
      map.disconnect()
      ins.send tree
      ins.disconnect()
