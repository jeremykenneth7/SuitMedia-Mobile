import 'package:suitmedia1/API/base_network.dart';

class ApiDataSource {
  static ApiDataSource instance = ApiDataSource();

  Future<Map<String, dynamic>> loadUsers({int page = 1, int perPage = 10}) {
    return BaseNetwork.get("users?page=$page&per_page=$perPage");
  }

  Future<Map<String, dynamic>> loadDetailUser(int idDiterima) {
    String id = idDiterima.toString();
    return BaseNetwork.get("users/$id");
  }
}
