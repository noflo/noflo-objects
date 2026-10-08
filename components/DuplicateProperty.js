import { Component } from "@noflo/noflo";

/**
 * Duplicates a property on an object under a new name, optionally
 * joining several source properties with a separator.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Duplicate a property on an object",
    inPorts: {
      property: {
        datatype: "string",
        description: "Property to duplicate, in 'new=original' form",
        control: true,
        required: true,
      },
      separator: {
        datatype: "string",
        description: "Separator to use to join properties",
        control: true,
        default: "/",
      },
      in: {
        datatype: "object",
        description: "Object to duplicate property on",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "object",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("property", "separator", "in")) {
      return;
    }
    const [prop, sep, data] = input.getData("property", "separator", "in");

    /** @type {Record<string, any>} */
    const properties = {};
    const separator = sep != null ? sep : "/";

    if (prop) {
      if (typeof prop === "object") {
        output.done(new Error("Property name cannot be an object"));
        return;
      }
      const propParts = prop.split("=");
      if (propParts.length > 2) {
        properties[propParts.pop()] = propParts;
      } else {
        properties[propParts[1]] = propParts[0];
      }
    }

    if (!data) {
      return;
    }
    for (const newProp of Object.keys(properties)) {
      const original = properties[newProp];
      if (typeof original === "string") {
        data[newProp] = data[original];
        continue;
      }
      const newValues = [];
      for (const originalProp of original) {
        newValues.push(data[originalProp]);
      }
      data[newProp] = newValues.join(separator);
    }
    output.sendDone({ out: data });
  });

  return c;
}
