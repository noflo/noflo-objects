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
 * Extends an incoming object with one or more base objects, optionally
 * matched by a property.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Extend an incoming object to some predefined objects, optionally by a certain property",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to extend",
        required: true,
      },
      base: {
        datatype: "object",
        description: "Objects to extend with (one object per IP)",
        required: true,
      },
      key: {
        datatype: "string",
        description: "Property name to extend with",
        control: true,
      },
      reverse: {
        datatype: "string",
        description: '"true" to make the base objects take precedence',
        control: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: 'The object received on port "in" extended',
        required: true,
      },
    },
  });

  /**
   * @param {Record<string, unknown>} object
   * @param {Record<string, unknown>} properties
   * @param {Record<string, unknown> | null} other
   * @returns {Record<string, unknown>}
   */
  const extend = (object, properties, other = null) => {
    const extended = object;
    for (const key of Object.keys(properties)) {
      extended[key] = properties[key];
    }
    if (other != null) {
      for (const key of Object.keys(other)) {
        extended[key] = other[key];
      }
    }
    return extended;
  };

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (!input.hasStream("base")) {
      return;
    }
    // Wait for attached key/reverse connections to deliver before firing
    if (input.attached("key").length > 0 && !input.hasData("key")) {
      return;
    }
    if (input.attached("reverse").length > 0 && !input.hasData("reverse")) {
      return;
    }

    const bases = /** @type {import("@noflo/noflo").IP[]} */ (
      readStream(input, "base")
    )
      .filter(
        /** @param {import("@noflo/noflo").IP} ip */ (ip) => ip.type === "data",
      )
      .map(/** @param {import("@noflo/noflo").IP} ip */ (ip) => ip.data);
    const data = input.getData("in");

    /** @type {any} */
    let key = input.hasData("key") ? input.getData("key") : undefined;
    if (key === undefined) {
      key = null;
    }

    // Normally the passed IP object is extended into base objects (the
    // attributes of the IP object take precedence). `reverse` makes the
    // passed IP object the base (base attributes take precedence)
    const reverse = input.hasData("reverse")
      ? String(input.getData("reverse")) === "true"
      : false;

    /** @type {Record<string, any>} */
    let out = {};
    for (const base of bases) {
      // Only extend when there's no key specified, or when the specified
      // attribute matches
      if (key == null || (data[key] != null && data[key] === base[key])) {
        out = extend(out, base);
      }
    }

    if (reverse) {
      output.sendDone(/** @type {any} */ (extend({}, data, out)));
      return;
    }
    output.sendDone(/** @type {any} */ (extend(out, data)));
  });

  return c;
}
