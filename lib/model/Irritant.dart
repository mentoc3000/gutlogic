class Irritant {
  String name;
  List<String> serving;
  List<Sensitivity> sensitivity;

  Irritant({
    this.name,
    this.serving,
    this.sensitivity
  });

  factory Irritant.fromJson(Map<String, dynamic> json) {
    return new Irritant(
      name: json['name'],
      serving: json['serving'],
      sensitivity: json['sensitivity']
    );
  }

}

enum Sensitivity {
  low,
  medium,
  high
}