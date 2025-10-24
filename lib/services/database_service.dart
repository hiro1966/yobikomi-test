import 'package:hive_flutter/hive_flutter.dart';
import '../models/patient.dart';

class DatabaseService {
  static const String _patientsBoxName = 'patients';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PatientAdapter());
    await Hive.openBox<Patient>(_patientsBoxName);
  }

  static Box<Patient> get _patientsBox => Hive.box<Patient>(_patientsBoxName);

  // 患者を追加
  static Future<void> addPatient(Patient patient) async {
    await _patientsBox.put(patient.patientId, patient);
  }

  // 全患者を取得
  static List<Patient> getAllPatients() {
    return _patientsBox.values.toList();
  }

  // 患者IDで取得
  static Patient? getPatient(String patientId) {
    return _patientsBox.get(patientId);
  }

  // 患者を削除
  static Future<void> deletePatient(String patientId) async {
    await _patientsBox.delete(patientId);
  }

  // 全患者を削除
  static Future<void> clearAllPatients() async {
    await _patientsBox.clear();
  }

  // FCMトークンを更新
  static Future<void> updateFcmToken(String patientId, String token) async {
    final patient = getPatient(patientId);
    if (patient != null) {
      patient.fcmToken = token;
      await patient.save();
    }
  }
}
