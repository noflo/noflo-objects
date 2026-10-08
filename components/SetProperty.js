import { Component } from "@noflo/noflo";

/**
 * Sets a property on the incoming object from a `key=value` pair.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Set a property on an object",
    inPorts: {
      property: {
        datatype: "string",
        description: "Property to set, in 'key=value' form",
        control: true,
        required: true,
      },
      in: {
        datatype: "object",
        description: "Object to set property on",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "Object forwarded from input",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "property")) {
      return;
    }
    const prop = input.getData("property");
    const data = input.getData("in");

    const propParts = prop.split("=");
    data[propParts[0]] = propParts[1];

    output.sendDone({ out: data });
  });

  return c;
}
