import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaroKick Health Check (Web)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HealthCheckPage(),
    );
  }
}

class HealthCheckPage extends StatefulWidget {
  const HealthCheckPage({super.key});

  @override
  State<HealthCheckPage> createState() => _HealthCheckPageState();
}

class _HealthCheckPageState extends State<HealthCheckPage> {
  String _statusText = '아직 서버를 확인하지 않았어요.';
  bool _loading = false;

  Future<void> _checkHealth() async {
    setState(() {
      _loading = true;
      _statusText = '서버 확인 중...';
    });

    try {
      // 👉 FastAPI /health 엔드포인트
      final uri = Uri.parse('http://127.0.0.1:8000/health');
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final jsonBody = jsonDecode(utf8.decode(resp.bodyBytes));
        setState(() {
          _statusText = 'OK\n\n${jsonBody.toString()}';
        });
      } else {
        setState(() {
          _statusText = '에러: status ${resp.statusCode}\n${resp.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = '요청 실패: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BaroKick /health 테스트 (Web)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _checkHealth,
              child: Text(_loading ? '확인 중...' : '/health 호출하기'),
            ),
            const SizedBox(height: 16),
            const Text(
              '서버 응답:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _statusText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
