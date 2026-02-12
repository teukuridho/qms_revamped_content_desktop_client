import 'sse_frame.dart';

enum SseIncrementalIdMismatchReason { missingId, nonNumericId, unexpectedId }

class SseIncrementalIdMismatch {
  final int expectedId;
  final String? actualIdRaw;
  final int? actualIdParsed;
  final SseIncrementalIdMismatchReason reason;
  final SseFrame frame;

  const SseIncrementalIdMismatch({
    required this.expectedId,
    required this.actualIdRaw,
    required this.actualIdParsed,
    required this.reason,
    required this.frame,
  });

  @override
  String toString() {
    return 'SseIncrementalIdMismatch(expectedId: $expectedId, actualIdRaw: $actualIdRaw, actualIdParsed: $actualIdParsed, reason: $reason)';
  }
}

typedef SseIncrementalMismatchCallback =
    void Function(SseIncrementalIdMismatch mismatch);

class SseIncrementalIdValidator {
  int? _lastId;
  bool _initialized = false;

  bool get initialized => _initialized;
  int? get lastId => _lastId;

  void reset() {
    _lastId = null;
    _initialized = false;
  }

  /// Returns `null` when ok. Returns mismatch when invalid.
  ///
  /// When [requireFirstId] is true and the validator is not initialized yet,
  /// missing/non-numeric id produces a mismatch.
  SseIncrementalIdMismatch? validate(
    SseFrame frame, {
    required bool requireFirstId,
  }) {
    final hasIdField = frame.fields.containsKey('id');
    final idRaw = hasIdField ? (frame.id ?? '') : null;

    if (!_initialized) {
      if (!hasIdField || idRaw == null || idRaw.isEmpty) {
        if (!requireFirstId) return null;
        return SseIncrementalIdMismatch(
          expectedId: 0,
          actualIdRaw: idRaw,
          actualIdParsed: null,
          reason: SseIncrementalIdMismatchReason.missingId,
          frame: frame,
        );
      }

      final parsed = int.tryParse(idRaw);
      if (parsed == null) {
        return SseIncrementalIdMismatch(
          expectedId: 0,
          actualIdRaw: idRaw,
          actualIdParsed: null,
          reason: SseIncrementalIdMismatchReason.nonNumericId,
          frame: frame,
        );
      }

      _initialized = true;
      _lastId = parsed;
      return null;
    }

    final expected = (_lastId ?? 0) + 1;
    if (!hasIdField || idRaw == null || idRaw.isEmpty) {
      return SseIncrementalIdMismatch(
        expectedId: expected,
        actualIdRaw: idRaw,
        actualIdParsed: null,
        reason: SseIncrementalIdMismatchReason.missingId,
        frame: frame,
      );
    }

    final parsed = int.tryParse(idRaw);
    if (parsed == null) {
      return SseIncrementalIdMismatch(
        expectedId: expected,
        actualIdRaw: idRaw,
        actualIdParsed: null,
        reason: SseIncrementalIdMismatchReason.nonNumericId,
        frame: frame,
      );
    }

    if (parsed != expected) {
      // Resync to the observed id so we can keep checking future increments.
      _lastId = parsed;
      return SseIncrementalIdMismatch(
        expectedId: expected,
        actualIdRaw: idRaw,
        actualIdParsed: parsed,
        reason: SseIncrementalIdMismatchReason.unexpectedId,
        frame: frame,
      );
    }

    _lastId = parsed;
    return null;
  }
}
