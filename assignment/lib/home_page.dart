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
  const HomePage({super.key});

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
  bool _onlyNeverScanned = false;
  bool _onlyCheckedOut = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _clearSearch() {
    searchCtl.clear();
    setState(() {});
  }

  void _clearAdvancedFilters() {
    typeFilterCtl.clear();
    brandFilterCtl.clear();
    locationFilterCtl.clear();
    _onlyNeverScanned = false;
    _onlyCheckedOut = false;
    setState(() {});
  }

  void _showNoPermission() {
    _showMessage('Permission denied');
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
      _showMessage('Asset code not found');
      return;
    }

    try {
      await service.markAssetScanned(
        item.id,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
    } catch (_) {
      // Keep navigation working even when scan timestamp update fails.
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
      default:
        return Colors.white70;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case AssetService.statusNormal:
        return 'Normal';
      case AssetService.statusRepair:
        return 'Repair';
      case AssetService.statusDisposed:
        return 'Disposed';
      default:
        return status;
    }
  }

  Widget _buildDashboard(List<AssetItem> items) {
    final summary = AssetSummary.fromItems(items);
    final canCreate = access.can(AssetService.permissionCreateAsset);

    return LayoutBuilder(
      builder: (context, constraints) {
        final statusHeight = (constraints.maxHeight * 0.26).clamp(150.0, 230.0);
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
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text(
                        'Asset Management',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${items.length} assets in system'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checked out ${summary.checkedOut} • Overdue ${summary.overdueCheckout}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Status overview',
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
                            label: 'Normal',
                            count: summary.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatusCard(
                            color: const Color(0xFFE77A2B),
                            icon: Icons.report_problem_outlined,
                            label: 'Repair',
                            count: summary.repair,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatusCard(
                            color: const Color(0xFF757575),
                            icon: Icons.remove_circle_outline,
                            label: 'Disposed',
                            count: summary.disposed,
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
                            label: 'Scan QR',
                            color: const Color(0xFF64A5FF),
                            onTap: _openScanner,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_circle_outline,
                            label: 'Add Asset',
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
    final filter = AssetSearchFilter(
      keyword: searchCtl.text,
      status: _statusFilter,
      type: typeFilterCtl.text,
      brand: brandFilterCtl.text,
      location: locationFilterCtl.text,
      onlyNeverScanned: _onlyNeverScanned,
      onlyCheckedOut: _onlyCheckedOut,
    );
    final filteredItems = service.filterItemsAdvanced(items, filter);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchCtl,
            decoration: InputDecoration(
              hintText: 'Search by code/type/brand/location',
              suffixIconConstraints: const BoxConstraints(minWidth: 92),
              suffixIcon: Row(
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
                  if (searchCtl.text.trim().isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
            onChanged: (_) => setState(() {}),
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
                      ? 'Hide advanced filters'
                      : 'Show advanced filters',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAdvancedFilters,
                child: const Text('Clear'),
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
                  decoration: const InputDecoration(
                    labelText: 'Filter by type',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: brandFilterCtl,
                  decoration: const InputDecoration(
                    labelText: 'Filter by brand',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationFilterCtl,
                  decoration: const InputDecoration(
                    labelText: 'Filter by location',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      selected: _onlyCheckedOut,
                      onSelected: (v) => setState(() => _onlyCheckedOut = v),
                      label: const Text('Checked out only'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _onlyNeverScanned,
                      onSelected: (v) => setState(() => _onlyNeverScanned = v),
                      label: const Text('Never scanned'),
                    ),
                  ],
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
                label: 'All',
                selected: _statusFilter == AssetService.statusAll,
                color: const Color(0xFF6E6E6E),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusAll),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Normal',
                selected: _statusFilter == AssetService.statusNormal,
                color: const Color(0xFF23B734),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusNormal),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Repair',
                selected: _statusFilter == AssetService.statusRepair,
                color: const Color(0xFFE77A2B),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusRepair),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Disposed',
                selected: _statusFilter == AssetService.statusDisposed,
                color: const Color(0xFF9E9E9E),
                onTap: () =>
                    setState(() => _statusFilter = AssetService.statusDisposed),
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
              '${filteredItems.length} items',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text('No asset found'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: filteredItems.length,
                  itemBuilder: (_, i) {
                    final a = filteredItems[i];
                    final checkoutText = a.isCheckedOut
                        ? ' • OUT: ${a.currentBorrower ?? 'Unknown'}'
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
                          a.type.isEmpty ? a.assetCode : a.type,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${a.assetCode} • ${_statusLabel(a.status)}$checkoutText',
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
            body: Center(child: Text('Failed to load asset data')),
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
            title: Text(_tabIndex == 0 ? 'Dashboard' : 'Assets'),
            actions: [
              IconButton(
                tooltip: 'Ops Center',
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OpsCenterPage()),
                ),
              ),
              IconButton(
                tooltip: 'Scan QR',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _openScanner,
              ),
              IconButton(
                tooltip: 'Add asset',
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
              PopupMenuButton<String>(
                tooltip: 'Role',
                onSelected: (v) {
                  access.switchRole(v);
                  setState(() {});
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: AssetService.roleAdmin,
                    child: Text('Role: ADMIN'),
                  ),
                  PopupMenuItem(
                    value: AssetService.roleStaff,
                    child: Text('Role: STAFF'),
                  ),
                  PopupMenuItem(
                    value: AssetService.roleViewer,
                    child: Text('Role: VIEWER'),
                  ),
                ],
              ),
            ],
          ),
          body: _tabIndex == 0 ? _buildDashboard(items) : _buildList(items),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            backgroundColor: const Color(0xFF252525),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.list), label: 'Assets'),
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 38,
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
