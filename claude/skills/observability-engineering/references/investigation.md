# Population-comparison workflow

Use this for live investigation or to verify that emitted telemetry supports cohort comparisons. Use available query tools; no particular vendor is required.

For BubbleUp or a manual equivalent:

1. Select a comparable population of units of work and visualize its distribution, usually with a latency heatmap or percentiles plus counts. Select primary events by service and operation so child spans do not distort the denominator.
2. Select the slow, failing, or otherwise unusual cohort and compare it with an appropriate baseline. State the time window and population filters.
3. Compare field-value frequencies, numeric distributions, and missingness across the selection and baseline. Let unexpected dimensions surface; do not inspect only the dimensions in the initial hypothesis.
4. Group/filter on the strongest clues, inspect representative traces, and verify the proposed explanation. Correlation supplies a hypothesis, not proof of causation. Check sample sizes, traffic mix, and sampling bias.
5. Feed gaps back into instrumentation: add the missing context to the owning event so the next investigation can answer the question directly.

If a field is only populated on errors, its presence may simply restate the selection condition. Check that relevant categories and measurements exist on successes too, with unknown/missing distinct from false or zero.
