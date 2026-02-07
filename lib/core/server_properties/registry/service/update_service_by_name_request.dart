class UpdateServiceByNameRequest {
  late final String serviceName;
  String? serverAddress;
  String? username;
  String? password;
  String? cookies;

  UpdateServiceByNameRequest({required this.serviceName, this.serverAddress, this.username, this.password, this.cookies});
}
