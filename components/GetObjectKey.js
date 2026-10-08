import { Component, IP } from "@noflo/noflo";

/**
 * getStream's declared return type is a loose union; cast it for every
 * stream read until the core types are tightened.
 * @param {{ getStream(port: string): unknown }} input
 * @param {string} port
 * @returns {import("@noflo/noflo").IP[]}
 */
const readStream = (input, port) =>
  /** @type {import("@noflo/noflo").IP[]} */ (input.getStream(port));

/**
 * Extracts values from an object by key, optionally wrapping each value
 * with the key as a group. Objects with no matching keys go to `missed`,
 * those with at least one match to `object`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Extract values from an object by key",
    icon: "indent",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to get keys from",
        required: true,
      },
      key: {
        datatype: "string",
        description: "Keys to extract from the object (one key per IP)",
        required: true,
      },
      sendgroup: {
        datatype: "string",
        description: '"true" to send keys as groups around value IPs',
        control: true,
        default: "false",
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description:
          "Values extracted from the input object given the input keys (one value per IP, potentially grouped using the key names)",
      },
      object: {
        datatype: "object",
        description:
          "Object forwarded from input if at least one property matches the input keys",
      },
      missed: {
        datatype: "object",
        description:
          "Object forwarded from input if no property matches the input keys",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (!input.hasStream("key")) {
      return;
    }
    // Wait for an attached sendgroup connection to deliver before firing
    if (input.attached("sendgroup").length > 0 && !input.hasData("sendgroup")) {
      return;
    }
    const keys = readStream(input, "key")
      .filter((ip) => ip.type === "data")
      .map((ip) => ip.data);
    const data = input.getData("in");

    const sendGroupRaw = input.hasData("sendgroup")
      ? input.getData("sendgroup")
      : "false";
    const sendGroup = sendGroupRaw === "true" || sendGroupRaw === true;

    if (typeof data !== "object" || data === null) {
      output.sendDone(
        new Error(data === null ? "Data is NULL" : "Data is not an object"),
      );
      return;
    }

    const sendAll = async () => {
      for (const key of keys) {
        if (data[key] === undefined) {
          if (sendGroup) {
            await output.send({ missed: new IP("openBracket", key) });
          }
          await output.send({ missed: new IP("data", data) });
          if (sendGroup) {
            await output.send({ missed: new IP("closeBracket", key) });
          }
          // 1.x also sent the undefined value on out; keep the semantics
          if (sendGroup) {
            await output.send({ out: new IP("openBracket", key) });
          }
          await output.send({ out: new IP("data", data[key]) });
          if (sendGroup) {
            await output.send({ out: new IP("closeBracket", key) });
          }
          continue;
        }
        if (sendGroup) {
          await output.send({ out: new IP("openBracket", key) });
        }
        await output.send({ out: new IP("data", data[key]) });
        if (sendGroup) {
          await output.send({ out: new IP("closeBracket", key) });
        }
      }
      // 1.x sent the object unconditionally, despite the port description
      await output.send({ object: new IP("data", data) });
      output.done();
    };
    sendAll().catch((err) => output.done(err));
  });

  return c;
}
