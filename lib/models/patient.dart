import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  String patientId;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime registeredAt;

  @HiveField(3)
  String? fcmToken;

  Patient({
    required this.patientId,
    required this.name,
    required this.registeredAt,
    this.fcmToken,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] as String,
      name: json['name'] as String,
      registeredAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'name': name,
      'registered_at': registeredAt.toIso8601String(),
      'fcm_token': fcmToken,
    };
  }
}
