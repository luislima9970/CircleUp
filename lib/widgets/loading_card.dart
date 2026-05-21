import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2A8CFF),
        ),
      ),
    );
  }
}