import { Component } from "@noflo/noflo";

/**
 * Slices an array (or array-like) between `begin` and the optional `end`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Slice an array",
    inPorts: {
      in: {
        datatype: "all",
        description: "Array to slice",
        required: true,
      },
      begin: {
        datatype: "number",
        description: "Beginning of the slicing",
        control: true,
        required: true,
      },
      end: {
        datatype: "number",
        description: "End of the slicing",
        control: true,
      },
    },
    outPorts: {
      out: {
        datatype: "array",
        description: "Result of the slice operation",
        required: true,
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "begin")) {
      return;
    }
    // Wait for an attached end connection to deliver before firing
    if (input.attached("end").length > 0 && !input.hasData("end")) {
      return;
    }
    const data = input.getData("in");
    const begin = input.getData("begin");
    if (!(data != null ? data.slice : undefined)) {
      output.done(new Error(`Data ${typeof data} cannot be sliced`));
      return;
    }
    let sliced;
    if (input.hasData("end")) {
      const end = input.getData("end");
      sliced = data.slice(begin, end);
    } else {
      sliced = data.slice(begin);
    }
    output.sendDone({ out: sliced });
  });

  return c;
}
