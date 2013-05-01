test = require "noflo-test"

object1 =
  x: 1
  y: 2

test.component("objects/Split").
  discuss("pass in an object").
    send.connect("in").
      send.data("in", object1).
    send.disconnect("in").
  discuss("keys become groups and values become their own IPs").
    receive.beginGroup("out", "x").
    receive.data("out", 1).
    receive.beginGroup("out", "y").
    receive.data("out", 2).

export module
