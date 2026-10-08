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
 * Filters properties of incoming objects by accepted values and/or
 * regexp patterns. Objects with no matched properties go to `missed`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Filter out some values",
    icon: "filter",
    inPorts: {
      accept: {
        datatype: "all",
        description:
          "Property value to accept, can be more than one per object",
      },
      regexp: {
        datatype: "string",
        description: "Regexp properties to accept, in 'property=pattern' form",
      },
      in: {
        datatype: "object",
        description: "Object to filter properties from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "Object including the filtered properties",
      },
      missed: {
        datatype: "object",
        description: "Object received as input if no key have been matched",
      },
    },
  });

  c.forwardBrackets = {};

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    if (input.attached("accept").length > 0 && !input.hasStream("accept")) {
      return;
    }
    if (input.attached("regexp").length > 0 && !input.hasData("regexp")) {
      return;
    }

    const stream = readStream(input, "in")
      .filter((ip) => ip.type === "data")
      .map((ip) => ip.data);

    /** @type {Record<string, unknown>} */
    let accepts = {};
    if (input.has("accept")) {
      const acceptData = readStream(input, "accept")
        .filter((ip) => ip.type === "data")
        .map((ip) => ip.data);
      for (const accept of acceptData) {
        if (typeof accept === "object") {
          accepts = accept;
          break;
        }
        const mapParts = String(accept).split("=");
        try {
          accepts[mapParts[0]] = Function(`return ${mapParts[1]}`)();
        } catch (err) {
          if (err instanceof ReferenceError) {
            accepts[mapParts[0]] = mapParts[1];
          } else {
            output.done(err instanceof Error ? err : new Error(String(err)));
            return;
          }
        }
      }
    }

    /** @type {Record<string, string>} */
    const regexps = {};
    if (input.has("regexp")) {
      const regexpData = readStream(input, "regexp")
        .filter((ip) => ip.type === "data")
        .map((ip) => ip.data);
      if (regexpData.length > 0) {
        const mapParts = String(regexpData[0]).split("=");
        regexps[mapParts[0]] = mapParts[1];
      }
    }

    const sendAll = async () => {
      for (const data of stream) {
        if (
          Object.keys(accepts).length > 0 ||
          Object.keys(regexps).length > 0
        ) {
          /** @type {Record<string, unknown>} */
          const newData = {};
          let match = false;
          for (const property of Object.keys(data)) {
            const value = data[property];
            if (accepts[property]) {
              if (accepts[property] !== value) {
                continue;
              }
              match = true;
            }
            if (regexps[property]) {
              const regexp = new RegExp(regexps[property]);
              if (!regexp.exec(value)) {
                continue;
              }
              match = true;
            }
            newData[property] = value;
          }
          if (!match) {
            await output.send({ missed: data });
          } else {
            await output.send({ out: newData });
          }
        } else {
          await output.send({ out: data });
        }
      }
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
