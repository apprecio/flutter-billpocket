import 'dart:convert';

List<Installment> installmentFromJson(String str) => List<Installment>.from(json.decode(str).map((x) => Installment.fromJson(x)));

String installmentToJson(List<Installment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Installment {
  final double? commission;
  final double? minAmount;
  final int? value;

  Installment({
    this.commission,
    this.minAmount,
    this.value,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
    commission: json["commission"]?.toDouble(),
    minAmount: json["minAmount"]?.toDouble(),
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "commission": commission,
    "minAmount": minAmount,
    "value": value,
  };
}
