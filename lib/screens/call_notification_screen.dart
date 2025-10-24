import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient.dart';

class CallNotificationScreen extends StatefulWidget {
  final String patientId;
  final Patient? patient;

  const CallNotificationScreen({
    super.key,
    required this.patientId,
    this.patient,
  });

  @override
  State<CallNotificationScreen> createState() => _CallNotificationScreenState();
}

class _CallNotificationScreenState extends State<CallNotificationScreen> {
  CallInfo? _callInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCallInfo();
  }

  Future<void> _fetchCallInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // REST APIから診察室情報を取得
      // 実際のAPIが未実装の場合はモックデータを使用
      final callInfo = await ApiService.getCallInfo(widget.patientId);
      
      if (callInfo != null) {
        setState(() {
          _callInfo = callInfo;
          _isLoading = false;
        });
      } else {
        // モックデータを使用
        final mockInfo = ApiService.getMockCallInfo(widget.patientId);
        setState(() {
          _callInfo = mockInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診察室呼び出し'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'エラーが発生しました',
                          style: TextStyle(fontSize: 18, color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchCallInfo,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  )
                : _buildCallInfoView(),
      ),
    );
  }

  Widget _buildCallInfoView() {
    if (_callInfo == null) {
      return const Center(child: Text('情報が取得できませんでした'));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 患者情報
            if (widget.patient != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        child: Text(
                          widget.patient!.name.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.patient!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '患者ID: ${widget.patient!.patientId}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 診察室番号（大きく表示）
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.meeting_room,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '診察室番号',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _callInfo!.roomNumber,
                    style: const TextStyle(
                      fontSize: 96,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ステータス
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _callInfo!.status == 'ready' ? '準備完了' : _callInfo!.status,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // アクションボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle),
                label: const Text('確認しました'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
