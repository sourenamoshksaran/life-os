import 'medicine.dart';

abstract class MedicineRepository {
  Future<List<Medicine>> getActive();
  Future<void> saveMedicine(Medicine medicine);
  Future<List<MedicineLog>> getLogsByDate(String localDate);
  Future<void> saveLog(MedicineLog log);
}

abstract class SupplementRepository {
  Future<List<Supplement>> getActive();
  Future<void> saveSupplement(Supplement supplement);
  Future<List<SupplementLog>> getLogsByDate(String localDate);
  Future<void> saveLog(SupplementLog log);
}
