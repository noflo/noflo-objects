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
 * Merges all incoming objects in the stream into one, concatenating
 * arrays and merging nested objects.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "merges all incoming objects into one",
    inPorts: {
      in: {
        datatype: "object",
        description: "Objects to merge (one per IP)",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "A new object containing the merge of input objects",
      },
    },
  });

  c.forwardBrackets = {};

  /**
   * @param {Record<string, any>} origin
   * @param {Record<string, any>} object
   * @returns {Record<string, any>}
   */
  const merge = (origin, object) => {
    const orig = origin;
    for (const key of Object.keys(object)) {
      const value = object[key];
      const oValue = origin[key];

      // If the property already exists, merge depending on its type
      if (oValue != null) {
        if (Array.isArray(oValue)) {
          orig[key].push(...value);
        } else if (typeof oValue === "object") {
          orig[key] = merge(oValue, value);
        } else {
          orig[key] = value;
        }
      } else {
        orig[key] = value;
      }
    }
    return orig;
  };

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const inData = readStream(input, "in")
      .filter((ip) => ip.type === "data")
      .map((ip) => ip.data);
    output.sendDone(inData.reduce(merge, {}));
  });

  return c;
}
