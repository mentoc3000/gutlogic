class Irritant {
  String name;
  List<String> serving;
  List<Sensitivity> sensitivity;

  Irritant(
    this.name,
    this.serving,
    this.sensitivity
  );

}

enum Sensitivity {
  low,
  medium,
  high
}