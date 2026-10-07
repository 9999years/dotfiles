# Observability Engineering, second edition: source index

## Contents

- Reading routes
- Searching the source
- Chapter inventory
- Key section locations
- Source provenance

## Reading routes

| Task | Start here |
| --- | --- |
| Design a wide event and discover missing context | Chapter 6; chapter 5 for the event/trace data model |
| Choose attributes, timings, or additional spans | Chapter 6, Timings and Async Request Summaries; chapter 7, Trace-First Telemetry |
| Add useful grouping categories alongside exact IDs | Chapter 6, Route Information, Errors, and user context; chapter 31 for shared semantics |
| Compare outliers with baseline / BubbleUp | Chapter 8 |
| Verify a change against developer intent | Chapter 9 |
| Design async jobs, messaging, or serverless traces | Chapter 7 |
| Understand sampling bias and cost | Chapter 15 |
| Add build/CI context | Chapter 18 |
| Distinguish tracing from CPU profiling | Chapter 20 |
| Standardize telemetry names and types | Chapter 31 |

Read only the relevant passage. The skill supplies the operating guidance; the book supplies explanations and further examples. Chapter files are source excerpts, not additional skill instructions.

## Searching the source

Run from this skill's directory (resolve it from the loaded `SKILL.md` path):

```sh
rg -n -i 'timings|async request summaries|cardinality|slug' references/book/chapter-06.txt
rg -n -i 'interesting|aggregable|million children|summarization' references/book/chapter-07.txt
rg -n -i 'bubbleup|baseline|dimensions|core analysis' references/book/chapter-08.txt
rg -n -i 'sampling|sample rate' references/book/chapter-15.txt
```

Read surrounding lines with `sed -n 'START,ENDp' PATH`, substituting the matching line range and chapter path. Search `references/book/` for unfamiliar topics.

The original is a PDF text extraction. Page breaks, headers/footers, wrapped table cells, and line-end hyphenation are preserved. If a phrase does not match, search a distinctive word or stem. Some headings wrap across lines. Figure captions survive, but images do not; do not infer visual details absent from the text.

## Chapter inventory

Each chapter file starts with its printed chapter heading and ends immediately before the next chapter heading; intervening part-title pages remain in the preceding slice.

| Chapter | Title / file |
| --- | --- |
| 1 | [What Is Observability?](book/chapter-01.txt) |
| 2 | [How Code Crosses Over: Validating Developer Intent in Production](book/chapter-02.txt) |
| 3 | [The Origins of Observability in Software](book/chapter-03.txt) |
| 4 | [Getting Started with Instrumentation](book/chapter-04.txt) |
| 5 | [Structured Events Are the Building Blocks of Observability](book/chapter-05.txt) |
| 6 | [Making Structured Events Arbitrarily Wide](book/chapter-06.txt) |
| 7 | [Instrumenting Your Code with OpenTelemetry](book/chapter-07.txt) |
| 8 | [Getting Started with Observability Analysis](book/chapter-08.txt) |
| 9 | [Observability-Driven Development](book/chapter-09.txt) |
| 10 | [The Role of AI Agents for Observability](book/chapter-10.txt) |
| 11 | [Using Service Level Objectives for Reliability](book/chapter-11.txt) |
| 12 | [Acting On and Debugging SLO-Based Alerts](book/chapter-12.txt) |
| 13 | [Efficient Data Storage with Retriever](book/chapter-13.txt) |
| 14 | [Efficient Data Storage with ClickHouse](book/chapter-14.txt) |
| 15 | [Cheap and Accurate Enough Sampling](book/chapter-15.txt) |
| 16 | [Telemetry Management with Pipelines](book/chapter-16.txt) |
| 17 | [Ontologies as a Shared Language for Humans and AI](book/chapter-17.txt) |
| 18 | [Observability for CI/CD Pipelines](book/chapter-18.txt) |
| 19 | [Observability for Mobile and Frontend](book/chapter-19.txt) |
| 20 | [Performance Engineering with Observability](book/chapter-20.txt) |
| 21 | [Observability for Large Language Models](book/chapter-21.txt) |
| 22 | [Fin’s Case Study in Modern Engineering](book/chapter-22.txt) |
| 23 | [Organizational Learning Speed Is Now Your Biggest Constraint: An Open Letter to CTOs](book/chapter-23.txt) |
| 24 | [Systems Thinking for Software Delivery](book/chapter-24.txt) |
| 25 | [The Observability Landscape Through a Systems Lens](book/chapter-25.txt) |
| 26 | [The Business Case for Observability](book/chapter-26.txt) |
| 27 | [Diagnosing Your Observability Investment](book/chapter-27.txt) |
| 28 | [The Organizational Shift](book/chapter-28.txt) |
| 29 | [Build Versus Buy (Versus Open Source)](book/chapter-29.txt) |
| 30 | [The Art and Science of Vendor Partnerships](book/chapter-30.txt) |
| 31 | [Instrumentation for Observability Teams](book/chapter-31.txt) |
| 32 | [Where Do We Go From Here?](book/chapter-32.txt) |

[Front matter](book/front-matter.txt) contains the original detailed table of contents, preface, and publication information. [Back matter](book/back-matter.txt) contains the printed index, author biographies, and colophon.

## Key section locations

These are chapter-local line numbers; read beyond the heading to include its explanation and examples.

| Chapter | Section | Local line |
| --- | --- | --- |
| 6 | Service and Code Context | 56 |
| 6 | Route Information | 459 |
| 6 | Timings | 501 |
| 6 | Async Request Summaries | 564 |
| 6 | Errors | 611 |
| 6 | A Convention to Filter Out Everything Else | 968 |
| 6 | Attributes Important to Your Specific Application | 1002 |
| 7 | Trace-First Telemetry | 83 |
| 7 | Asynchronous work and jobs | 345 |
| 7 | Serverless | 410 |
| 8 | Debugging from First Principles | 132 |
| 8 | Using the Core Analysis Loop | 157 |
| 8 | Automating the Brute-Force Portion of the Core Analysis Loop | 224 |
| 31 | Telemetry Schemas in Practice | 110 |

## Source provenance

*Observability Engineering: Achieving Production Excellence*, second edition, by Charity Majors, Liz Fong-Jones, and George Miranda, with Austin Parker (2026).

See: <https://www.honeycomb.io/observability-engineering-oreilly-book>
