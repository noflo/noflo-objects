noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-objects'

describe 'FlattenObject component', ->
  c = null
  ins = null
  map = null
  out = null

  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'objects/FlattenObject', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      map = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.map.attach map
      c.outPorts.out.attach out
      done()

  beforeEach (done) ->
    ins = noflo.internalSocket.createSocket()
    map = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.map.attach map
    c.outPorts.out.attach out
    done()
  afterEach (done) ->
    c.inPorts.in.detach ins
    c.inPorts.map.detach map
    c.outPorts.out.detach out
    done()

  describe 'when instantiated', ->
    it 'should have input ports', (done) ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      done()
    it 'should have an output port', (done) ->
      chai.expect(c.outPorts.out).to.be.an 'object'
      done()

  describe 'flatten', ->
    tree =
      root:
        branch1: ["leaf1", "leaf2"]
        branch2: ["leaf3", "leaf4"]
        branch3:
          branch4: "leaf5"

    it 'test no map', (done) ->
      c.inPorts.map.sockets = []
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

      ins.post new noflo.IP 'data', tree

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
      map.post new noflo.IP 'data', {0:"index"}
      ins.post new noflo.IP 'data', tree

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

      map.post new noflo.IP 'data', {1:"branch"}
      ins.post new noflo.IP 'data', tree

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

      map.post new noflo.IP 'data', {2:"root"}
      ins.post new noflo.IP 'data', tree

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

      map.post new noflo.IP 'data', {3:"nothere"}
      ins.post new noflo.IP 'data', tree

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

      map.post new noflo.IP 'data', {0:"index",1:"branch",2:"root"}
      ins.post new noflo.IP 'data', tree
