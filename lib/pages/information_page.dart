import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter, // ★ 이 부분 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'The Holy Bible\n'
                'New Testament\n'
                'Colloquial Central Tibetan Version\n'
                'Lhasa Dialect, 2025\n'
                '(CCTV)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2025 ASIA PUBLISHING HOUSE\n'
                'ISBN 979-11-989197-1-7',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 40),
              const Text(
                'Bibliographic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Scan the QR code below to view the bibliographic record in the National Library of Korea.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset('assets/nlk_qr.png', width: 130),
            ],
          ),
        ),
      ),
    );
  }
}
