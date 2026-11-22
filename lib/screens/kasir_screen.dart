import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _barangList = [];

  int? _selectedBarangId;
  Map<String, dynamic>? _selectedBarang;

  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _bayarController = TextEditingController();

  int _totalHarga = 0;
  int _kembalian = 0;

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  void _loadBarang() async {
    final data = await _dbHelper.getBarang();
    setState(() {
      _barangList = data;
      _selectedBarangId = null;
      _selectedBarang = null;
      _totalHarga = 0;
      _kembalian = 0;
      _bayarController.clear();
      _qtyController.text = '1';
    });
  }

  void _hitungTotal() {
    if (_selectedBarang != null) {
      int harga = _selectedBarang!['harga'] ?? 0;
      int qty = int.tryParse(_qtyController.text) ?? 0;
      setState(() {
        _totalHarga = harga * qty;
        _hitungKembalian();
      });
    }
  }

  void _hitungKembalian() {
    int bayar = int.tryParse(_bayarController.text) ?? 0;
    setState(() {
      if (bayar >= _totalHarga) {
        _kembalian = bayar - _totalHarga;
      } else {
        _kembalian = 0;
      }
    });
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _prosesBayar() async {
    if (_selectedBarang == null) {
      _showNotification('Silakan pilih buku/barang terlebih dahulu!', isError: true);
      return;
    }

    int qty = int.tryParse(_qtyController.text) ?? 0;
    int stokSekarang = _selectedBarang!['stok'] ?? 0;
    int bayar = int.tryParse(_bayarController.text) ?? 0;

    if (qty <= 0) {
      _showNotification('Jumlah pembelian minimal 1!', isError: true);
      return;
    }

    if (qty > stokSekarang) {
      _showNotification('Stok tidak mencukupi! Sisa stok: $stokSekarang', isError: true);
      return;
    }

    if (bayar < _totalHarga || _totalHarga == 0) {
      _showNotification('Uang pembayaran masih kurang!', isError: true);
      return;
    }

    int stokBaru = stokSekarang - qty;
    int barangId = _selectedBarang!['id'];

    // Update stok barang
    await _dbHelper.updateStok(barangId, stokBaru);

    // Simpan riwayat transaksi ke database
    String nowFormatted = DateTime.now().toString().substring(0, 16);
    await _dbHelper.insertTransaksi({
      'nama_barang': _selectedBarang!['nama'],
      'jumlah': qty,
      'total_harga': _totalHarga,
      'uang_bayar': bayar,
      'kembalian': _kembalian,
      'tanggal': nowFormatted,
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2432),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'TRANSAKSI SUKSES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131822),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStrukItem('Barang', '${_selectedBarang!['nama']}'),
              _buildStrukItem('Jumlah', '$qty unit'),
              _buildStrukItem('Sisa Stok', '$stokBaru', valColor: Colors.amber),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Colors.white24, thickness: 1),
              ),
              _buildStrukItem('Total Harga', 'Rp $_totalHarga', isBold: true),
              _buildStrukItem('Uang Bayar', 'Rp $bayar'),
              _buildStrukItem('Kembalian', 'Rp $_kembalian', valColor: Colors.greenAccent, isBold: true),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _loadBarang();
              },
              child: const Text(
                'Selesai / Transaksi Baru',
                style: TextStyle(
                  color: Color(0xFF131822),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStrukItem(String label, String value, {Color valColor = Colors.white, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF181F2C),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.point_of_sale, color: Colors.amber, size: 22),
            SizedBox(width: 8),
            Text(
              'Transaksi Kasir Toko Buku',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _loadBarang,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF181F2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pilih Buku & Jumlah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF181F2C),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Pilih Buku / ATK',
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.menu_book, color: Colors.amber),
                      filled: true,
                      fillColor: const Color(0xFF101520),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    value: _selectedBarangId,
                    items: _barangList.map((barang) {
                      return DropdownMenuItem<int>(
                        value: barang['id'],
                        child: Text(
                          '${barang['nama']} - Rp${barang['harga']} (Stok: ${barang['stok']})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBarangId = val;
                        _selectedBarang = _barangList.firstWhere(
                          (item) => item['id'] == val,
                          orElse: () => {},
                        );
                        _hitungTotal();
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Quantity)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, color: Colors.amber),
                      filled: true,
                      fillColor: const Color(0xFF101520),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    onChanged: (_) => _hitungTotal(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2838), Color(0xFF121824)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL HARGA:',
                        style: TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 1.1),
                      ),
                      Text(
                        'Rp $_totalHarga',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white12, thickness: 1),
                  ),
                  TextField(
                    controller: _bayarController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Uang Pembayaran (Rp)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.payments_outlined, color: Colors.amber),
                      filled: true,
                      fillColor: const Color(0xFF0D121B),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    onChanged: (_) => _hitungKembalian(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KEMBALIAN:',
                        style: TextStyle(color: Colors.white60, fontSize: 13, letterSpacing: 1.1),
                      ),
                      Text(
                        'Rp $_kembalian',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _prosesBayar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        elevation: 8,
                        shadowColor: Colors.amber.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Color(0xFF101520)),
                          SizedBox(width: 8),
                          Text(
                            'PROSES BAYAR',
                            style: TextStyle(
                              color: Color(0xFF101520),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
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