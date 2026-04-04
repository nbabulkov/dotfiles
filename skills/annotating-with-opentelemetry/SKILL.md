---
name: annotating-with-opentelemetry
description: Use when writing or modifying code that crosses system boundaries, performs long-running operations, or implements core business functionality — to add OpenTelemetry traces, metrics, and log correlation
---

# Annotating with OpenTelemetry

## Overview

Guides you to add proper OpenTelemetry instrumentation after writing or modifying code. Covers traces, metrics, and log correlation. Language-independent concepts with TypeScript and Python quick reference.

## Activation

**Proactive:** When you write code that crosses a system boundary, is long-running, or implements core business logic — offer to instrument:
> "This looks like [a core workflow / a long-running operation / an external call]. Want me to add OpenTelemetry instrumentation?"

Do NOT instrument without user confirmation in proactive mode.

**Manual:** User asks directly ("add telemetry," "instrument this") — activate immediately on the target code.

## Detection Phase

Before instrumenting, inspect the project's OTel setup:

1. **SDK presence** — which OTel packages are installed? (`@opentelemetry/*`, `opentelemetry-*`, framework wrappers like `@vercel/otel`)
2. **Auto-instrumentation** — registered instrumentations already creating spans? (look for instrumentation configs, `registerInstrumentations()`)
3. **Existing manual spans** — how does the project create spans? What naming conventions and attributes?
4. **Exporter config** — where do traces/metrics go? (OTLP, Jaeger, console, vendor)
5. **Logging setup** — is there trace-log correlation? What logger?

**Adapt:**
- Auto-instrumentation covers it → **enrich** existing spans with custom attributes
- No auto-instrumentation → **create manual spans** following existing project conventions
- No OTel setup at all → **flag to user**, offer to help set up basics first

**Match the project's style.** If they use `tracer.startActiveSpan()`, don't introduce `tracer.startSpan()`. If there's a wrapper utility, use it.

## Hard Rules

### Span Hygiene

- Name spans as `<Component>.<operation>` (e.g., `PaymentService.processRefund`)
- Always set span status to `ERROR` on exceptions — record the exception via `recordException`
- Always end spans, even on error paths — use try/finally or context managers
- Never create spans inside tight loops — instrument the loop or batch operation itself

### Attribute Discipline

**Semantic conventions** for infrastructure (`http.request.method`, `db.system`, `rpc.service`). **Dot-namespaced** for business domain (`deal.id`, `document.page_count`, `job.type`).

**What to capture:**

| Category | When | Examples |
|---|---|---|
| Identity | Every span | `user.id`, `order.id`, `document.id` |
| Operation context | Every span | `job.type`, `api.endpoint`, `query.name` |
| Outcome | Every span | `result.status`, `result.count`, error codes |
| Source/destination | System boundaries | `peer.service`, `server.address` |
| Size/volume | System boundaries | `http.request.body.size`, `db.result.row_count` |
| Progress | Long-running ops | `batch.total_items`, `batch.processed_items` |

**Never capture:** full request/response bodies, credentials/tokens/PII, high-cardinality unbounded attribute keys, info already captured by auto-instrumentation.

### Metrics

| Type | Use when | Answers | Example |
|---|---|---|---|
| Histogram | Latency distribution matters | "What's the p95?" | `document.parse.duration_seconds` |
| Counter | Rate/throughput matters | "How many per second?" | `job.process.count` |
| Gauge | Value goes up and down | "What's the current state?" | `queue.depth` |

**Naming:** `<domain>.<noun>.<unit>` — always include the unit (`_seconds`, `_bytes`, `_count`).

**Metric attributes:** Low-cardinality dimensions only (`job.type`, `status`, `endpoint`). Never user IDs or request IDs — each unique combination creates a new time series.

**Don't create metrics** for things derivable from span data, one-off operations, or "just in case."

### Log Correlation

- Include `trace_id` and `span_id` in structured log entries
- Log at span boundaries: entry (input context) and exit (outcome)
- Error logs must be inside the span so they inherit trace context

## Principles

**Decision rule:** Instrument if the operation can independently: fail, vary in latency, or be called with different parameters that affect behavior. If none apply, skip it.

| Principle | Meaning |
|---|---|
| Boundary, not implementation | Spans at public interfaces, not internal helpers |
| Depth follows pain | Start shallow, add depth where debugging is hard |
| Attributes over child spans | Don't create a child span just for one piece of context |
| Events for moments, spans for durations | Span events for "cache miss"; child spans for sub-operations with own lifecycle |
| One metric, many dimensions | Add attribute dimensions, don't create separate metrics per variant |

## Quick Reference: TypeScript & Python

### Traces

| Concept | TypeScript (`@opentelemetry/api`) | Python (`opentelemetry`) |
|---|---|---|
| Get tracer | `trace.getTracer('name')` | `trace.get_tracer('name')` |
| Span (recommended) | `tracer.startActiveSpan('name', async (span) => { ... span.end() })` | `with tracer.start_as_current_span('name') as span:` |
| Span (manual) | `const span = tracer.startSpan('name'); ... span.end()` | `@tracer.start_as_current_span('name')` (decorator) |
| Set attribute | `span.setAttribute('key', val)` | `span.set_attribute('key', val)` |
| Set multiple | `span.setAttributes({ k: v })` | `span.set_attributes({'k': v})` |
| Add event | `span.addEvent('name', { k: v })` | `span.add_event('name', {'k': v})` |
| Error status | `span.setStatus({ code: SpanStatusCode.ERROR, message })` | `span.set_status(StatusCode.ERROR, msg)` |
| Record exception | `span.recordException(error)` | `span.record_exception(exc)` |
| Span kind | `{ kind: SpanKind.CLIENT }` | `kind=SpanKind.CLIENT` |
| Semantic attrs | `import { ATTR_HTTP_REQUEST_METHOD } from '@opentelemetry/semantic-conventions'` | `'http.request.method'` (string keys) |

### Metrics

| Concept | TypeScript (`@opentelemetry/api`) | Python (`opentelemetry.metrics`) |
|---|---|---|
| Get meter | `metrics.getMeter('name')` | `metrics.get_meter('name')` |
| Counter | `meter.createCounter('name')` | `meter.create_counter('name')` |
| Histogram | `meter.createHistogram('name')` | `meter.create_histogram('name')` |
| Observable gauge | `meter.createObservableGauge('name')` | `meter.create_observable_gauge('name')` |
| Record counter | `counter.add(1, { attr: val })` | `counter.add(1, {'attr': val})` |
| Record histogram | `histogram.record(dur, { attr: val })` | `histogram.record(dur, {'attr': val})` |

### Log Correlation

| Concept | TypeScript | Python |
|---|---|---|
| Active span | `trace.getActiveSpan()` | `trace.get_current_span()` |
| Trace ID | `span.spanContext().traceId` | `span.get_span_context().trace_id` |
| Span ID | `span.spanContext().spanId` | `span.get_span_context().span_id` |

## Example

Instrumenting an external API call (TypeScript):

```typescript
return tracer.startActiveSpan('DocumentParser.parse', async (span) => {
  // Identity + context
  span.setAttributes({ 'document.id': documentId, 'peer.service': 'llamaparse' });

  try {
    const response = await fetch(endpoint, { method: 'POST', body });
    // Outcome
    span.setAttribute('document.page_count', result.pages.length);
    span.setStatus({ code: SpanStatusCode.OK });
    return result;
  } catch (error) {
    span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    span.recordException(error);
    throw error;
  } finally {
    span.end();
  }
});
```

Python equivalent uses `with tracer.start_as_current_span('DocumentParser.parse') as span:` — same attribute and error handling pattern.
