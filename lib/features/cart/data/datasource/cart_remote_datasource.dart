import 'package:nepabite/core/api/api_client.dart';
import 'package:nepabite/core/api/api_endpoints.dart';

class CartRemoteDatasource {
  final ApiClient apiClient;

  CartRemoteDatasource(this.apiClient);

  Future<void> addItem(String name, int quantity) async {
    await apiClient.post(
      ApiEndpoints.cart,
      data: {
        "name": name,
        "quantity": quantity
      },
    );
  }

  Future<List> getCart() async {
    final response = await apiClient.get(ApiEndpoints.cart);
    return response.data["cart"]["items"];
  }

  Future<void> removeItem(String name) async {
    await apiClient.delete("${ApiEndpoints.cart}/$name");
  }
}