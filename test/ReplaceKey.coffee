test = require "noflo-test"

pattern1 =
  "a.+c": "def"

object1 =
  abc: 1
  bbc: 2

expected1 =
  def: 1
  bbc: 2

test.component("objects/ReplaceKey").
  discuss("given a regexp").
    send.connect("pattern").
      send.data("pattern", pattern1).
    send.disconnect("pattern").
  discuss("pass in an object").
    send.connect("in").
      send.data("in", object1).
    send.disconnect("in").
  discuss("key is changed based on regex").
    receive.data("out", expected1).

export module
