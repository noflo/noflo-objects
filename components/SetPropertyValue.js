import { Component } from "@noflo/noflo";

/**
 * Sets a property value on the incoming object.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Set a property value on an object",
    inPorts: {
      property: {
        datatype: "string",
        description: "Property name to set value on",
        control: true,
        required: true,
      },
      value: {
        datatype: "all",
        description: "Property value to set",
        control: true,
        required: true,
      },
      in: {
        datatype: "object",
        description: "Object to set property value on",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "Object forwarded from the input",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("property", "value", "in")) {
      return;
    }
    const data = input.getData("in");
    const property = input.getData("property");
    const value = input.getData("value");
    data[property] = value;
    output.sendDone({ out: data });
  });

  return c;
}
