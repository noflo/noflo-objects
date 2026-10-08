import { Component } from "@noflo/noflo";

/**
 * Creates an Error object from a string or context payload.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Create an Error object",
    icon: "bug",
    inPorts: {
      start: {
        datatype: "all",
        description: "Error message string, or a context payload object",
      },
    },
    outPorts: {
      out: {
        datatype: "object",
        description: "The created Error",
      },
    },
  });

  c.forwardBrackets = { start: ["out"] };

  c.process((input, output) => {
    if (!input.hasData("start")) {
      return;
    }
    const data = input.getData("start");
    let err;
    if (typeof data === "string") {
      err = new Error(data);
    } else {
      err = /** @type {Error & { context?: unknown }} */ (new Error("Error"));
      err.context = data;
    }
    output.sendDone({ out: err });
  });

  return c;
}
