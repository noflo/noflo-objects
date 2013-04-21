test = require "noflo-test"

object1 =
  a: 1
  b: 2
object2 =
  a: 3
  c: 5
object3 =
  c: 5
  d: 6

expected1 =
  a: 3
  b: 2
  c: 5
  d: 6
expected2 =
  a: 3
  b: 2
  c: 5
expected3 =
  a: 3
  c: 5
  d: 6

test.component("objects/Extend").
  discuss("pass some objects to extend with").
    send.data("base", object1).
    send.data("base", object2).
  discuss("pass an object to extend").
    send.connect("in").
      send.data("in", object3).
    send.disconnect("in").
  discuss("a new extended object from all three objects is produced").
    receive.data("out", expected1).

  next().
  discuss("pass some objects to extend with").
    send.data("base", object1).
    send.data("base", object2).
  discuss("pass an empty object to extend").
    send.connect("in").
      send.data("in", {}).
    send.disconnect("in").
  discuss("the new object is the extended object from `object1` and `object2`, the base objects").
    receive.data("out", expected2).

  next().
  discuss("pass some objects to extend with").
    send.data("base", object1).
    send.data("base", object2).
  discuss("only extend object with a 'c' attribute that is equal in value").
    send.data("key", "c").
  discuss("pass an object to extend").
    send.connect("in").
      send.data("in", object3).
    send.disconnect("in").
  discuss("the new object is the extended object from `object2` and `object3`").
    receive.data("out", expected3).

  next().
  discuss("pass some objects to extend with").
    send.data("base", object1).
    send.data("base", object2).
  discuss("only extend object with an attribute that no object will match").
    send.data("key", "norris").
  discuss("pass an object to extend").
    send.connect("in").
      send.data("in", object3).
    send.disconnect("in").
  discuss("the new object is passed through from the incoming object").
    receive.data("out", object3).

  next().
  discuss("pass some objects to extend with").
    send.data("base", object1).
    send.data("base", object2).
  discuss("reset the bases to nothing").
    send.data("base", null).
  discuss("pass an object to extend").
    send.connect("in").
      send.data("in", object3).
    send.disconnect("in").
  discuss("the new object is passed through from the incoming object because of lack of base objects").
    receive.data("out", object3).

export module
