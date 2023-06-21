import 'package:flutter/material.dart';

class CasesBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descriptionText;
  const CasesBox({
    super.key,
    required this.color,
    required this.headerText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 5,
      ),
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15).copyWith(left: 10),
        child: Column(children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              headerText,
              style: const TextStyle(
                fontFamily: 'Chinzel',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              descriptionText,
              style: const TextStyle(
                fontFamily: 'Chinzel',
                color: Colors.white,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
