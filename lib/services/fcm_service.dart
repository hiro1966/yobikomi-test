import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // FCMトークンのコールバック
  static Function(String)? onTokenReceived;
  
  // 通知受信時のコールバック（患者ID）
  static Function(String)? onNotificationReceived;

  // FCMの初期化
  static Future<void> init() async {
    // 通知権限のリクエスト
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('✅ FCM権限ステータス: ${settings.authorizationStatus}');
    }

    // FCMトークンの取得
    String? token = await _messaging.getToken();
    if (token != null) {
      if (kDebugMode) {
        debugPrint('✅ FCMトークン: $token');
      }
      onTokenReceived?.call(token);
    }

    // トークン更新のリスナー
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint('🔄 FCMトークン更新: $newToken');
      }
      onTokenReceived?.call(newToken);
    });

    // フォアグラウンドでの通知受信
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📬 フォアグラウンド通知受信: ${message.notification?.title}');
        debugPrint('📬 データ: ${message.data}');
      }
      
      // patient_idをデータから取得
      if (message.data.containsKey('patient_id')) {
        String patientId = message.data['patient_id'];
        onNotificationReceived?.call(patientId);
      }
    });

    // バックグラウンドでの通知タップ
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📬 バックグラウンド通知タップ: ${message.notification?.title}');
      }
      
      if (message.data.containsKey('patient_id')) {
        String patientId = message.data['patient_id'];
        onNotificationReceived?.call(patientId);
      }
    });
  }

  // AWS SNSへのトークン登録（実装例）
  static Future<void> registerToAws(String fcmToken, List<String> patientIds) async {
    // TODO: AWSのエンドポイントにFCMトークンと患者IDを送信
    // 例: POST https://your-api.amazonaws.com/register
    // Body: { "fcm_token": fcmToken, "patient_ids": patientIds }
    
    if (kDebugMode) {
      debugPrint('📤 AWS登録リクエスト:');
      debugPrint('  FCMトークン: $fcmToken');
      debugPrint('  患者ID: $patientIds');
    }
  }

  // FCMトークンの取得
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

// バックグラウンドメッセージハンドラ（トップレベル関数）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('📬 バックグラウンドメッセージ: ${message.messageId}');
  }
}
