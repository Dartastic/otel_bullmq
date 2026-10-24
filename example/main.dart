// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_bullmq/otel_bullmq.dart';

/// Traces Bullmq calls with OpenTelemetry.
///
/// `otel_bullmq` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Bullmq call in
/// [tracedBullMQ]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'bullmq-example');

  // Traces a Bullmq call.
  final bullMQId = await tracedBullMQ<String>(
    operation: 'create',
    invoke: () async {
      // Make the Bullmq call here, then report what it returned.
      const id = 'bullmq_8f3a2c';
      return const BullMQCallResult(
          value: id,
          result: BullMQResult(
              queueName: 'orders',
              jobName: 'example',
              jobId: 'job_8f3a2c',
              attempts: 1,
              priority: 1,
              delayMs: 120,
              parentId: 'parent_8f3a2c',
              flowId: 'flow_8f3a2c',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedBullMQ create returned $bullMQId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutBullmqInstrumentationAsync.
  await runWithoutBullmqInstrumentationAsync(
    () => tracedBullMQ<String>(
      operation: 'create',
      invoke: () async {
        const id = 'bullmq_8f3a2c';
        return const BullMQCallResult(
            value: id,
            result: BullMQResult(
                queueName: 'orders',
                jobName: 'example',
                jobId: 'job_8f3a2c',
                attempts: 1,
                priority: 1,
                delayMs: 120,
                parentId: 'parent_8f3a2c',
                flowId: 'flow_8f3a2c',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
