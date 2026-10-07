# Instrumentation examples

These examples illustrate decisions, not a complete attribute checklist. Extend them with the application's domain context. Custom names below are illustrative; use the project's conventions and current OpenTelemetry conventions where applicable.

## Pairing precise values with categories

Categories supplement precise values so recurring cohorts can be compared without losing individual identities or exact measurements.

| Keep this detail | Add this grouping dimension |
| --- | --- |
| Tenant or user ID | Account tier, authentication method, enabled product capabilities |
| URL/path and extracted object IDs, where appropriate | Matched route template, HTTP method |
| Error message and diagnostic details | Error type, domain failure reason, stable code-site slug |
| Build/job ID and exact graph size | Job kind, target platform, execution mode, cache outcome |
| Exact numeric payload size or item count | Optional, explicitly defined size class when it captures a useful domain distinction |

An error slug such as `payment-retries-exhausted` identifies a failure site, not an exception instance. Derive categories from domain enums, route templates, and stable sites; avoid interpolating IDs or messages into them.

## A checkout request with a slow minority

Existing instrumentation has a server span and spans for the payment and database calls. A patch adds spans around parsing, each validation rule, flag evaluation, and calculating totals.

Instead, enrich the existing checkout span with the branch decisions, validation outcome, totals, and selected phase timings. Keep the meaningful dependency spans. Add a business-operation span only if it has an independently useful lifetime or failure boundary.

Useful fields on the checkout event include:

| Context | Example fields |
| --- | --- |
| Selection and identity | `main`, service, matched route, trace ID, request ID, customer ID |
| Cohorts | Customer tier, region, authentication method, payment provider, checkout flow, evaluated flag variant |
| Workload | Line item count, distinct product count, payload bytes, discount count, currency |
| Timings | Authentication duration, payload parsing duration, payment cumulative duration, total elapsed duration |
| Summaries | Database call count, payment attempt count, retry reason, cache hits and misses |
| Outcome | Success/failure, HTTP status, domain failure category, stable error slug |

Query the main checkout spans, select the slow tail, and compare all available fields with the baseline. If enterprise accounts on a new checkout flow show elevated authentication time, filter those dimensions and inspect traces to test the explanation. Putting the timing exclusively on a child span makes that population comparison harder.

Record the relevant tier and flag variant on fast requests too. Otherwise field presence may reveal only which code path received extra instrumentation.

## Error messages that all look unique

Errors currently include `invoice 8f3... failed on attempt 3: timeout`. Grouping by the full message produces mostly singleton groups.

Keep invoice identity and useful error detail, then add independently queryable fields such as:

```text
error.type = "TimeoutError"
app.error.slug = "invoice-provider-retries-exhausted"
app.failure.reason = "upstream_timeout"
app.retry.count = 2
app.invoice.id = "8f3..."
app.provider = "provider-a"
```

The slug is stable at the failure site; it does not interpolate the invoice ID. Provider, failure reason, and slug let many events form comparable groups. Invoice ID lets an investigator follow one exact case. On successes, emit the normal outcome and provider; omit inapplicable error fields rather than supplying fake error values.

## A build with a million graph nodes

Do not create a span or dynamically named field for every node just to show that it was visited. Emit a wide build summary that describes the graph and execution, including:

- Build identity, revision, repository, trigger, target platform, toolchain, and configuration.
- Nodes, edges, maximum depth, target count, dependency counts by meaningful kind, and input/output bytes.
- Execution strategy, enabled features, cache modes, hits/misses, remote/local work, retries, and failure categories.
- Graph planning, dependency resolution, execution, and artifact publication timings.
- Worker/resource characteristics and the final result.

Hundreds or thousands of useful attributes can be appropriate here. These should describe actual dimensions of the work, not encode node IDs into attribute names or dump an unqueryable graph blob. Preserve exact numeric counts; add a domain-specific size class only when useful.

Keep spans for meaningful stages, remote calls, or independently useful tasks. For a long-running build, stage traces linked by build identity can avoid a huge monolithic trace. Intermediate progress needs separate telemetry; the final summary is only available at completion.

Compare slow builds by platform, execution strategy, cache outcome, and graph shape, then follow build IDs into representative traces. Cumulative worker time and wall-clock elapsed time are separate measurements.

## A queue worker that outlives its HTTP caller

An endpoint enqueues a task and returns before the worker starts. Adding worker results to the ended HTTP span would lose them or misrepresent its lifetime.

Keep producer/consumer spans and propagate or link context as appropriate to the messaging model. Enrich the worker's own unit-of-work span with job type, job identity, queue latency, attempt count, input shape, processing phases, and outcome. Summarize a larger workflow in its own completion event if needed. The request event describes acceptance; the worker event describes processing. Model those outcomes separately.
