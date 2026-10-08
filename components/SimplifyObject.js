import { Component } from "@noflo/noflo";

/**
 * Simplifies XML-parsed-style objects: single-member arrays collapse to
 * their member, `$data` wrappers unwrap.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Simplify an object",
    inPorts: {
      in: {
        datatype: "all",
        description: "Object to simplify",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description: "Simplified object",
      },
    },
  });

  /**
   * @param {any} data
   * @returns {any}
   */
  const simplify = (data) => {
    if (Array.isArray(data)) {
      if (data.length === 1) {
        return data[0];
      }
      return data;
    }
    if (typeof data !== "object" || data === null) {
      return data;
    }
    const keys = Object.keys(data);
    if (keys.length === 1 && keys[0] === "$data") {
      return simplify(data.$data);
    }
    /** @type {Record<string, any>} */
    const simplified = {};
    for (const key of keys) {
      simplified[key] = simplify(data[key]);
    }
    return simplified;
  };

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    output.sendDone({ out: simplify(data) });
  });

  return c;
}
