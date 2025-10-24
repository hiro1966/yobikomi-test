import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // TODO: 実際のAPIエンドポイントに変更してください
  static const String baseUrl = 'https://your-api.example.com/api';
  
  // 診察情報の取得
  static Future<CallInfo?> getCallInfo(String patientId) async {
    try {
      final url = Uri.parse('$baseUrl/patient/$patientId/call-info');
      
      if (kDebugMode) {
        debugPrint('🌐 API呼び出し: $url');
      }
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          debugPrint('✅ API応答: $data');
        }
        return CallInfo.fromJson(data);
      } else {
        if (kDebugMode) {
          debugPrint('❌ APIエラー: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ API例外: $e');
      }
      return null;
    }
  }

  // モックデータ（開発用）
  static CallInfo getMockCallInfo(String patientId) {
    // テスト用のモックデータを返す
    return CallInfo(
      patientId: patientId,
      roomNumber: '${(int.parse(patientId.hashCode.toString().substring(0, 1)) % 5) + 1}',
      status: 'ready',
      timestamp: DateTime.now(),
    );
  }
}

// 診察情報モデル
class CallInfo {
  final String patientId;
  final String roomNumber;
  final String status;
  final DateTime timestamp;

  CallInfo({
    required this.patientId,
    required this.roomNumber,
    required this.status,
    required this.timestamp,
  });

  factory CallInfo.fromJson(Map<String, dynamic> json) {
    return CallInfo(
      patientId: json['patient_id'] as String,
      roomNumber: json['room_number'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'room_number': roomNumber,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
