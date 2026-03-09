import 'package:flutter/material.dart';

import 'access_control.dart';
import 'asset_detail_page.dart';
import 'asset_form_page.dart';
import 'asset_image_view.dart';
import 'asset_item.dart';
import 'asset_ops_models.dart';
import 'asset_service.dart';
import 'ops_center_page.dart';
import 'scan_qr_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomePage({super.key, this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = AssetService();
  final access = AccessControl.instance;

  final searchCtl = TextEditingController();
  final typeFilterCtl = TextEditingController();
  final brandFilterCtl = TextEditingController();
  final locationFilterCtl = TextEditingController();

  int _tabIndex = 0;
  String _statusFilter = AssetService.statusAll;
  bool _showAdvancedFilters = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _clearSearch() {
    searchCtl.clear();
  }

  void _clearAdvancedFilters() {
    typeFilterCtl.clear();
    brandFilterCtl.clear();
    locationFilterCtl.clear();
    setState(() {});
  }

  void _openStatusAssets(String status) {
    searchCtl.clear();
    typeFilterCtl.clear();
    brandFilterCtl.clear();
    locationFilterCtl.clear();
    setState(() {
      _statusFilter = status;
      _showAdvancedFilters = false;
      _tabIndex = 1;
    });
  }

  void _showNoPermission() {
    _showMessage('คุณไม่มีสิทธิ์ใช้งาน');
  }

  Future<void> _openCreateAssetForm(String assetCode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetFormPage(initialAssetCode: assetCode),
      ),
    );
  }

  Future<void> _promptCreateMissingAsset(String assetCode) async {
    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ไม่พบครุภัณฑ์'),
        content: Text(
          'ไม่พบรหัสครุภัณฑ์ $assetCode ในระบบ\nต้องการสร้างครุภัณฑ์ใหม่ตอนนี้หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
    if (!mounted || shouldCreate != true) return;
    await _openCreateAssetForm(assetCode);
  }

  @override
  void dispose() {
    searchCtl.dispose();
    typeFilterCtl.dispose();
    brandFilterCtl.dispose();
    locationFilterCtl.dispose();
    super.dispose();
  }

  Future<void> _searchByCode(String rawInput) async {
    final code = service.extractAssetCode(rawInput);
    if (code.isEmpty) return;

    final item = await service.getByAssetCode(code);
    if (!mounted) return;

    if (item == null) {
      if (access.can(AssetService.permissionCreateAsset)) {
        await _promptCreateMissingAsset(code);
        return;
      }
      _showMessage(
        'ไม่พบรหัสครุภัณฑ์นี้ในระบบ และบัญชีเจ้าหน้าที่ไม่สามารถสร้างรายการใหม่ได้',
      );
      return;
    }

    if (access.can(AssetService.permissionEditAsset)) {
      try {
        await service.markAssetScanned(
          item.id,
          actorName: access.activeUserName,
          actorRole: access.activeRole,
        );
      } catch (_) {
        // Keep navigation working even when scan timestamp update fails.
      }
    }

    if (!mounted) return;
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

    final normalized = service.extractAssetCode(code);
    if (normalized.isEmpty) return;

    searchCtl.text = normalized;
    setState(() {});
    await _searchByCode(normalized);
  }

  Color _statusColor(String status) {
    switch (status) {
      case AssetService.statusNormal:
        return const Color(0xFF3CD348);
      case AssetService.statusRepair:
        return const Color(0xFFFF8A3D);
      case AssetService.statusDisposed:
        return const Color(0xFF9E9E9E);
      case AssetService.statusBorrowed:
        return const Color(0xFF3B82F6);
      case AssetService.statusLost:
        return const Color(0xFFEF4444);
      default:
        return Colors.white70;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case AssetService.statusNormal:
        return 'ปกติ';
      case AssetService.statusRepair:
        return 'ชำรุด';
      case AssetService.statusDisposed:
        return 'จำหน่าย';
      case AssetService.statusBorrowed:
        return 'ถูกยืม';
      case AssetService.statusLost:
        return 'สูญหาย';
      default:
        return status;
    }
  }

  String _roleLabel(String role) {
    switch (role.trim().toUpperCase()) {
      case AssetService.roleAdmin:
        return 'ผู้ดูแลระบบ';
      case AssetService.roleStaff:
        return 'เจ้าหน้าที่';
      default:
        return role;
    }
  }

  Widget _buildDashboard(List<AssetItem> items) {
    final summary = AssetSummary.fromItems(items);
    final canCreate = access.can(AssetService.permissionCreateAsset);

    return LayoutBuilder(
      builder: (context, constraints) {
        final statusHeight = (constraints.maxHeight * 0.26).clamp(170.0, 230.0);
        final actionHeight = (constraints.maxHeight * 0.24).clamp(112.0, 190.0);
        final statusCardWidth = (constraints.maxWidth * 0.34)
            .clamp(120.0, 170.0)
            .toDouble();

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
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text(
                        'ระบบจัดการครุภัณฑ์',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'มีครุภัณฑ์ทั้งหมด ${items.length} รายการ',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กำลังถูกยืม ${summary.checkedOut} • เกินกำหนด ${summary.overdueCheckout}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'สรุปสถานะครุภัณฑ์',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: statusHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: statusCardWidth,
                          child: _StatusCard(
                            color: const Color(0xFF23B734),
                            icon: Icons.check_circle_outline,
                            label: 'ปกติ',
                            count: summary.normal,
                            onTap: () =>
                                _openStatusAssets(AssetService.statusNormal),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: statusCardWidth,
                          child: _StatusCard(
                            color: const Color(0xFFE77A2B),
                            icon: Icons.report_problem_outlined,
                            label: 'ชำรุด',
                            count: summary.repair,
                            onTap: () =>
                                _openStatusAssets(AssetService.statusRepair),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: statusCardWidth,
                          child: _StatusCard(
                            color: const Color(0xFF757575),
                            icon: Icons.remove_circle_outline,
                            label: 'จำหน่าย',
                            count: summary.disposed,
                            onTap: () =>
                                _openStatusAssets(AssetService.statusDisposed),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: statusCardWidth,
                          child: _StatusCard(
                            color: const Color(0xFF3B82F6),
                            icon: Icons.assignment_returned_outlined,
                            label: 'ถูกยืม',
                            count: summary.borrowed,
                            onTap: () =>
                                _openStatusAssets(AssetService.statusBorrowed),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: statusCardWidth,
                          child: _StatusCard(
                            color: const Color(0xFFEF4444),
                            icon: Icons.help_outline,
                            label: 'สูญหาย',
                            count: summary.lost,
                            onTap: () =>
                                _openStatusAssets(AssetService.statusLost),
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
                            label: 'สแกนบาร์โค้ด',
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
                            onTap: canCreate
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AssetFormPage(),
                                    ),
                                  )
                                : _showNoPermission,
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
    final canEdit = access.can(AssetService.permissionEditAsset);
    final filterListenable = Listenable.merge([
      searchCtl,
      typeFilterCtl,
      brandFilterCtl,
      locationFilterCtl,
    ]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchCtl,
            decoration: InputDecoration(
              hintText: 'ค้นหาด้วยรหัส/ประเภท/ยี่ห้อ/ที่ตั้ง',
              suffixIconConstraints: const BoxConstraints(minWidth: 92),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchCtl,
                builder: (context, value, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final code = searchCtl.text.trim();
                        if (code.isEmpty) return;
                        await _searchByCode(code);
                      },
                    ),
                    if (value.text.trim().isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),
            onSubmitted: (v) async {
              if (v.trim().isEmpty) return;
              await _searchByCode(v);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(
                  () => _showAdvancedFilters = !_showAdvancedFilters,
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  _showAdvancedFilters
                      ? 'ซ่อนตัวกรองขั้นสูง'
                      : 'แสดงตัวกรองขั้นสูง',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAdvancedFilters,
                child: const Text('ล้างค่า'),
              ),
            ],
          ),
        ),
        if (_showAdvancedFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              children: [
                TextField(
                  controller: typeFilterCtl,
                  decoration: const InputDecoration(labelText: 'กรองตามประเภท'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: brandFilterCtl,
                  decoration: const InputDecoration(labelText: 'กรองตามยี่ห้อ'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationFilterCtl,
                  decoration: const InputDecoration(
                    labelText: 'กรองตามที่ตั้ง',
                  ),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _FilterChip(
                label: 'ทั้งหมด',
                selected: _statusFilter == AssetService.statusAll,
                color: const Color(0xFF6E6E6E),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusAll),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'ปกติ',
                selected: _statusFilter == AssetService.statusNormal,
                color: const Color(0xFF23B734),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusNormal),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'ชำรุด',
                selected: _statusFilter == AssetService.statusRepair,
                color: const Color(0xFFE77A2B),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusRepair),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'จำหน่าย',
                selected: _statusFilter == AssetService.statusDisposed,
                color: const Color(0xFF9E9E9E),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusDisposed),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'ถูกยืม',
                selected: _statusFilter == AssetService.statusBorrowed,
                color: const Color(0xFF3B82F6),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusBorrowed),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'สูญหาย',
                selected: _statusFilter == AssetService.statusLost,
                color: const Color(0xFFEF4444),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusLost),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: AnimatedBuilder(
            animation: filterListenable,
            builder: (context, _) {
              final filter = AssetSearchFilter(
                keyword: searchCtl.text,
                status: _statusFilter,
                type: typeFilterCtl.text,
                brand: brandFilterCtl.text,
                location: locationFilterCtl.text,
              );
              final filteredItems = service.filterItemsAdvanced(items, filter);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filteredItems.length} รายการ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(child: Text('ไม่พบครุภัณฑ์'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                            itemCount: filteredItems.length,
                            itemBuilder: (_, i) {
                              final a = filteredItems[i];
                              final checkoutText = a.isCheckedOut
                                  ? ' • ยืมโดย: ${a.currentBorrower ?? ''}'
                                  : '';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: const Color(0xFF2B2B2B),
                                child: ListTile(
                                  leading: _AssetLeading(
                                    imageUrl: a.imageUrl,
                                    imageBase64: a.imageBase64,
                                    iconColor: _statusColor(a.status),
                                  ),
                                  title: Text(
                                    a.brand.isNotEmpty
                                        ? a.brand
                                        : (a.type.isNotEmpty
                                              ? a.type
                                              : a.assetCode),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${a.assetCode} • ${_statusLabel(a.status)}$checkoutText',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: Icon(
                                    canEdit
                                        ? Icons.edit
                                        : Icons.visibility_outlined,
                                    color: Colors.white54,
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AssetDetailPage(assetId: a.id),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
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
            body: Center(child: Text('โหลดข้อมูลครุภัณฑ์ไม่สำเร็จ')),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snap.data ?? [];
        final canCreate = access.can(AssetService.permissionCreateAsset);

        return Scaffold(
          appBar: AppBar(
            title: Text(_tabIndex == 0 ? 'แดชบอร์ด' : 'ครุภัณฑ์'),
            actions: [
              IconButton(
                tooltip: 'ศูนย์ปฏิบัติการ',
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OpsCenterPage()),
                ),
              ),
              IconButton(
                tooltip: 'สแกนบาร์โค้ด',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _openScanner,
              ),
              IconButton(
                tooltip: 'เพิ่มครุภัณฑ์',
                icon: const Icon(Icons.add),
                onPressed: canCreate
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssetFormPage(),
                        ),
                      )
                    : _showNoPermission,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Center(
                  child: Text(
                    _roleLabel(access.activeRole),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (widget.onLogout != null)
                IconButton(
                  tooltip: 'ออกจากระบบ',
                  icon: const Icon(Icons.logout),
                  onPressed: widget.onLogout,
                ),
            ],
          ),
          body: _tabIndex == 0 ? _buildDashboard(items) : _buildList(items),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            backgroundColor: const Color(0xFF252525),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'แดชบอร์ด'),
              NavigationDestination(icon: Icon(Icons.list), label: 'ครุภัณฑ์'),
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
  final VoidCallback? onTap;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 180;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: compact ? 24 : 30),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 16 : 20,
                      height: 1.1,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 32 : 38,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
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
  final String? imageBase64;
  final Color iconColor;

  const _AssetLeading({
    required this.imageUrl,
    required this.imageBase64,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.devices, color: iconColor),
    );

    return AssetImageView(
      imageUrl: imageUrl,
      imageBase64: imageBase64,
      width: 42,
      height: 42,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      placeholder: fallback,
      error: fallback,
    );
  }
}
