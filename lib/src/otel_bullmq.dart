// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_bullmq_suppression.dart';

class BullMQResult {
  const BullMQResult({
    this.queueName,
    this.jobName,
    this.jobId,
    this.attempts,
    this.priority,
    this.delayMs,
    this.parentId,
    this.flowId,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? queueName;
  final String? jobName;
  final String? jobId;
  final int? attempts;
  final int? priority;
  final int? delayMs;
  final String? parentId;
  final String? flowId;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class BullMQCallResult<T> {
  const BullMQCallResult({required this.value, this.result});
  final T value;
  final BullMQResult? result;
}

Future<T> tracedBullMQ<T>({
  required String operation,
  required Future<BullMQCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (bullmqInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_bullmq');
  final span = t.startSpan('bullmq $operation', kind: SpanKind.producer);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('messaging.system', 'bullmq')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.queueName != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('messaging.destination.name', res.queueName!)
        ]));
      }
      if (res.jobName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bullmq.job.name', res.jobName!)]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('messaging.message.id', res.jobId!)]));
      }
      if (res.attempts != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('bullmq.attempts', res.attempts!)]));
      }
      if (res.priority != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('messaging.message.priority', res.priority!)]));
      }
      if (res.delayMs != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeInt('bullmq.delay', res.delayMs!)]));
      }
      if (res.parentId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bullmq.parent_id', res.parentId!)]));
      }
      if (res.flowId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bullmq.flow_id', res.flowId!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bullmq.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'bullmq.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
