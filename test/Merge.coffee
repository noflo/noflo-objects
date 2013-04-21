test = require "noflo-test"

object1 =
  x: 1
  y: [2, 3, 4]
  z:
    p: 5
    q: 6

object2 =
  x: 7
  y: [8, 9]
  z:
    p: 10
    r: 11

expected1 =
  x: 7
  y: [2, 3, 4, 8, 9]
  z:
    p: 10
    q: 6
    r: 11

test.component("objects/Merge").
  discuss("merges all objects in separate IPs").
    send.data("in", object1).
    send.data("in", object2).
    send.disconnect("in").
  discuss("into single object on disconnect").
    receive.data("out", expected1).
    receive.disconnect("out").

export module
