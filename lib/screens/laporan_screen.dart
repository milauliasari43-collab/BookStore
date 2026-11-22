import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _transaksiList = [];
  int _totalPendapatan = 0;

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  void _loadLaporan() async {
    final data = await _dbHelper.getTransaksi();
    int total = 0;
    for (var item in data) {
      total += (item['total_harga'] as int? ?? 0);
    }
    setState(() {
      _transaksiList = data;
      _totalPendapatan = total;
    });
  }

  void _hapusSemuaLaporan() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2432),
        title: const Text('Hapus Riwayat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Yakin ingin menghapus seluruh riwayat transaksi?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _dbHelper.clearTransaksi();
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadLaporan();
            },
            child: const Text('Hapus All', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2C),
        title: const Text('Laporan Penjualan', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.amber),
        actions: [
          if (_transaksiList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'Bersihkan Riwayat',
              onPressed: _hapusSemuaLaporan,
            ),
        ],
      ),
      body: Column(
        children: [
          // SUMMARY RINGKASAN PENDAPATAN
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF242C3D), Color(0xFF161C26)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL OMSET / PENDAPATAN', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('Total Penjualan Selesai', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Text(
                  'Rp $_totalPendapatan',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // LIST RIWAYAT TRANSAKSI
          Expanded(
            child: _transaksiList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada transaksi penjualan.',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transaksiList.length,
                    itemBuilder: (context, index) {
                      final item = _transaksiList[index];
                      return Card(
                        color: const Color(0xFF181F2C),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long, color: Colors.greenAccent),
                          ),
                          title: Text(
                            item['nama_barang'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${item['jumlah']} unit @ Rp ${item['total_harga']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Waktu: ${item['tanggal']}',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${item['total_harga']}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kembali: Rp ${item['kembalian']}',
                                style: const TextStyle(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}