class StoreAddress {
  int? id;
  String? name;
  String? address;
  String? latitude;
  String? longitude;
  String? createdAt;

  StoreAddress(
      {this.id,
      this.name,
      this.address,
      this.latitude,
      this.longitude,
      this.createdAt});

  StoreAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    return data;
  }
}
