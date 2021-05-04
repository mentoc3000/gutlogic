import 'package:flutter/material.dart';

class IrritantAssessment extends StatelessWidget {
  final String name;
  final int sensitivity;

  const IrritantAssessment({required this.name, required this.sensitivity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontStyle: FontStyle.italic)),
          Container(
              // padding: const EdgeInsets.only(top: 10.0),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                  ),
                  const Text('1/4 Cup')
                ],
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                  ),
                  const Text('1/2 Cup')
                ],
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 30.0,
                    height: 30.0,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const Text('1 Cup')
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
