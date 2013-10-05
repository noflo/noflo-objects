noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  FilterPropertyValue = require '../components/FilterPropertyValue.coffee'
else
  FilterPropertyValue = require 'noflo-objects/components/FilterPropertyValue.js'

describe 'FilterPropertyValue component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = FilterPropertyValue.getComponent()
    c.inPorts.in.attach noflo.internalSocket.createSocket()
    c.outPorts.out.attach noflo.internalSocket.createSocket()
    ins = c.inPorts.in
    out = c.outPorts.out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.in).to.be.an 'object'

    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  it 'test default behavior', (done) ->
    actual = [{a:1},{b:2},{c:3}]
    expect = [{a:1},{b:2},{c:3}]

    out.on "data", (data) ->
      expected = expect.shift()
      chai.expect((Object.keys data).length).to.equal (Object.keys expected).length
      chai.expect(val).to.equal expected[prop] for prop, val of data
      done() if expect.length == 0

    ins.send a for a in actual

  it 'test accept via map', (done) ->
    acc = noflo.internalSocket.createSocket()
    c.inPorts.accept.attach acc

    acc.send { good: true }

    out.on "data", (data) ->
      chai.expect(data.good).to.equal true
      chai.expect(data.bar).to.equal 3
      chai.expect((k for k of data).length).to.equal 2
      done()

    ins.send { good: false, foo: 1 } # reject
    ins.send { baz: 2 }              # reject
    ins.send { good: true, bar: 3 }  # accept

  it 'test accept via pairs', (done) ->
    acc = noflo.internalSocket.createSocket()
    c.inPorts.accept.attach acc

    acc.send "food=true"
    acc.send "good=yes"
    acc.send "hood=1"

    expect = [["good","yes"],["hood",1],["food",true]]

    out.on "data", (data) ->
        [k,v] = expect.shift()
        chai.expect(data[k]).to.equal v
        done() if expect.length is 0

    ins.send { good: "yes" }         # accept
    ins.send { hood: 1 }             # accept
    ins.send { good: false, foo: 1 } # reject
    ins.send { baz: 2 }              # reject
    ins.send { food: true, bar: 3 }  # accept

  it 'test accept via regexp', (done) ->
    reg = noflo.internalSocket.createSocket()
    c.inPorts.regexp.attach reg

    reg.send "good=[tg]rue"

    expect = ["grue",true]

    out.on "data", (data) ->
        chai.expect(data.good).to.equal expect.shift()
        chai.expect(data.bar).to.equal 3
        chai.expect((k for k of data).length).to.equal 2
        done() if expect.length is 0

    ins.send { good: "grue", bar: 3 } # accept
    ins.send { good: false, foo: 1 }  # reject
    ins.send { baz: 2 }               # reject
    ins.send { good: true, bar: 3 }   # accept
