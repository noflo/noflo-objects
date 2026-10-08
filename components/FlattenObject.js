import { Component, IP } from "@noflo/noflo";

/**
 * Flattens a nested object into an array of entries, optionally renaming
 * the flattened key positions via a `map` (index-based, e.g.
 * `{"0": "name"}`).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Flatten a nested object into a flat array",
    inPorts: {
      map: {
        datatype: "all",
        description: "Map to use to rename flattened key positions",
        control: true,
      },
      in: {
        datatype: "object",
        description: "Object to flatten",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "array",
      },
    },
  });

  c.forwardBrackets = {};

  /**
   * @param {{ flattenedKeys: string[], value: unknown }} entry
   * @param {Record<string, string>} maps
   * @returns {Record<string, unknown>}
   */
  const mapKeys = (entry, maps) => {
    const o = /** @type {any} */ (entry);
    for (const key of Object.keys(maps)) {
      o[maps[key]] = entry.flattenedKeys[Number(key)];
    }
    delete o.flattenedKeys;
    return o;
  };

  /**
   * @param {Record<string, any>} object
   * @returns {Array<{ flattenedKeys: string[], value: unknown }>}
   */
  const flattenObject = (object) => {
    const flattened = [];
    for (const key of Object.keys(object)) {
      const value = object[key];
      if (typeof value === "object") {
        for (const entry of flattenObject(value)) {
          entry.flattenedKeys.push(key);
          flattened.push(entry);
        }
        continue;
      }
      flattened.push({
        flattenedKeys: [key],
        value,
      });
    }
    return flattened;
  };

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    // Wait for an attached map connection to deliver before firing
    if (input.attached("map").length > 0 && !input.hasData("map")) {
      return;
    }
    /** @type {Record<string, string>} */
    let maps = {};
    if (input.hasData("map")) {
      const map = input.getData("map");
      if (map != null) {
        if (typeof map === "object") {
          maps = map;
        } else {
          const mapParts = String(map).split("=");
          maps[mapParts[0]] = mapParts[1];
        }
      }
    }

    const data = input.getData("in");
    const sendAll = async () => {
      await output.send(new IP("openBracket"));
      for (const entry of flattenObject(data)) {
        await output.send({ out: mapKeys(entry, maps) });
      }
      await output.send(new IP("closeBracket"));
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
