import { Component } from "@noflo/noflo";

/**
 * Maps property names of the incoming object, using a `map` object and
 * optionally regex replacements.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Map property names on an object",
    // currently only accepts one map and one regex per object
    inPorts: {
      map: {
        datatype: "all",
        description:
          "Map to use to map property on object (object, or 'from=to')",
      },
      regexp: {
        datatype: "string",
        description:
          "Regex to use to map property on object, in 'from=to' form",
      },
      in: {
        datatype: "object",
        description: "Object to map property on",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        required: true,
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    // Wait for attached regexp/map connections to deliver before firing
    if (input.attached("regexp").length > 0 && !input.hasData("regexp")) {
      return;
    }
    if (input.attached("map").length > 0 && !input.hasData("map")) {
      return;
    }

    const data = input.getData("in");

    /** @type {Record<string, string>} */
    const regexps = {};
    if (input.hasData("regexp")) {
      const regexp = input.getData("regexp");
      const regexPart = String(regexp).split("=");
      regexps[regexPart[0]] = regexPart[1];
    }

    /** @type {any} */
    let map = {};
    if (input.hasData("map")) {
      map = input.getData("map");
      if (typeof map !== "object") {
        const mapParts = String(map).split("=");
        map[mapParts[0]] = mapParts[1];
      }
    }

    /** @type {Record<string, any>} */
    const newData = {};
    for (const property of Object.keys(data)) {
      const value = data[property];
      let prop = property;
      if (property in map) {
        prop = map[property];
      }
      for (const expression of Object.keys(regexps)) {
        const replacement = regexps[expression];
        const regexp = new RegExp(expression);
        const matched = regexp.exec(prop);
        if (!matched) {
          continue;
        }
        prop = prop.replace(regexp, replacement);
      }

      if (prop in newData) {
        // 1.x behavior: new key collisions overwrite
      }
      newData[prop] = value;
    }
    output.sendDone({ out: newData });
  });

  return c;
}
