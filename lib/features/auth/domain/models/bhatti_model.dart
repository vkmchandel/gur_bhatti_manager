class BhattiModel {
  final String id;
  final String ownerName;
  final String bhattiName;
  final String mobileNumber;
  final String? pincode;
  final String? state;
  final String? district;
  final String? village;
  final double? latitude;
  final double? longitude;
  final double? defaultRate;

  BhattiModel({
    required this.id,
    required this.ownerName,
    required this.bhattiName,
    required this.mobileNumber,
    this.pincode,
    this.state,
    this.district,
    this.village,
    this.latitude,
    this.longitude,
    this.defaultRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerName': ownerName,
      'bhattiName': bhattiName,
      'mobileNumber': mobileNumber,
      'pincode': pincode,
      'state': state,
      'district': district,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'defaultRate': defaultRate,
    };
  }

  factory BhattiModel.fromJson(Map<String, dynamic> json) {
    return BhattiModel(
      id: json['id'],
      ownerName: json['ownerName'],
      bhattiName: json['bhattiName'],
      mobileNumber: json['mobileNumber'],
      pincode: json['pincode'],
      state: json['state'],
      district: json['district'],
      village: json['village'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      defaultRate: json['defaultRate']?.toDouble(),
    );
  }
}
