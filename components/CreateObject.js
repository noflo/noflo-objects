import { Component } from "@noflo/noflo";

/**
 * Creates an empty object on a bang.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Create an empty object",
    inPorts: {
      start: {
        datatype: "bang",
        description: "Signal to create a new object",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "A new empty object",
      },
    },
  });

  c.forwardBrackets = { start: ["out"] };

  c.process((input, output) => {
    if (!input.hasData("start")) {
      return;
    }
    input.getData("start");
    output.sendDone({ out: {} });
  });

  return c;
}
