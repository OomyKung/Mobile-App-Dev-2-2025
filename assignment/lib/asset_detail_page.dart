import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'asset_service.dart';
import 'asset_form_page.dart';
import 'asset_image_view.dart';

class AssetDetailPage extends StatelessWidget {
  final String assetId;

  AssetDetailPage({super.key, required this.assetId});

  final assetService = AssetService();

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('ลบรายการนี้ใช่หรือไม่'),
        content: const Text('เมื่อลบแล้วจะไม่สามารถกู้คืนข้อมูลและรูปภาพได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await assetService.deleteAsset(assetId);

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ลบเรียบร้อย')));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return const Color(0xFF23B734);
      case 'REPAIR':
        return const Color(0xFFE77A2B);
      case 'DISPOSED':
        return const Color(0xFF8A8A8A);
      default:
        return const Color(0xFF6D6D6D);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'NORMAL':
        return 'ปกติ';
      case 'REPAIR':
        return 'ชำรุด';
      case 'DISPOSED':
        return 'จำหน่าย';
      default:
        return status;
    }
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssetFormPage(assetId: assetId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: assetService.watchById(assetId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('โหลดข้อมูลไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ต'),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final asset = snap.data;
          if (asset == null) {
            return const Center(child: Text('ไม่พบข้อมูลครุภัณฑ์'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: IntrinsicHeight(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 170,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AssetImageView(
                                  imageUrl: asset.imageUrl,
                                  imageBase64: asset.imageBase64,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(10),
                                  placeholder: const Icon(
                                    Icons.devices,
                                    size: 56,
                                    color: Colors.white54,
                                  ),
                                  error: const Icon(
                                    Icons.devices,
                                    size: 56,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              asset.type.isEmpty ? 'ไม่ระบุประเภท' : asset.type,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _row('รหัส', asset.assetCode),
                            _row('ยี่ห้อ', asset.brand),
                            _row('รายละเอียด', asset.detail),
                            _row('ที่ตั้ง', asset.location),
                            const SizedBox(height: 8),
                            const Text(
                              'สถานะ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(asset.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: asset.status,
                                underline: const SizedBox.shrink(),
                                dropdownColor: const Color(0xFF2F2F2F),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'NORMAL',
                                    child: Text('ปกติ'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'REPAIR',
                                    child: Text('ชำรุด'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DISPOSED',
                                    child: Text('จำหน่าย'),
                                  ),
                                ],
                                onChanged: (v) async {
                                  if (v == null) return;
                                  await assetService.updateAsset(assetId, {
                                    'status': v,
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            _row('สร้างเมื่อ', df.format(asset.createdAt)),
                            _row('แก้ไขล่าสุด', df.format(asset.updatedAt)),
                            const Spacer(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AssetFormPage(assetId: assetId),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('แก้ไข'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFE77A2B),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _confirmDelete(context),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('ลบ'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _statusLabel(asset.status),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
