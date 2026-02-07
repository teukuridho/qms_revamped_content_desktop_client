enum ProcessStateEnum {
  none,
  loading,
  success,
  failed
}
class ProcessState {
  final ProcessStateEnum state;
  final String? errorMessage;

  ProcessState({required this.state, this.errorMessage});
}