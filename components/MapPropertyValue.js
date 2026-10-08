import { Component } from "@noflo/noflo";

/**
 * Maps property names and property values of the incoming object,
 * using a `map` (object or `from=to` / `prop=from=to` strings) and
 * optionally regex replacements.
 *
 * The 1.x version had broken regex handling (reassigned the map object,
 * referenced an undefined `c.regexp`); those paths are implemented
 * directly here.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Map property names and values on an object",
    // currently only supports one map and regex per object
    inPorts: {
      map: {
        datatype: "all",
        description: "Map to use to map property value on object",
      },
      regexp: {
        datatype: "string",
        description: "Regex to use to map property value on object",
      },
      in: {
        datatype: "object",
        description: "Object to map property value on",
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
    const mapAny = {};
    /** @type {Record<string, { from: string, to: string }>} */
    const map = {};
    /** @type {Record<string, { from: string, to: string }>} */
    const regexp = {};
    /** @type {Record<string, string>} */
    const regexpAny = {};

    const mapIn = input.hasData("map") ? input.getData("map") : {};
    if (typeof mapIn !== "object") {
      // 'property=from=to' form maps a value inside a specific property
      const mapParts = String(mapIn).split("=");
      if (mapParts.length === 3) {
        map[mapParts[0]] = {
          from: mapParts[1],
          to: mapParts[2],
        };
      } else {
        mapAny[mapParts[0]] = mapParts[1];
      }
    } else {
      Object.assign(mapAny, mapIn);
    }

    const regexIn = input.hasData("regexp") ? input.getData("regexp") : {};
    if (typeof regexIn !== "object") {
      const regexParts = String(regexIn).split("=");
      if (regexParts.length === 3) {
        regexp[regexParts[0]] = {
          from: regexParts[1],
          to: regexParts[2],
        };
      } else if (regexParts.length >= 2) {
        regexpAny[regexParts[0]] = regexParts[1];
      }
    }

    for (const property of Object.keys(data)) {
      const value = data[property];
      // Map whole property values
      if (map[property] && map[property].from === value) {
        data[property] = map[property].to;
      }
      if (mapAny[value] !== undefined) {
        data[property] = mapAny[value];
      }

      // Regex mapping for specific properties
      if (regexp[property]) {
        const expression = new RegExp(regexp[property].from);
        const matched = expression.exec(value);
        if (matched) {
          data[property] = value.replace(expression, regexp[property].to);
        }
      }

      // Regex mapping across all properties
      for (const expression of Object.keys(regexpAny)) {
        const replacement = regexpAny[expression];
        const regex = new RegExp(expression);
        const matched = regex.exec(value);
        if (!matched) {
          continue;
        }
        data[property] = value.replace(regex, replacement);
      }
    }

    output.sendDone({ out: data });
  });

  return c;
}
