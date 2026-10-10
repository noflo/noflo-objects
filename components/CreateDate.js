import { Component } from "@noflo/noflo";

/**
 * Creates a new Date object from a string.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Create a new Date object from string",
    icon: "clock-o",
    inPorts: {
      in: {
        datatype: "string",
        description:
          "A string representation of a date in RFC2822/IETF/ISO8601 format",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "date",
        description: "A new Date object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const date =
      data === "now" || data === null || data === true
        ? new Date()
        : new Date(data);
    output.sendDone({ out: date });
  });

  return c;
}
