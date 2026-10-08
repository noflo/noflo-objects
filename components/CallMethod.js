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
 * Calls a method on an object.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "call a method on an object",
    icon: "gear",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object on which a method will be called",
        required: true,
      },
      method: {
        datatype: "string",
        description: "Name of the method to call",
        control: true,
        required: true,
      },
      arguments: {
        datatype: "all",
        description: "Arguments given to the method (one argument per IP)",
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description: "Value returned by the method call",
        required: true,
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("method", "in")) {
      return;
    }
    // Wait for an attached arguments connection to deliver before firing
    if (
      input.attached("arguments").length > 0 &&
      !input.hasStream("arguments")
    ) {
      return;
    }
    const args = input.hasStream("arguments")
      ? /** @type {import("@noflo/noflo").IP[]} */ (
          readStream(input, "arguments")
        )
          .filter(
            /** @param {import("@noflo/noflo").IP} ip */ (ip) =>
              ip.type === "data" && ip.data != null,
          )
          .map(/** @param {import("@noflo/noflo").IP} ip */ (ip) => ip.data)
      : [];
    const data = input.getData("in");
    const method = input.getData("method");

    if (!data[method]) {
      output.sendDone(new Error(`Method '${method}' not available`));
      return;
    }

    output.sendDone({
      out: data[method].apply(data, args),
    });
  });

  return c;
}
