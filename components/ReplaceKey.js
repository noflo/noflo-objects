import { Component } from "@noflo/noflo";

/**
 * Replaces keys of the incoming object matching a regexp pattern with
 * the provided replacement string.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "given a regexp matching any key of an incoming object as a data IP, replace the key with the provided string",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to replace a key from",
        required: true,
      },
      pattern: {
        datatype: "object",
        description: "Map of regexp pattern to replacement string",
        control: true,
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "Object forwarded from input",
      },
      error: {
        datatype: "object",
        description: "Invalid regular expression errors",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "pattern")) {
      return;
    }
    const data = input.getData("in");
    const patterns = input.getData("pattern");

    for (const key of Object.keys(data)) {
      const value = data[key];
      for (const pattern of Object.keys(patterns)) {
        const replace = patterns[pattern];
        let regexp;
        try {
          regexp = new RegExp(pattern);
        } catch (err) {
          output.done(err instanceof Error ? err : new Error(String(err)));
          return;
        }
        if (key.match(regexp) != null) {
          const newKey = key.replace(regexp, replace);
          data[newKey] = value;
          delete data[key];
        }
      }
    }

    output.sendDone({ out: data });
  });

  return c;
}
