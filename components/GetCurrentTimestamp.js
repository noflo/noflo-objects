import { Component } from "@noflo/noflo";

/**
 * Sends the current timestamp as an integer.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Send out the current timestamp",
    icon: "clock-o",
    inPorts: {
      in: {
        datatype: "bang",
        description: "Causes the current timestamp to be sent out",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "int",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    input.getData("in");
    output.sendDone({ out: Date.now() });
  });

  return c;
}
