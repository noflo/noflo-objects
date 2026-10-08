import { Component } from "@noflo/noflo";

/**
 * Gets the size of an object (number of keys) or array/string length,
 * sent out as a number.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "gets the size of an object and sends that out as a number",
    inPorts: {
      in: {
        datatype: "all",
        description: "Object to measure the size of",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "int",
        description: "Size of the input object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const size =
      typeof data === "object" && data !== null
        ? Object.keys(data).length
        : data.length;
    output.sendDone({ out: size });
  });

  return c;
}
