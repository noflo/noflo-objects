test = require "noflo-test"

input1 =
  a: 3
  getA: () ->
    return @a

expected1 = 3


inc = (forA, forB) ->
  @a += forA
  @b += forB
  return @

args = [1, 5]

input2 =
  a: 1
  b: 10
  inc: inc

expected2 =
  a: 2
  b: 15
  inc: inc

test.component("objects/CallMethod").
  discuss("set method to call").
    send.connect("method").
    send.data("method", "getA").
    send.disconnect("method").
  discuss("then give it object").
    send.connect("in").
    send.data("in", input1).
    send.disconnect("in").
  discuss("get returned value of method").
    receive.data("out", 3).

  next().
  discuss("set method to call").
    send.connect("method").
    send.data("method", "inc").
    send.disconnect("method").
  discuss("then set arguments for method").
    send.connect("arguments").
    send.data("arguments", args).
    send.disconnect("arguments").
  discuss("then give it object").
    send.connect("in").
    send.data("in", input2).
    send.disconnect("in").
  discuss("get the modified object").
    receive.data("out", expected2).

export module
