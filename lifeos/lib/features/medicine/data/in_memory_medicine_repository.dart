import '../domain/medicine.dart';
import '../domain/medicine_repository.dart';

/// TODO(implementation): replace with IsarMedicineRepository.
class InMemoryMedicineRepository implements MedicineRepository {
  final Map<String, Medicine> _medicines = {};
  final Map<String, MedicineLog> _logs = {};

  @override
  Future<List<Medicine>> getActive() async =>
      _medicines.values.where((m) => m.active && !m.isDeleted).toList();

  @override
  Future<void> saveMedicine(Medicine medicine) async => _medicines[medicine.id] = medicine;

  @override
  Future<List<MedicineLog>> getLogsByDate(String localDate) async =>
      _logs.values.where((l) => l.localDate == localDate).toList();

  @override
  Future<void> saveLog(MedicineLog log) async => _logs[log.id] = log;
}

/// TODO(implementation): replace with IsarSupplementRepository.
class InMemorySupplementRepository implements SupplementRepository {
  final Map<String, Supplement> _supplements = {};
  final Map<String, SupplementLog> _logs = {};

  @override
  Future<List<Supplement>> getActive() async =>
      _supplements.values.where((s) => s.active && !s.isDeleted).toList();

  @override
  Future<void> saveSupplement(Supplement supplement) async =>
      _supplements[supplement.id] = supplement;

  @override
  Future<List<SupplementLog>> getLogsByDate(String localDate) async =>
      _logs.values.where((l) => l.localDate == localDate).toList();

  @override
  Future<void> saveLog(SupplementLog log) async => _logs[log.id] = log;
}
