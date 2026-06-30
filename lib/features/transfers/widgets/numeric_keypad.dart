import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('clear', icon: Icons.clear),
              _buildKey('0'),
              _buildKey('backspace', icon: Icons.backspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, {IconData? icon}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onKeyPressed(value),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: icon != null ? Colors.grey.shade200 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: icon != null
              ? Icon(icon, color: Colors.grey.shade800)
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}