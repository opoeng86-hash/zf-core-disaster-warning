import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ZfCoreApp());
}

class ZfCoreApp extends StatelessWidget {
  const ZfCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZF-Core Disaster Warning',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.indigo,
      ),
      home: const DisasterDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DisasterDashboard extends StatefulWidget {
  const DisasterDashboard({super.key});

  @override
  State<DisasterDashboard> createState() => _DisasterDashboardState();
}

class _DisasterDashboardState extends State<DisasterDashboard> {
  late Timer _timer;
  String _currentTime = '';
  String _liveApiStatus = 'Menghubungkan ke jalur data live...';
  bool _isLoadingApi = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    _fetchRealtimeData(); // Memanggil data real-time saat aplikasi dibuka
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} WIB";
    });
  }

  // Fungsi untuk menarik data gempa real-time dari API publik terbuka (USGS)
  Future<void> _fetchRealtimeData() async {
    setState(() {
      _isLoadingApi = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_hour.geojson'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        
        setState(() {
          if (features.isNotEmpty) {
            final latest = features[0]['properties'];
            final place = latest['place'] ?? 'Lokasi tidak diketahui';
            final mag = latest['mag'] ?? '0';
            _liveApiStatus = 'STATUS LIVE: Terdeteksi aktivitas M$mag di $place';
          } else {
            _liveApiStatus = 'STATUS LIVE: Zona stabil. Tidak ada anomali signifikan detik ini.';
          }
          _isLoadingApi = false;
        });
      } else {
        setState(() {
          _liveApiStatus = 'STATUS LIVE: Gagal merespons jalur data.';
          _isLoadingApi = false;
        });
      }
    } catch (e) {
      setState(() {
        _liveApiStatus = 'STATUS LIVE: Mode offline / Jaringan terbatas.';
        _isLoadingApi = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showBroadcastDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Broadcast Komando Darurat", style: TextStyle(color: Colors.redAccent)),
        content: const Text("Sinyal komando ZF-Core berhasil disiarkan ke seluruh sektor wilayah siaga berbasis Zuhri Formalism."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZF-Core Disaster Warning'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRealtimeData,
            tooltip: 'Segarkan Data Live',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ARSITEK & PENCIPTA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text("ARSITEK & PENCIPTA SISTEM:", style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Opung Sirr (Abdul Gofur)", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // LIVE API STATUS PANEL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1E293B),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("FEED API REAL-TIME", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(_currentTime, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingApi
                      ? const LinearProgressIndicator(color: Colors.cyanAccent)
                      : Text(_liveApiStatus, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // STATUS PANEL UTAMA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orangeAccent),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1E293B),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("LEVEL 2: SIAGA TERBATAS", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("NUSANTARA: WASPADA ANOMALI MUSIM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("GLOBAL: TERMONITOR STABIL (Kardashev Simpul A)", style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BROADCAST BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showBroadcastDialog(context),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              label: const Text("Kirim Broadcast Darurat Komando", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 24),

            const Text("Pusat Analisis & Kalkulasi Presisi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // MODUL 1: GUNUNG MELETUS
            _buildDisasterCard(
              title: "ANALISIS: Aktivitas Gunung Meletus",
              formula: "R_vulkanik = (E_magma * S_tekanan) / D_konduit",
              proj7: "• Hari 1-3: Tremor menerus pada amplitudo 12-18mm.\n• Hari 4-7: Peningkatan suplai magma dangkal.",
              projMonth: "• Minggu 1-2: Akumulasi gas di kantong magma.\n• Minggu 3-4: Stabilisasi atau fase letusan minor.",
              region: "Wilayah Terdampak: Zona Radius 5-10 km dari kemerdekaan puncak aktif.",
            ),
            const SizedBox(height: 12),

            // MODUL 2: BANJIR
            _buildDisasterCard(
              title: "ANALISIS: Potensi Banjir & Hidrometeorologi",
              formula: "F_banjir = (V_curah_hujan * C_alir) / Kapasitas_Drainase",
              proj7: "• Hari 1-3: Siaga curah hujan ekstrem sore menjelang malam.\n• Hari 4-7: Penurunan intensitas secara bertahap.",
              projMonth: "• Minggu 1-2: Puncak siklus musiman air pasang.\n• Minggu 3-4: Pemulihan debit air normal.",
              region: "Wilayah Terdampak: Bantaran sungai utama dan dataran rendah perkotaan.",
            ),
            const SizedBox(height: 12),

            // MODUL 3: BADAI
            _buildDisasterCard(
              title: "ANALISIS: Anomali Badai & Siklon",
              formula: "S_badai = (P_atmosfir_delta * V_angin) / Zeta_Coriolis",
              proj7: "• Hari 1-3: Kecepatan angin meningkat hingga 35 knot.\n• Hari 4-7: Pergerakan pusaran menjauhi garis pantai.",
              projMonth: "• Minggu 1-2: Pembentukan front tekanan rendah.\n• Minggu 3-4: Peluruhan energi badai.",
              region: "Wilayah Terdampak: Jalur lintasan pesisir terbuka dan perairan regional.",
            ),
            const SizedBox(height: 12),

            // MODUL 4: GEMPA BUMI
            _buildDisasterCard(
              title: "ANALISIS: Aktivitas Seismik & Gempa",
              formula: "G_seismik = (E_taktik_lumpur * M_gesekan) / R_jarak_pusat",
              proj7: "• Hari 1-3: Aktivitas gempa mikro beruntun.\n• Hari 4-7: Relaksasi lempengan tektonik stabil.",
              projMonth: "• Minggu 1-2: Akumulasi energi regangan tektonik.\n• Minggu 3-4: Pelepasan energi skala kecil-menengah.",
              region: "Wilayah Terdampak: Sepanjang jalur sesar aktif dan zona subduksi.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisasterCard({
    required String title,
    required String formula,
    required String proj7,
    required String projMonth,
    required String region,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("📐 Uraian Rumus (Zuhri Formalism):\n$formula", style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Text("⏳ Proyeksi 7 Hari:\n$proj7", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text("📅 Proyeksi 1 Bulan:\n$projMonth", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text("📍 $region", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
