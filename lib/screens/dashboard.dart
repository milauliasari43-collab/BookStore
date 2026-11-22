import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import 'kasir_screen.dart';
import 'inventaris_screen.dart';
import 'laporan_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _dbHelper = DBHelper();
  int _totalJenisBarang = 0;
  int _totalStokBarang = 0;
  int _totalPendapatan = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    final data = await _dbHelper.getBarang();
    final transaksi = await _dbHelper.getTransaksi();

    int jenis = data.length;
    int totalStok = 0;
    int pendapatan = 0;

    for (var item in data) {
      totalStok += (item['stok'] as int? ?? 0);
    }

    for (var t in transaksi) {
      pendapatan += (t['total_harga'] as int? ?? 0);
    }

    setState(() {
      _totalJenisBarang = jenis;
      _totalStokBarang = totalStok;
      _totalPendapatan = pendapatan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF181F2C),
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Dashboard Toko Buku',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Keluar / Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.amber,
        backgroundColor: const Color(0xFF181F2C),
        onRefresh: () async {
          _loadDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF242C3D), Color(0xFF161C26)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang, Kasir!',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sistem Kasir & Inventaris Toko Buku siap digunakan. Stok akan terpotong dan tercatat otomatis di laporan.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Omset: Rp $_totalPendapatan',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'INFORMASI STOK & INVENTARIS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Jenis Buku',
                      value: '$_totalJenisBarang',
                      icon: Icons.menu_book,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Unit Stok',
                      value: '$_totalStokBarang',
                      icon: Icons.inventory_2,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Text(
                'MENU UTAMA',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Transaksi Kasir',
                    subtitle: 'POS & Hitung Otomatis',
                    icon: Icons.point_of_sale_rounded,
                    color: Colors.amber,
                    destination: const KasirScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Kelola Barang',
                    subtitle: 'Tambah / Edit Stok',
                    icon: Icons.edit_note_rounded,
                    color: Colors.blueAccent,
                    destination: const InventarisScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Laporan Penjualan',
                    subtitle: 'Riwayat & Omset',
                    icon: Icons.bar_chart_rounded,
                    color: Colors.greenAccent,
                    destination: const LaporanScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Widget destination}) {
    return Material(
      color: const Color(0xFF181F2C),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
          _loadDashboardData();
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}