---
name: otel-semconv
description: Applies OpenTelemetry semantic conventions when adding or reviewing telemetry attribute names.
---

# OpenTelemetry semantic conventions

**Consult the specification, use the language's semconv library, and define service-specific keys in a dedicated module.**
Treat attribute names and their meanings as a schema shared by instrumentation and its consumers.

## Consult the spec before choosing a name

Inspect existing telemetry, dependency versions, and any local semconv module first.
Then consult the [OpenTelemetry semantic conventions](https://opentelemetry.io/docs/specs/semconv/) and [attribute registry](https://opentelemetry.io/docs/specs/semconv/registry/attributes/) for the concept being recorded.
Read the relevant domain and signal conventions as well as the registry entry.

Check the attribute's meaning, value type, units, allowed values, recording conditions, placement (resource, span, log, or metric), stability, and deprecation status.
Reuse a standard attribute only when its semantics fit.

Consult the current spec, then reconcile it with the version used by the project and its instrumentation.
Prefer stable conventions where applicable.
Identify development or deprecated conventions explicitly; do not mix old and new schemas accidentally.
If sources cannot be accessed, report that limitation and distinguish verified definitions from proposals.

## Use the language's semconv library

Use the language's semconv constants or typed helpers for standard keys and enumerated values (Rust: [opentelemetry-semantic-conventions](https://docs.rs/opentelemetry-semantic-conventions)).
Look up symbols and feature gates in the installed version's documentation or source.
Add a compatible dependency when needed; do not redeclare available upstream keys locally.

- A missing library symbol does not imply a missing standard.
  Check version coverage and optional features before inventing a custom key.
- If no usable library definition exists, isolate the exact spec-defined key in the local semconv module with its source/version and the reason for the fallback.
  Include a URL to the spec upstream in a doc comment for reference.
  Keep these compatibility definitions visibly separate from custom attributes.

## Centralize service-specific attributes

For concepts with no appropriate upstream equivalent, use a dedicated module such as `semconv.rs`, `semconv.py`, or the language's idiomatic equivalent.
Extend an existing module rather than creating a competing catalog.
Instrumentation sites must import its constants instead of repeating key strings, even when a new key initially has only one caller.

Document each definition's meaning, type, units, allowed values, recording conditions, and absence semantics.
Distinguish related measurements precisely, e.g. bytes received versus bytes durably committed.

Shared components should own their definitions; import or re-export those constants instead of copying them into each service.
Keep domain values typed until the telemetry boundary, especially enums, identifiers, and durations.

For new custom names, follow the [OTel naming guidance](https://opentelemetry.io/docs/specs/semconv/general/naming/): lowercase, dot-separated namespaces, and snake_case within components.
Use an established internal namespace policy or a distinctive application/company prefix.
Avoid extending standard namespaces with private meanings; `otel.*` is reserved.
Keep keys static and put request IDs and other variable data in values.

## Preserve and verify the schema

Moving existing literals into constants should preserve emitted names and values.
Renaming a key or changing its type, unit, or meaning is a telemetry schema migration: inspect affected queries, dashboards, alerts, and other consumers, and handle compatibility deliberately within the requested scope.

When behavior changes, use representative emitted telemetry or an in-memory exporter test to verify names, types, placement, and recording conditions, including meaningful failure cases.
Avoid tests that only assert a constant equals its own literal.
