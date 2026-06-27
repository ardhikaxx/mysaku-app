import 'package:flutter_riverpod/flutter_riverpod.dart';

final customIncomeCategoriesProvider =
    StateProvider<Map<String, String>>((ref) => {
          'salary': 'Gaji',
          'freelance': 'Freelance',
          'investment': 'Investasi',
          'bonus': 'Bonus',
          'gift': 'Hadiah / Pemberian',
          'other_income': 'Lainnya',
        });

final customExpenseCategoriesProvider =
    StateProvider<Map<String, String>>((ref) => {
          'food': 'Makan & Minum',
          'transport': 'Transportasi',
          'bills': 'Tagihan',
          'shopping': 'Belanja',
          'health': 'Kesehatan',
          'education': 'Pendidikan',
          'entertainment': 'Hiburan',
          'savings': 'Tabungan / Investasi',
          'other_expense': 'Lainnya',
        });
