import { Component } from "@noflo/noflo";

/**
 * getStream's declared return type is a loose union; cast it for every
 * stream read until the core types are tightened.
 * @param {{ getStream(port: string): unknown }} input
 * @param {string} port
 * @returns {import("@noflo/noflo").IP[]}
 */
const readStream = (input, port) =>
  /** @type {import("@noflo/noflo").IP[]} */ (input.getStream(port));

/**
 * Inserts a property into the incoming object. The property name is sent
 * as a group on the `property` port, the value as the data inside it.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Insert a property into incoming objects",
    inPorts: {
      in: {
        datatype: "all",
        description: "Object to insert property into",
        required: true,
      },
      property: {
        datatype: "all",
        description:
          "Property to insert (property sent as group, value sent as IP)",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "Object received as input with added properties",
      },
    },
  });

  c.forwardBrackets = {};

  c.process((input, output) => {
    if (!input.hasData("in", "property")) {
      return;
    }
    const data = input.getData("in");
    const stream = readStream(input, "property");
    let val = null;
    let key = null;
    for (const ip of stream) {
      if (ip.type === "openBracket") {
        key = ip.data;
      }
      if (ip.type === "data") {
        val = ip.data;
      }
    }
    /** @type {Record<string, any>} */
    let outputData = {};
    if (data instanceof Object) {
      outputData = data;
    }
    outputData[key] = val;
    output.sendDone({ out: outputData });
  });

  return c;
}
