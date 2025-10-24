import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/database_service.dart';
import 'services/fcm_service.dart';
import 'providers/patient_provider.dart';
import 'screens/patient_list_screen.dart';
import 'screens/call_notification_screen.dart';

// バックグラウンドメッセージハンドラ
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hiveの初期化
  await DatabaseService.init();
  
  // Firebaseの初期化は省略（google-services.jsonがない場合）
  // await Firebase.initializeApp();
  
  // FCMバックグラウンドハンドラの設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientProvider(),
      child: MaterialApp(
        title: '診察室呼び込みアプリ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFcm();
  }

  Future<void> _initializeFcm() async {
    // FCMの初期化
    await FcmService.init();
    
    // 通知受信時の処理
    FcmService.onNotificationReceived = (patientId) {
      // 患者情報を取得
      final provider = Provider.of<PatientProvider>(context, listen: false);
      final patient = provider.getPatient(patientId);
      
      // 診察室呼び出し画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallNotificationScreen(
            patientId: patientId,
            patient: patient,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アプリアイコン
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // アプリタイトル
                  const Text(
                    '診察室呼び込みアプリ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'QRコードで患者登録\nPush通知で診察室へご案内',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // 機能カード
                  _buildFeatureCard(
                    icon: Icons.qr_code_scanner,
                    title: 'QRコード登録',
                    description: '患者情報をQRコードから読み取り',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Push通知',
                    description: '診察準備完了をリアルタイムでお知らせ',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.meeting_room,
                    title: '診察室案内',
                    description: '診察室番号を大きく表示',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 48),
                  
                  // メインボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 28),
                      label: const Text(
                        '患者登録を開始',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // FCMステータス表示
                  Consumer<PatientProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: provider.fcmToken != null
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: provider.fcmToken != null
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.fcmToken != null
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 16,
                              color: provider.fcmToken != null
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.fcmToken != null
                                  ? 'Push通知: 有効'
                                  : 'Push通知: 初期化中...',
                              style: TextStyle(
                                fontSize: 12,
                                color: provider.fcmToken != null
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
