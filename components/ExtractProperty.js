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
 * Given a key, returns only the value matching that key in the incoming
 * object. An `in` packet fires once per buffered key stream.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Given a key, return only the value matching that key in the incoming object",
    inPorts: {
      in: {
        datatype: "object",
        description: "An object to extract property from",
        required: true,
      },
      key: {
        datatype: "string",
        description: "Property names to extract (one property per IP)",
        control: true,
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description:
          "Values of the property extracted (each value sent as a separate IP)",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (!input.hasStream("key")) {
      return;
    }
    const keys = /** @type {import("@noflo/noflo").IP[]} */ (
      readStream(input, "key")
    )
      .filter(
        /** @param {import("@noflo/noflo").IP} ip */ (ip) => ip.type === "data",
      )
      .map(/** @param {import("@noflo/noflo").IP} ip */ (ip) => ip.data);
    const data = input.getData("in");
    let value = data;

    const sendAll = async () => {
      // Loop through the keys we have
      for (const key of keys) {
        value = value[key];
        // Send the extracted value
        await output.send({ out: value });
      }
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
