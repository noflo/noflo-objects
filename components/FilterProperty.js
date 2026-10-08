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
 * Filters properties of incoming objects by matching regexps against
 * the keys, optionally recursing into nested objects.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Filter out some properties by matching RegExps against the keys of incoming objects",
    icon: "filter",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to filter properties from",
        required: true,
      },
      key: {
        datatype: "string",
        description: "Keys to filter (one key per IP)",
        required: true,
      },
      recurse: {
        datatype: "string",
        description: '"true" to recurse into the object\'s values',
        control: true,
        default: "false",
      },
      keep: {
        datatype: "string",
        description:
          '"true" if matching properties must be kept, otherwise removed',
        control: true,
        default: "false",
      },
      // Legacy mode
      accept: {
        datatype: "all",
      },
      regexp: {
        datatype: "all",
      },
    },
    outPorts: {
      out: {
        datatype: "object",
      },
    },
  });

  /** @type {Map<string | typeof undefined, RegExp[]>} */
  const keysByScope = new Map();

  /**
   * @param {Record<string, any>} object
   * @param {RegExp[]} keys
   * @param {boolean} recurse
   * @param {boolean} keep
   */
  const filterObject = (object, keys, recurse, keep) => {
    for (const key of Object.keys(object)) {
      const value = object[key];
      let isMatched = false;

      // the keys are filters we want to match in the object
      for (const filter of keys) {
        const match = key.match(filter);
        // if they match, we delete them
        const matchButDontKeep = !keep && match;
        const keepButDontMatch = keep && !match;
        if (matchButDontKeep || keepButDontMatch) {
          delete object[key];
          isMatched = true;
        }
      }

      if (!isMatched && recurse && typeof value === "object") {
        filterObject(value, keys, recurse, keep);
      }
    }
  };

  c.process((input, output) => {
    if (input.hasStream("key")) {
      keysByScope.set(
        input.scope,
        readStream(input, "key")
          .filter((ip) => ip.type === "data" && ip.data != null)
          .map((ip) => new RegExp(ip.data, "g")),
      );
      output.done();
      return;
    }
    const keys = keysByScope.get(input.scope) ?? [];
    if (!input.hasData("in") || keys.length <= 0) {
      return;
    }
    // Wait for attached recurse/keep connections to deliver before firing
    if (input.attached("recurse").length > 0 && !input.hasData("recurse")) {
      return;
    }
    if (input.attached("keep").length > 0 && !input.hasData("keep")) {
      return;
    }

    let accepts = null;
    let regexp = null;
    let legacy = false;
    if (input.has("accept") || input.has("regexp")) {
      legacy = true;
      accepts = /** @type {import("@noflo/noflo").IP} */ (input.get("accept"))
        .data;
      regexp = /** @type {import("@noflo/noflo").IP} */ (input.get("regexp"))
        .data;
    }

    const data = input.getData("in");
    const recurse = input.hasData("recurse") ? input.getData("recurse") : false;
    let keep = input.hasData("keep") ? input.getData("keep") : false;
    if (keep != null && typeof keep === "object") {
      keep = keep.pop();
    }
    const recurseFlag = recurse === true || recurse === "true";
    const keepFlag = keep === true || keep === "true";

    if (!legacy) {
      if (typeof data === "object" && data !== null) {
        let copy;
        try {
          copy = structuredClone(data);
        } catch (err) {
          if (err instanceof Error && err.name === "DataCloneError") {
            copy = data;
          } else {
            throw err;
          }
        }
        filterObject(copy, keys, recurseFlag, keepFlag);
        output.sendDone(copy);
        return;
      }
      output.done();
      return;
    }
    // Legacy mode
    /** @type {Record<string, unknown>} */
    const newData = {};
    let match = false;
    for (const property of Object.keys(data)) {
      const value = data[property];
      if (accepts.indexOf(property) !== -1) {
        newData[property] = value;
        match = true;
        continue;
      }
      for (const expression of regexp) {
        const regex = new RegExp(expression);
        if (regex.exec(property)) {
          newData[property] = value;
          match = true;
        }
      }
    }
    if (!match) {
      output.done();
      return;
    }
    output.sendDone(newData);
  });

  return c;
}
