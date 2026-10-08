import { Component, IP } from "@noflo/noflo";

/**
 * Splits a single object into multiple IPs, wrapped with the key as the
 * group.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "splits a single object into multiple IPs, wrapped with the key as the group",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to split key/values from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description:
          "Values from the input object (one value per IP and its key sent as group)",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const sendAll = async () => {
      for (const key of Object.keys(data)) {
        const value = data[key];
        await output.send(new IP("openBracket", key));
        await output.send(new IP("data", value));
        await output.send(new IP("closeBracket", key));
      }
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
