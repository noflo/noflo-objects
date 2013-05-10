test = require "noflo-test"

test.component("objects/InsertProperty").
  discuss("set some properties to insert").
    send.connect("property").
    send.beginGroup("property", "key").
    send.data("property", "value").
    send.endGroup("property", "group").
    send.disconnect("property").
  discuss("give it some objects").
    send.connect("in").
    send.data("in", { a: 1, b: 2 }).
    send.disconnect("in").
  discuss("get the inserted object").
    receive.data("out", { a: 1, b: 2, key: "value" }).

export module
