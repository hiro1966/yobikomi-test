# 診察室呼び込みアプリ（Hospital Call System）

病院の診察室呼び込みシステム用のFlutterアプリケーションです。

## 🏥 機能

### 1. QRコード患者登録
- JSON形式のQRコードを読み取り
- 複数患者の登録に対応
- ローカルDB（Hive）への自動保存

**QRコードフォーマット例**:
```json
{
  "patient_id": "12345",
  "name": "山田太郎"
}
```

### 2. Firebase Cloud Messaging (FCM)
- Push通知の受信
- AWS SNS/Pinpointとの連携準備
- フォアグラウンド/バックグラウンド対応

### 3. REST API連携
- 患者IDをキーに診察情報を取得
- 診察室番号の表示
- エラーハンドリング実装

### 4. 診察室番号表示
- 大きく見やすい表示
- 患者情報の確認
- ステータス表示

## 📱 対応プラットフォーム

- ✅ Android
- ✅ iOS（要macOS環境）
- ✅ Web

## 🚀 セットアップ

### 必要な環境
- Flutter 3.35.4以上
- Dart 3.9.2以上

### インストール手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/hiro1966/yobikomi-test.git
cd yobikomi-test

# 2. 依存関係をインストール
flutter pub get

# 3. Hiveアダプターを生成
dart run build_runner build --delete-conflicting-outputs

# 4. アプリを実行
flutter run
```

## 🔧 Firebase設定（必須）

### Android用
1. Firebase Consoleで新しいプロジェクトを作成
2. Androidアプリを追加
3. `google-services.json`をダウンロード
4. `android/app/google-services.json`に配置

### iOS用
1. Firebase ConsoleでiOSアプリを追加
2. `GoogleService-Info.plist`をダウンロード
3. Xcodeで`ios/Runner/`に追加

## 📦 ビルド

### Webビルド
```bash
flutter build web --release
```

### Androidビルド
```bash
flutter build apk --release
# 出力: build/app/outputs/flutter-apk/app-release.apk
```

### iOSビルド（macOS環境）
```bash
# 1. iOS依存関係のインストール
cd ios
pod install
cd ..

# 2. ビルド実行
flutter build ipa --release
```

## 🔌 REST API設定

`lib/services/api_service.dart`のエンドポイントURLを変更：

```dart
static const String baseUrl = 'https://your-api.example.com/api';
```

**APIエンドポイント仕様**:
```
GET /api/patient/{patient_id}/call-info

Response:
{
  "patient_id": "12345",
  "room_number": "3",
  "status": "ready",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 📂 プロジェクト構成

```
lib/
├── main.dart                            # アプリエントリーポイント
├── models/
│   └── patient.dart                     # 患者データモデル
├── services/
│   ├── database_service.dart            # Hiveデータベース操作
│   ├── fcm_service.dart                 # Firebase Cloud Messaging
│   └── api_service.dart                 # REST API通信
├── providers/
│   └── patient_provider.dart            # 患者データ管理（Provider）
└── screens/
    ├── patient_registration_screen.dart # QRコード登録画面
    ├── patient_list_screen.dart         # 患者リスト画面
    └── call_notification_screen.dart    # 診察室呼び出し画面
```

## 🧪 テスト

現在はモックデータで動作確認が可能です。

実際のREST APIを実装後、本番環境での動作確認を行ってください。

## 📝 TODO

- [ ] Firebase設定ファイルの追加
- [ ] REST APIエンドポイントの実装
- [ ] AWS Push通知の設定
- [ ] 実機でのテスト（iOS/Android）

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 👤 作成者

hiro1966

## 🔗 リンク

- [リポジトリ](https://github.com/hiro1966/yobikomi-test)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
