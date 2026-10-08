import { Component, IP } from "@noflo/noflo";

/**
 * Gets only the keys of an object, forwarding them as one packet per key.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "gets only the keys of an object and forward them as an array",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to get keys from",
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "string",
        description: "Keys from the incoming object (one per IP)",
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
        await output.send({ out: new IP("data", key) });
      }
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
