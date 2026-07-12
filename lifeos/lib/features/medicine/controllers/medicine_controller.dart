import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/date_manager.dart';
import '../data/in_memory_medicine_repository.dart';
import '../domain/grace_window_use_cases.dart';
import '../domain/medicine.dart';
import '../domain/medicine_repository.dart';

const _dateManager = DateManager();

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return InMemoryMedicineRepository();
});

final supplementRepositoryProvider = Provider<SupplementRepository>((ref) {
  return InMemorySupplementRepository();
});

final applyMedicineGraceWindowProvider = Provider((ref) {
  return ApplyMedicineGraceWindowUseCase(ref.watch(medicineRepositoryProvider));
});

final applySupplementGraceWindowProvider = Provider((ref) {
  return ApplySupplementGraceWindowUseCase(ref.watch(supplementRepositoryProvider));
});

final activeMedicinesProvider =
    AsyncNotifierProvider<ActiveMedicinesNotifier, List<Medicine>>(ActiveMedicinesNotifier.new);

class ActiveMedicinesNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    // Apply grace-window on every load (RFC-011 §7) so missed doses
    // surface even if the app wasn't open when they were due.
    await ref.read(applyMedicineGraceWindowProvider).call(_dateManager.today());
    return ref.watch(medicineRepositoryProvider).getActive();
  }

  Future<void> add(Medicine medicine) async {
    await ref.read(medicineRepositoryProvider).saveMedicine(medicine);
    ref.invalidateSelf();
    await future;
  }
}

final activeSupplementsProvider =
    AsyncNotifierProvider<ActiveSupplementsNotifier, List<Supplement>>(
        ActiveSupplementsNotifier.new);

class ActiveSupplementsNotifier extends AsyncNotifier<List<Supplement>> {
  @override
  Future<List<Supplement>> build() async {
    await ref.read(applySupplementGraceWindowProvider).call(_dateManager.today());
    return ref.watch(supplementRepositoryProvider).getActive();
  }

  Future<void> add(Supplement supplement) async {
    await ref.read(supplementRepositoryProvider).saveSupplement(supplement);
    ref.invalidateSelf();
    await future;
  }
}

/// Records a Taken/Skipped action — mirrors the notification action-button
/// write path in RFC-006 §5 (a real notification action writes here
/// without opening the app; the in-app button reuses the same call).
final recordMedicineDoseProvider = Provider((ref) {
  return (MedicineLog log, DoseStatus status) =>
      ref.read(medicineRepositoryProvider).saveLog(log.copyWith(status: status, actualTime: DateTime.now()));
});
