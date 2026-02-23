import 'package:flutter/material.dart';
import 'asset_service.dart';
import 'asset_item.dart';
import 'asset_form_page.dart';
import 'asset_detail_page.dart';
import 'scan_qr_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = AssetService();
  final searchCtl = TextEditingController();
  int _tabIndex = 0;
  String _statusFilter = 'ALL';

  @override
  void dispose() {
    searchCtl.dispose();
    super.dispose();
  }

  Future<void> _searchByCode(String code) async {
    final item = await service.getByAssetCode(code.trim());
    if (!mounted) return;

    if (item == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบรหัสครุภัณฑ์')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssetDetailPage(assetId: item.id)),
    );
  }

  Future<void> _openScanner() async {
    final code = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const ScanQrPage()),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;
    searchCtl.text = code.trim();
    await _searchByCode(code);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return const Color(0xFF3CD348);
      case 'REPAIR':
        return const Color(0xFFFF8A3D);
      case 'DISPOSED':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.white70;
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

  Widget _buildDashboard(List<AssetItem> items) {
    final normalCount = items.where((e) => e.status == 'NORMAL').length;
    final repairCount = items.where((e) => e.status == 'REPAIR').length;
    final disposedCount = items.where((e) => e.status == 'DISPOSED').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final statusHeight = (constraints.maxHeight * 0.19).clamp(112.0, 160.0);
        final actionHeight = (constraints.maxHeight * 0.24).clamp(112.0, 190.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF262626),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF4D4D4D),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: const Text(
                        'ระบบตรวจเช็คครุภัณฑ์',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('จำนวน ${items.length} รายการ'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'สถานะครุภัณฑ์',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: statusHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatusCard(
                            color: const Color(0xFF23B734),
                            icon: Icons.check_circle_outline,
                            label: 'ปกติ',
                            count: normalCount,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatusCard(
                            color: const Color(0xFFE77A2B),
                            icon: Icons.report_problem_outlined,
                            label: 'ชำรุด',
                            count: repairCount,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatusCard(
                            color: const Color(0xFF757575),
                            icon: Icons.remove_circle_outline,
                            label: 'จำหน่าย',
                            count: disposedCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: actionHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.qr_code_scanner,
                            label: 'สแกน QRCode',
                            color: const Color(0xFF64A5FF),
                            onTap: _openScanner,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_circle_outline,
                            label: 'เพิ่มครุภัณฑ์',
                            color: const Color(0xFFE0E0E0),
                            textColor: Colors.black87,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AssetFormPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<AssetItem> items) {
    final filteredItems = items.where((item) {
      if (_statusFilter == 'ALL') return true;
      return item.status == _statusFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchCtl,
            decoration: InputDecoration(
              hintText: 'ค้นหาด้วยรหัสครุภัณฑ์',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final code = searchCtl.text.trim();
                  if (code.isEmpty) return;
                  await _searchByCode(code);
                },
              ),
            ),
            onSubmitted: (v) async {
              if (v.trim().isEmpty) return;
              await _searchByCode(v);
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _FilterChip(
                label: 'ทั้งหมด',
                selected: _statusFilter == 'ALL',
                color: const Color(0xFF6E6E6E),
                onTap: () => setState(() => _statusFilter = 'ALL'),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'ปกติ',
                selected: _statusFilter == 'NORMAL',
                color: const Color(0xFF23B734),
                onTap: () => setState(() => _statusFilter = 'NORMAL'),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'ชำรุด',
                selected: _statusFilter == 'REPAIR',
                color: const Color(0xFFE77A2B),
                onTap: () => setState(() => _statusFilter = 'REPAIR'),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'จำหน่าย',
                selected: _statusFilter == 'DISPOSED',
                color: const Color(0xFF9E9E9E),
                onTap: () => setState(() => _statusFilter = 'DISPOSED'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'จำนวน ${filteredItems.length} รายการ',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text('ยังไม่มีรายการครุภัณฑ์'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: filteredItems.length,
                  itemBuilder: (_, i) {
                    final a = filteredItems[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: const Color(0xFF2B2B2B),
                      child: ListTile(
                        leading: _AssetLeading(
                          imageUrl: a.imageUrl,
                          iconColor: _statusColor(a.status),
                        ),
                        title: Text(
                          a.type.isEmpty ? a.assetCode : a.type,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${a.assetCode}  •  ${_statusLabel(a.status)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.white54),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssetDetailPage(assetId: a.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetItem>>(
      stream: service.watchAll(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('โหลดข้อมูลไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ต'),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snap.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(_tabIndex == 0 ? 'หน้าแรก' : 'รายการครุภัณฑ์'),
            actions: [
              IconButton(
                tooltip: 'สแกน QR',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _openScanner,
              ),
              IconButton(
                tooltip: 'เพิ่ม',
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssetFormPage()),
                ),
              ),
            ],
          ),
          body: _tabIndex == 0 ? _buildDashboard(items) : _buildList(items),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            backgroundColor: const Color(0xFF252525),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'หน้าแรก'),
              NavigationDestination(icon: Icon(Icons.list), label: 'รายการ'),
            ],
            onDestinationSelected: (idx) => setState(() => _tabIndex = idx),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int count;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFF404040),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AssetLeading extends StatelessWidget {
  final String? imageUrl;
  final Color iconColor;

  const _AssetLeading({required this.imageUrl, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    if ((imageUrl ?? '').isEmpty) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.devices, color: iconColor),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => Container(
          width: 42,
          height: 42,
          color: const Color(0xFF3A3A3A),
          child: Icon(Icons.devices, color: iconColor),
        ),
      ),
    );
  }
}
