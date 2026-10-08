import { Component, IP } from "@noflo/noflo";

/**
 * Splits a single array (or object) into multiple IPs. Objects are
 * wrapped with the key as the group; arrays are wrapped in one bare
 * stream.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "splits a single array into multiple IPs, wrapped with the key as the group",
    inPorts: {
      in: {
        datatype: "all",
        description: "Array to split from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description: "Values from the split array",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const sendAll = async () => {
      if (typeof data === "object" && !Array.isArray(data)) {
        for (const key of Object.keys(data)) {
          const item = data[key];
          await output.send(new IP("openBracket", key));
          await output.send(new IP("data", item));
          await output.send(new IP("closeBracket", key));
        }
        output.done();
        return;
      }
      await output.send(new IP("openBracket"));
      for (const item of data) {
        await output.send({ out: item });
      }
      await output.send(new IP("closeBracket"));
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
