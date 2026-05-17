# otel_bullmq

Dartastic OpenTelemetry bridge for BullMQ (Node.js Redis-backed queue).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_bullmq/otel_bullmq.dart';

await tracedBullmq<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return BullmqCallResult(value: r, result: BullmqResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutBullmqInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
