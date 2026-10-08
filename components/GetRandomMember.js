import { Component } from "@noflo/noflo";

/**
 * Picks a random member from an array, using a random number between
 * 0 and 1 (from the `random` port, for determinism in tests).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Select a random member from an array",
    icon: "list",
    inPorts: {
      in: {
        datatype: "array",
        description: "Array to pick a member from",
        required: true,
      },
      random: {
        datatype: "number",
        description: "Random number to use, between 0 and 1",
        control: true,
        required: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
      },
      error: {
        datatype: "object",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "random")) {
      return;
    }
    const [arr, random] = input.getData("in", "random");

    if (random < 0 || random > 1) {
      output.done(new Error("Random number has to be between 0 and 1"));
      return;
    }
    const selected =
      arr[Math.min(arr.length - 1, Math.floor(random * arr.length))];
    output.sendDone({ out: selected });
  });

  return c;
}
