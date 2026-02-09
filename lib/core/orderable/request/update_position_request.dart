class UpdatePositionRequest {
  late final RecordWithPosition currentRecord;
  late final List<RecordWithPosition> affectedRecords;

  UpdatePositionRequest({required this.currentRecord, required this.affectedRecords});
}

class RecordWithPosition {
  late final int id;
  late final int position;

  RecordWithPosition({required this.id, required this.position});
}