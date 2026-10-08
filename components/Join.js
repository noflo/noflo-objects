import { Component } from "@noflo/noflo";

/**
 * Joins all values of the incoming object into a string with a
 * delimiter.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Join all values of a passed packet together as a string with a predefined delimiter",
    inPorts: {
      in: {
        datatype: "all",
        description: "Object to join values from",
        required: true,
      },
      delimiter: {
        datatype: "string",
        description: "Delimiter to join values",
        control: true,
        default: ",",
      },
    },
    outPorts: {
      out: {
        datatype: "string",
        description:
          "String conversion of all values joined with delimiter into one string",
        required: true,
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    // Wait for an attached delimiter connection to deliver before firing
    if (input.attached("delimiter").length > 0 && !input.hasData("delimiter")) {
      return;
    }
    const delimiter = input.hasData("delimiter")
      ? input.getData("delimiter")
      : ",";
    const data = input.getData("in");

    if (data != null && typeof data === "object") {
      const values = Object.keys(data).map((key) => data[key]);
      output.sendDone({ out: values.join(delimiter) });
      return;
    }
    output.sendDone({
      error: new Error(`${typeof data} is not a valid object to join`),
    });
  });

  return c;
}
