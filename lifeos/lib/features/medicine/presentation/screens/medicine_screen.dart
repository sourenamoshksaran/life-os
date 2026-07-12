import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/models/base_entity.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/medicine_controller.dart';
import '../../domain/medicine.dart';

class MedicineScreen extends ConsumerWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(activeMedicinesProvider);
    final supplementsAsync = ref.watch(activeSupplementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine & Supplements')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSampleMedicine(ref),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        children: [
          const Text('Medicine',
              style: TextStyle(color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: LifeOSSpacing.sm),
          medicinesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (medicines) => Column(children: medicines.map(_itemCard).toList()),
          ),
          const SizedBox(height: LifeOSSpacing.lg),
          const Text('Supplements',
              style: TextStyle(color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: LifeOSSpacing.sm),
          supplementsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (supplements) => Column(
              children: supplements
                  .map((s) => _itemCardGeneric(s.name, s.dosage, s.scheduleTimes))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(Medicine m) => _itemCardGeneric(m.name, m.dosage, m.scheduleTimes);

  Widget _itemCardGeneric(String name, String dosage, List<String> times) {
    return Container(
      margin: const EdgeInsets.only(bottom: LifeOSSpacing.sm),
      padding: const EdgeInsets.all(LifeOSSpacing.md),
      decoration: BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: LifeOSColors.textPrimary)),
          Text('$dosage · ${times.join(", ")}',
              style: const TextStyle(color: LifeOSColors.textSecondary)),
        ],
      ),
    );
  }

  Future<void> _addSampleMedicine(WidgetRef ref) async {
    final now = DateTime.now();
    await ref.read(activeMedicinesProvider.notifier).add(Medicine(
          id: BaseEntity.newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Vitamin D',
          dosage: '1 tablet',
          scheduleTimes: const ['09:00'],
        ));
  }
}
