import 'package:flutter/material.dart';

Widget noConnectionPage() {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_wifi_off,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tidak ada koneksi internet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pastikan koneksi internet Anda aktif.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
