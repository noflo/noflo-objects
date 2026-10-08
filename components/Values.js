import { Component, IP } from "@noflo/noflo";

/**
 * Gets only the values of an object, forwarding them as a bracketed
 * stream with one value per IP.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "gets only the values of an object and forward them as an array",
    inPorts: {
      in: {
        datatype: "all",
        description: "Object to extract values from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description:
          "Values extracted from the input object (one value per IP)",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const keys = Object.keys(data);
    const values = keys.map((key) => data[key]);

    const sendAll = async () => {
      await output.send(new IP("openBracket"));
      for (const value of values) {
        await output.send(new IP("data", value));
      }
      await output.send(new IP("closeBracket"));
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
