import '../domain/medicine.dart';
import '../domain/medicine_repository.dart';

/// Applies the grace-window rule from RFC-011 §7: a dose with no user
/// action within `gracePeriod` (default 2h, configurable in Settings —
/// RFC-014 §5) auto-transitions Scheduled -> Missed rather than being
/// silently dropped, so a device that was off when the reminder fired
/// still surfaces the missed dose in adherence history.
class ApplyMedicineGraceWindowUseCase {
  ApplyMedicineGraceWindowUseCase(this._repository);
  final MedicineRepository _repository;

  Future<void> call(String localDate, {Duration gracePeriod = const Duration(hours: 2)}) async {
    final logs = await _repository.getLogsByDate(localDate);
    final now = DateTime.now();
    for (final log in logs) {
      if (log.status == DoseStatus.scheduled && now.difference(log.scheduledTime) > gracePeriod) {
        await _repository.saveLog(log.copyWith(status: DoseStatus.missed));
      }
    }
  }
}

class ApplySupplementGraceWindowUseCase {
  ApplySupplementGraceWindowUseCase(this._repository);
  final SupplementRepository _repository;

  Future<void> call(String localDate, {Duration gracePeriod = const Duration(hours: 2)}) async {
    final logs = await _repository.getLogsByDate(localDate);
    final now = DateTime.now();
    for (final log in logs) {
      if (log.status == DoseStatus.scheduled && now.difference(log.scheduledTime) > gracePeriod) {
        await _repository.saveLog(log.copyWith(status: DoseStatus.missed));
      }
    }
  }
}
