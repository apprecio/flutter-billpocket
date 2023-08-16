// To parse this JSON data, do
//
//     final reader = readerFromJson(jsonString);

import 'dart:convert';

Reader readerFromJson(String str) => Reader.fromJson(json.decode(str));

String readerToJson(Reader data) => json.encode(data.toJson());

class Reader {
  String name;
  String macAddress;
  int type;

  Reader({
    required this.name,
    required this.macAddress,
    required this.type,
  });

  factory Reader.fromJson(Map<String, dynamic> json) => Reader(
    name: json["name"],
    macAddress: json["macAddress"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "macAddress": macAddress,
    "type": type,
  };

  @override
  String toString() {
    return 'Reader{name: $name, macAddress: $macAddress, type: $type}';
  }
}
