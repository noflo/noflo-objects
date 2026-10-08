import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getCallMethod } from "../components/CallMethod.js";
import { getComponent as getExtractProperty } from "../components/ExtractProperty.js";
import { getComponent as getFilterProperty } from "../components/FilterProperty.js";
import { getComponent as getFilterPropertyValue } from "../components/FilterPropertyValue.js";
import { getComponent as getFlattenObject } from "../components/FlattenObject.js";
import { getComponent as getGetObjectKey } from "../components/GetObjectKey.js";
import { getComponent as getInsertProperty } from "../components/InsertProperty.js";
import { getComponent as getKeys } from "../components/Keys.js";
import { getComponent as getMergeObjects } from "../components/MergeObjects.js";
import { getComponent as getSplitArray } from "../components/SplitArray.js";
import { getComponent as getSplitObject } from "../components/SplitObject.js";
import { getComponent as getValues } from "../components/Values.js";

/**
 * Waits for the next IP on a socket matching the predicate.
 * @param {import("@noflo/noflo").internalSocket.InternalSocket} socket
 * @param {(ip: import("@noflo/noflo").IP) => boolean} predicate
 * @returns {Promise<import("@noflo/noflo").IP>}
 */
const waitUntil = (socket, predicate) =>
  new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      cleanup();
      reject(new Error("Timed out waiting for IP"));
    }, 2000);
    /** @param {CustomEvent} event */
    const listener = (event) => {
      const ip = event.detail;
      if (predicate(ip)) {
        cleanup();
        resolve(ip);
      }
    };
    const cleanup = () => {
      clearTimeout(timer);
      socket.removeEventListener("ip", listener);
    };
    socket.addEventListener("ip", listener);
  });

/** @param {import("@noflo/noflo").internalSocket.InternalSocket} socket */
const collect = (socket) => {
  /** @type {import("@noflo/noflo").IP[]} */
  const ips = [];
  socket.addEventListener(
    "ip",
    /** @param {CustomEvent} event */ (event) => {
      ips.push(event.detail);
    },
  );
  return ips;
};

describe("InsertProperty component", () => {
  it("inserts the grouped property into the object", async () => {
    const c = getInsertProperty();
    const inSocket = noflo.internalSocket.createSocket();
    const propertySocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.property.attach(propertySocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "data");
      propertySocket.post(new noflo.IP("openBracket", "newprop"));
      propertySocket.post(new noflo.IP("data", "newvalue"));
      propertySocket.post(new noflo.IP("closeBracket", "newprop"));
      inSocket.post(new noflo.IP("data", { keep: "me" }));
      await done;
      assert.deepEqual(
        /** @type {import('@noflo/noflo').IP} */ (
          outIps.find((ip) => ip.type === "data")
        ).data,
        {
          keep: "me",
          newprop: "newvalue",
        },
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("CallMethod component", () => {
  it("calls the method with buffered arguments", async () => {
    const c = getCallMethod();
    const inSocket = noflo.internalSocket.createSocket();
    const methodSocket = noflo.internalSocket.createSocket();
    const argumentsSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.method.attach(methodSocket);
    c.inPorts.arguments.attach(argumentsSocket);
    c.outPorts.out.attach(outSocket);
    try {
      methodSocket.post(new noflo.IP("data", "greet"));
      argumentsSocket.post(new noflo.IP("openBracket", "args"));
      argumentsSocket.post(new noflo.IP("data", "world"));
      argumentsSocket.post(new noflo.IP("closeBracket", "args"));
      const outIp = waitUntil(outSocket, (ip) => ip.type === "data");
      inSocket.post(
        new noflo.IP("data", {
          greet: /** @param {string} name */ (name) => `hello ${name}`,
        }),
      );
      const ip = await outIp;
      assert.equal(ip.data, "hello world");
    } finally {
      await c.shutdown();
    }
  });
});

describe("GetObjectKey component", () => {
  it("sends matched values grouped and forwards the object", async () => {
    const c = getGetObjectKey();
    const inSocket = noflo.internalSocket.createSocket();
    const keySocket = noflo.internalSocket.createSocket();
    const sendgroupSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const objectSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.key.attach(keySocket);
    c.inPorts.sendgroup.attach(sendgroupSocket);
    c.outPorts.out.attach(outSocket);
    c.outPorts.object.attach(objectSocket);
    const outIps = collect(outSocket);
    try {
      // Control ports before the firing port
      keySocket.post(new noflo.IP("openBracket", "keys"));
      keySocket.post(new noflo.IP("data", "a"));
      keySocket.post(new noflo.IP("data", "b"));
      keySocket.post(new noflo.IP("closeBracket", "keys"));
      sendgroupSocket.post(new noflo.IP("data", "true"));
      const done = waitUntil(
        objectSocket,
        (ip) => ip.type === "data" || ip.type === "error",
      );
      inSocket.post(new noflo.IP("data", { a: 1, b: 2 }));
      await done;
      assert.deepEqual(
        outIps.map((ip) => [ip.type, ip.data]),
        [
          ["openBracket", "a"],
          ["data", 1],
          ["closeBracket", "a"],
          ["openBracket", "b"],
          ["data", 2],
          ["closeBracket", "b"],
        ],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("Keys component", () => {
  it("emits one packet per key", async () => {
    const c = getKeys();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(
        outSocket,
        (ip) => ip.type === "data" && ip.data === "b",
      );
      inSocket.post(new noflo.IP("data", { a: 1, b: 2 }));
      await done;
      assert.deepEqual(
        outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
        ["a", "b"],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("Values component", () => {
  it("emits a bracketed stream of values", async () => {
    const c = getValues();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "closeBracket");
      inSocket.post(new noflo.IP("data", { a: 1, b: 2 }));
      await done;
      assert.deepEqual(
        outIps.map((ip) => [ip.type, ip.data]),
        [
          ["openBracket", null],
          ["data", 1],
          ["data", 2],
          ["closeBracket", null],
        ],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("SplitObject component", () => {
  it("wraps each value with its key as group", async () => {
    const c = getSplitObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "closeBracket");
      inSocket.post(new noflo.IP("data", { a: 1 }));
      await done;
      assert.deepEqual(
        outIps.map((ip) => [ip.type, ip.data]),
        [
          ["openBracket", "a"],
          ["data", 1],
          ["closeBracket", "a"],
        ],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("SplitArray component", () => {
  it("wraps an array in a bare stream", async () => {
    const c = getSplitArray();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "closeBracket");
      inSocket.post(new noflo.IP("data", [1, 2]));
      await done;
      assert.deepEqual(
        outIps.map((ip) => [ip.type, ip.data]),
        [
          ["openBracket", null],
          ["data", 1],
          ["data", 2],
          ["closeBracket", null],
        ],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("MergeObjects component", () => {
  it("merges all objects in the stream", async () => {
    const c = getMergeObjects();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "data");
      inSocket.post(new noflo.IP("openBracket", "batch"));
      inSocket.post(new noflo.IP("data", { a: 1 }));
      inSocket.post(new noflo.IP("data", { b: 2 }));
      inSocket.post(new noflo.IP("data", { a: 3, list: [1] }));
      inSocket.post(new noflo.IP("data", { list: [2] }));
      inSocket.post(new noflo.IP("closeBracket", "batch"));
      await done;
      assert.deepEqual(
        /** @type {import("@noflo/noflo").IP} */ (
          outIps.find((ip) => ip.type === "data")
        ).data,
        { a: 3, b: 2, list: [1, 2] },
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("ExtractProperty component", () => {
  it("sends each traversed value", async () => {
    const c = getExtractProperty();
    const inSocket = noflo.internalSocket.createSocket();
    const keySocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.key.attach(keySocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      keySocket.post(new noflo.IP("openBracket", "keys"));
      keySocket.post(new noflo.IP("data", "a"));
      keySocket.post(new noflo.IP("data", "b"));
      keySocket.post(new noflo.IP("closeBracket", "keys"));
      const done = waitUntil(
        outSocket,
        (ip) => ip.type === "data" && ip.data === 2,
      );
      inSocket.post(new noflo.IP("data", { a: { b: 2 } }));
      await done;
      assert.deepEqual(
        outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
        [{ b: 2 }, 2],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("FlattenObject component", () => {
  it("flattens nested objects into entries", async () => {
    const c = getFlattenObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    try {
      const done = waitUntil(outSocket, (ip) => ip.type === "closeBracket");
      inSocket.post(new noflo.IP("data", { a: { b: 1 } }));
      await done;
      assert.deepEqual(
        outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
        [{ value: 1 }],
      );
    } finally {
      await c.shutdown();
    }
  });
});

describe("FilterProperty component", () => {
  it("removes keys matching the configured regexps", async () => {
    const c = getFilterProperty();
    const inSocket = noflo.internalSocket.createSocket();
    const keySocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.key.attach(keySocket);
    c.outPorts.out.attach(outSocket);
    try {
      keySocket.post(new noflo.IP("data", "^secret"));
      const done = waitUntil(
        outSocket,
        (ip) => ip.type === "data" || ip.type === "error",
      );
      inSocket.post(new noflo.IP("data", { secret: "hide", keep: "me" }));
      const ip = await done;
      assert.deepEqual(ip.data, { keep: "me" });
    } finally {
      await c.shutdown();
    }
  });
});

describe("FilterPropertyValue component", () => {
  it("keeps only accepted values", async () => {
    const c = getFilterPropertyValue();
    const inSocket = noflo.internalSocket.createSocket();
    const acceptSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const missedSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.accept.attach(acceptSocket);
    c.outPorts.out.attach(outSocket);
    c.outPorts.missed.attach(missedSocket);
    const missedIps = collect(missedSocket);
    const outIps = collect(outSocket);
    try {
      acceptSocket.post(new noflo.IP("openBracket", "accept"));
      acceptSocket.post(new noflo.IP("data", "keep=me"));
      acceptSocket.post(new noflo.IP("closeBracket", "accept"));
      const done = waitUntil(
        missedSocket,
        (ip) => ip.type === "data" || ip.type === "error",
      );
      inSocket.post(new noflo.IP("openBracket", "objects"));
      inSocket.post(new noflo.IP("data", { keep: "me" }));
      inSocket.post(new noflo.IP("data", { other: "x" }));
      inSocket.post(new noflo.IP("closeBracket", "objects"));
      await done;
      assert.deepEqual(
        outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
        [{ keep: "me" }],
      );
      assert.deepEqual(
        missedIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
        [{ other: "x" }],
      );
    } finally {
      await c.shutdown();
    }
  });
});
