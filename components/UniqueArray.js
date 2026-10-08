import { Component } from "@noflo/noflo";

/**
 * Deduplicates an array. Values are stringified for uniqueness, matching
 * the 1.x behavior.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Remove duplicate members from an array",
    icon: "empire",
    inPorts: {
      in: {
        datatype: "array",
        description: "Array to get unique values from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "array",
        description: "Array containing only unique values from the input array",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");

    /** @type {Record<string, unknown>} */
    const seen = {};
    for (const member of data) {
      seen[member] = member;
    }
    output.sendDone({ out: Object.keys(seen) });
  });

  return c;
}
