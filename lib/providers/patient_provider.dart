import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/fcm_service.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  String? _fcmToken;

  List<Patient> get patients => _patients;
  String? get fcmToken => _fcmToken;

  PatientProvider() {
    _loadPatients();
    _initFcm();
  }

  // 患者一覧の読み込み
  void _loadPatients() {
    _patients = DatabaseService.getAllPatients();
    notifyListeners();
  }

  // FCMの初期化
  void _initFcm() {
    FcmService.onTokenReceived = (token) {
      _fcmToken = token;
      _registerToAws();
      notifyListeners();
    };
  }

  // AWSへの登録
  Future<void> _registerToAws() async {
    if (_fcmToken != null && _patients.isNotEmpty) {
      final patientIds = _patients.map((p) => p.patientId).toList();
      await FcmService.registerToAws(_fcmToken!, patientIds);
    }
  }

  // 患者の追加
  Future<void> addPatient(Patient patient) async {
    await DatabaseService.addPatient(patient);
    _loadPatients();
    
    // AWSに再登録
    await _registerToAws();
  }

  // 患者の削除
  Future<void> deletePatient(String patientId) async {
    await DatabaseService.deletePatient(patientId);
    _loadPatients();
    
    // AWSに再登録
    await _registerToAws();
  }

  // 全患者の削除
  Future<void> clearAllPatients() async {
    await DatabaseService.clearAllPatients();
    _loadPatients();
  }

  // 患者の取得
  Patient? getPatient(String patientId) {
    try {
      return _patients.firstWhere((p) => p.patientId == patientId);
    } catch (e) {
      return null;
    }
  }
}
