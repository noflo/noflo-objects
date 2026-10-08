import { Component } from "@noflo/noflo";
import jsonpath from "jsonpath";

/**
 * Compares an object value extracted with a JSONPath expression.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Compare an object value extracted with a JSONPath expression",
    icon: "check",
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
      comparison: {
        datatype: "all",
        description: "Value to compare against",
        control: true,
        required: true,
      },
      operator: {
        datatype: "string",
        description: "Comparison operator",
        control: true,
        default: "==",
      },
    },
    outPorts: {
      pass: {
        datatype: "object",
        description: "Object that passed the comparison",
      },
      fail: {
        datatype: "object",
        description: "Object that failed the comparison",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "path", "comparison")) {
      return;
    }
    // Wait for an attached operator connection to deliver before firing
    if (input.attached("operator").length > 0 && !input.hasData("operator")) {
      return;
    }
    const operator = input.hasData("operator")
      ? input.getData("operator")
      : "==";
    const [data, path, comparison] = input.getData("in", "path", "comparison");
    let result;
    try {
      result = jsonpath.value(data, path);
    } catch (err) {
      output.done(err instanceof Error ? err : new Error(String(err)));
      return;
    }

    let passed = false;
    switch (operator) {
      case "==":
        // biome-ignore lint/suspicious/noDoubleEquals: loose equality is the component contract
        passed = result == comparison;
        break;
      case "!=":
        // biome-ignore lint/suspicious/noDoubleEquals: loose equality is the component contract
        passed = result != comparison;
        break;
      case ">":
        passed = result > comparison;
        break;
      case "<":
        passed = result < comparison;
        break;
      case ">=":
        passed = result >= comparison;
        break;
      case "<=":
        passed = result <= comparison;
        break;
      default:
        output.done(new Error(`Unknown operator ${operator}`));
        return;
    }
    if (passed) {
      output.sendDone({ pass: data });
      return;
    }
    output.sendDone({ fail: data });
  });

  return c;
}
