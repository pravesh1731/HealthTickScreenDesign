import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The arched "CHECK POINT" door between two status sections.
class CheckpointGate extends StatelessWidget {
  const CheckpointGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 110,
        decoration: const BoxDecoration(
          color: Color(0xFFB9B9B9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB4714F), AppColors.checkpoint],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
          ),
          alignment: const Alignment(0, -0.2),
          child: const Text(
            'CHECK\nPOINT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
