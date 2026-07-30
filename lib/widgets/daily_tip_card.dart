import 'package:flutter/material.dart';

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  static const List<String> _tips = [
    'BISINDO dan SIBI adalah dua sistem bahasa isyarat berbeda yang '
        'dipakai di Indonesia.',
    'Ekspresi wajah adalah bagian penting dari bahasa isyarat, bukan '
        'cuma gerakan tangan.',
    'Bahasa isyarat punya tata bahasa sendiri yang berbeda dari bahasa '
        'lisan/tulisan.',
    'Konsistensi latihan setiap hari membantu memori otot mengingat '
        'gerakan lebih cepat.',
  ];

  String get _todayTip {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFE67E22), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Hari Ini',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF7A4A14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayTip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A4A14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}