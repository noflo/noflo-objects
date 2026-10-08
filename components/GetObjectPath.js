import { Component } from "@noflo/noflo";
import jsonpath from "jsonpath";

/**
 * Queries an object with a JSONPath expression, sending either the
 * first matching value or all matches as an array.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Query an object with a JSONPath expression",
    icon: "indent",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to query",
        required: true,
      },
      path: {
        datatype: "string",
        description: "JSONPath expression",
        control: true,
        required: true,
      },
      multiple: {
        datatype: "boolean",
        description: "Whether to send all matching values as an array",
        control: true,
        default: false,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description: "Result of the JSONPath query",
      },
      object: {
        datatype: "all",
        description: "The original input object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "path")) {
      return;
    }
    // Wait for an attached multiple connection to deliver before firing
    if (input.attached("multiple").length > 0 && !input.hasData("multiple")) {
      return;
    }
    const multiple = input.hasData("multiple")
      ? input.getData("multiple")
      : false;
    const [data, path] = input.getData("in", "path");
    const method = multiple ? "query" : "value";
    let result;
    try {
      result = jsonpath[method](data, path);
    } catch (err) {
      output.done(err instanceof Error ? err : new Error(String(err)));
      return;
    }
    output.sendDone({
      out: result,
      object: data,
    });
  });

  return c;
}
