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
 * Removes properties from a cloned copy of the incoming object, so the
 * original is not modified. Non-clonable objects are forwarded as-is.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Remove properties from an object",
    icon: "ban",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to remove properties from",
        required: true,
      },
      property: {
        datatype: "string",
        description: "Properties to remove (one per IP)",
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

  /**
   * Legacy shallow-clonability marker from 1.x: IPs marked clonable get
   * a deep copy, everything else is forwarded as-is.
   * @param {any} obj
   * @returns {any}
   */
  const clone = (obj) => {
    if (obj === null || typeof obj !== "object") {
      return obj;
    }
    const temp = new obj.constructor();
    for (const key of Object.keys(obj)) {
      temp[key] = clone(obj[key]);
    }
    return temp;
  };

  c.process((input, output) => {
    if (!input.hasData("in", "property")) {
      return;
    }
    const ip = /** @type {import("@noflo/noflo").IP} */ (input.get("in"));
    const { data } = ip;
    const propData = readStream(input, "property")
      .filter((streamIp) => streamIp.type === "data")
      .map((streamIp) => streamIp.data);

    // Clone the object so that the original isn't changed
    let object;
    if (ip.clonable) {
      object = clone(data);
    } else {
      object = data;
    }

    for (const property of propData) {
      delete object[property];
    }

    output.sendDone({ out: object });
  });

  return c;
}
