// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_bullmq_suppress;

bool bullmqInstrumentationSuppressed() => Zone.current[_key] == true;

T runWithoutBullmqInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

Future<T> runWithoutBullmqInstrumentationAsync<T>(Future<T> Function() body) =>
    runZoned(body, zoneValues: {_key: true});
