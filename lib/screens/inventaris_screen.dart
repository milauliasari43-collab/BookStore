import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _barangList = [];

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshBarang();
  }

  void _refreshBarang() async {
    final data = await _dbHelper.getBarang();
    setState(() {
      _barangList = data;
    });
  }

  void _showFormDialog({Map<String, dynamic>? barang}) {
    if (barang != null) {
      _namaController.text = barang['nama'];
      _hargaController.text = barang['harga'].toString();
      _stokController.text = barang['stok'].toString();
    } else {
      _namaController.clear();
      _hargaController.clear();
      _stokController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2432),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          barang == null ? 'Tambah Buku / Barang' : 'Edit Buku / Barang',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Buku/Barang',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF101520),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Harga (Rp)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF101520),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stokController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Jumlah Stok',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF101520),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              String nama = _namaController.text.trim();
              int harga = int.tryParse(_hargaController.text) ?? 0;
              int stok = int.tryParse(_stokController.text) ?? 0;

              if (nama.isEmpty || harga <= 0) return;

              final db = await _dbHelper.database;
              if (barang == null) {
                await db.insert('barang', {
                  'nama': nama,
                  'harga': harga,
                  'stok': stok,
                });
              } else {
                await db.update(
                  'barang',
                  {'nama': nama, 'harga': harga, 'stok': stok},
                  where: 'id = ?',
                  whereArgs: [barang['id']],
                );
              }

              if (!mounted) return;
              Navigator.pop(ctx);
              _refreshBarang();
            },
            child: Text(
              barang == null ? 'Tambah' : 'Simpan',
              style: const TextStyle(color: Color(0xFF101520), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteBarang(int id) async {
    final db = await _dbHelper.database;
    await db.delete('barang', where: 'id = ?', whereArgs: [id]);
    _refreshBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F2C),
        title: const Text('Kelola Inventaris Buku', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: _barangList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data barang.',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _barangList.length,
              itemBuilder: (context, index) {
                final item = _barangList[index];
                return Card(
                  color: const Color(0xFF181F2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.amber),
                    ),
                    title: Text(
                      item['nama'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${item['harga']} | Stok: ${item['stok']}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showFormDialog(barang: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteBarang(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add, color: Color(0xFF101520)),
      ),
    );
  }
}