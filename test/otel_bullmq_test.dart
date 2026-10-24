// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_bullmq/otel_bullmq.dart';
import 'package:test/test.dart';

void main() {
  group('otel_bullmq', () {
    test('suppression toggles in zone', () async {
      expect(bullmqInstrumentationSuppressed(), isFalse);
      await runWithoutBullmqInstrumentationAsync(() async {
        expect(bullmqInstrumentationSuppressed(), isTrue);
      });
      expect(bullmqInstrumentationSuppressed(), isFalse);
    });

    test('BullMQResult fields default null', () {
      const r = BullMQResult();
      expect(r.statusCode, isNull);
    });
  });
}
