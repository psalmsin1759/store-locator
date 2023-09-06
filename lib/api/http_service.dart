import 'dart:convert';
import 'package:http/http.dart';

import '../model/store_address.dart';

class HttpService {
  final String baseUrl = 'http://10.0.2.2/api';

  Future<List<StoreAddress>> getStoreAddresses() async {
    final response = await get(Uri.parse('$baseUrl/store-locations'), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<StoreAddress> storeAddressList = data
          .map((json) => StoreAddress(
                id: json['id'],
                name: json['name'],
                address: json['address'],
                latitude: json['latitude'],
                longitude: json['longitude'],
                createdAt: json['created_at'],
              ))
          .toList();
      return storeAddressList;
    } else {
      throw Exception('Failed to load store address');
    }
  }
}
