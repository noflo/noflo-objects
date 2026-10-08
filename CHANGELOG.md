# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [2.0.0-alpha.1] - 2026-10-08

### Added

- The package is renamed to `@noflo/objects`; graph component identifiers are unaffected and keep resolving under the `objects/` namespace

### Changed

- All 32 components are converted from CoffeeScript to modern JavaScript ES modules for NoFlo 2.x (esm-only), with TypeScript-checked sources and Biome formatting
- Components follow the 2.x Process API contract: preconditions are checked with `has`/`hasData`/`hasStream` before any `get`/`getData` call, so no activation can stall waiting for data it already consumed
- Bracket-carrying grouped streams are preserved on forwarded packets: brackets attached to upstream sends are attached to the corresponding sends downstream
- `FilterProperty` uses `structuredClone` (with a pass-through fallback on `DataCloneError`) instead of the `owl-deepcopy` dependency, which is dropped. The unused `underscore` dependency is also dropped
- The Promise-pure output-omission contract applies where components may produce no output: they omit the output instead of sending empty brackets

### Fixed

- Test suite rebuilt on `@noflo/fbp-spec-runner` (fbp-spec YAML cases) and `node:test`, replacing the Mocha setup
