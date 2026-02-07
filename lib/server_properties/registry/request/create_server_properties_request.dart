class CreateServerPropertiesRequest {
  late final String serviceName;
  late final String serverAddress;
  late final String username;
  late final String password;

  CreateServerPropertiesRequest({
    required this.serviceName,
    required this.serverAddress,
    required this.username,
    required this.password,
  });
}
