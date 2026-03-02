import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'access_control.dart';
import 'asset_ops_models.dart';
import 'asset_operations_page.dart';
import 'asset_service.dart';

class OpsCenterPage extends StatefulWidget {
  const OpsCenterPage({super.key});

  @override
  State<OpsCenterPage> createState() => _OpsCenterPageState();
}

class _OpsCenterPageState extends State<OpsCenterPage> {
  final service = AssetService();
  final access = AccessControl.instance;
  final df = DateFormat('dd/MM/yyyy HH:mm');
  bool _busy = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _startStocktake() async {
    final nameCtl = TextEditingController();
    final locationCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Stocktake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Session name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locationCtl,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (nameCtl.text.trim().isEmpty) {
      _showMessage('Session name is required');
      return;
    }

    try {
      await service.startStocktakeSession(
        name: nameCtl.text.trim(),
        location: locationCtl.text.trim(),
        createdBy: access.activeUserName,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Stocktake started');
    } catch (e) {
      _showMessage('Start stocktake failed: $e');
    }
  }

  Future<void> _scanInSession(StocktakeSession session) async {
    final codeCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Scan in ${session.name}'),
        content: TextField(
          controller: codeCtl,
          decoration: const InputDecoration(labelText: 'Asset code / QR text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Scan'),
          ),
        ],
      ),
    );

    if (ok != true || codeCtl.text.trim().isEmpty) return;
    try {
      await service.recordStocktakeScan(
        sessionId: session.id,
        scannedText: codeCtl.text.trim(),
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Scanned');
    } catch (e) {
      _showMessage('Scan failed: $e');
    }
  }

  Future<void> _closeSession(StocktakeSession session) async {
    try {
      await service.closeStocktakeSession(
        session.id,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Stocktake closed');
    } catch (e) {
      _showMessage('Close session failed: $e');
    }
  }

  Future<void> _generateNotifications() async {
    setState(() => _busy = true);
    try {
      final count = await service.generateSystemNotifications(
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Generated $count notifications');
    } catch (e) {
      _showMessage('Generate failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final csv = await service.exportAssetsCsv();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export CSV'),
          content: SizedBox(
            width: 620,
            child: TextField(
              controller: TextEditingController(text: csv),
              maxLines: 16,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csv));
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _showMessage('CSV copied');
              },
              child: const Text('Copy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importCsv() async {
    final csvCtl = TextEditingController();
    var overwrite = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Import CSV'),
          content: SizedBox(
            width: 620,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: csvCtl,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'Paste CSV data',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Overwrite existing asset'),
                  value: overwrite,
                  onChanged: (v) => setDialogState(() => overwrite = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || csvCtl.text.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      final result = await service.importAssetsFromCsv(
        csvCtl.text,
        overwriteExisting: overwrite,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage(
        'Import done: +${result.imported}, updated ${result.updated}, skipped ${result.skipped}',
      );
      if (result.errors.isNotEmpty && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Import errors'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Text(result.errors.join('\n')),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showMessage('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upsertUser([AssetUserProfile? user]) async {
    final idCtl = TextEditingController(text: user?.id ?? '');
    final nameCtl = TextEditingController(text: user?.displayName ?? '');
    final emailCtl = TextEditingController(text: user?.email ?? '');
    var role = user?.role ?? AssetService.roleStaff;
    var active = user?.active ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(user == null ? 'Add User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idCtl,
                  enabled: user == null,
                  decoration: const InputDecoration(labelText: 'User id'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: AssetService.roleAdmin,
                      child: Text('ADMIN'),
                    ),
                    DropdownMenuItem(
                      value: AssetService.roleStaff,
                      child: Text('STAFF'),
                    ),
                    DropdownMenuItem(
                      value: AssetService.roleViewer,
                      child: Text('VIEWER'),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => role = v ?? AssetService.roleStaff),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    if (idCtl.text.trim().isEmpty || nameCtl.text.trim().isEmpty) {
      _showMessage('User id and name are required');
      return;
    }
    try {
      await service.upsertUserProfile(
        userId: idCtl.text.trim(),
        displayName: nameCtl.text.trim(),
        email: emailCtl.text.trim(),
        role: role,
        active: active,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Saved user profile');
    } catch (e) {
      _showMessage('Save user failed: $e');
    }
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageUsers = access.can(AssetService.permissionManageUsers);
    final canManageStocktake = access.can(
      AssetService.permissionManageStocktake,
    );
    final canManageNotifications = access.can(
      AssetService.permissionManageNotifications,
    );
    final canImportExport = access.can(AssetService.permissionImportExport);
    final canViewAudit = access.can(AssetService.permissionViewAudit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Center'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Switch role',
            onSelected: (v) {
              access.switchRole(v);
              setState(() {});
              _showMessage('Active role: $v');
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Session & Sync'),
                      const SizedBox(height: 8),
                      Text('User: ${access.activeUserName}'),
                      Text('Role: ${access.activeRole}'),
                      const SizedBox(height: 6),
                      StreamBuilder<AppSyncState>(
                        stream: service.watchSyncState(),
                        builder: (context, snap) {
                          final sync = snap.data;
                          if (sync == null) return const SizedBox.shrink();
                          return Text(
                            'Sync: ${sync.label} (${df.format(sync.observedAt)})',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Users & Roles',
                        trailing: IconButton(
                          onPressed: canManageUsers ? _upsertUser : null,
                          icon: const Icon(Icons.person_add_alt),
                        ),
                      ),
                      StreamBuilder<List<AssetUserProfile>>(
                        stream: service.watchUsers(),
                        builder: (context, snap) {
                          final users = snap.data ?? const [];
                          if (users.isEmpty) {
                            return const Text(
                              'No user profile yet',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: users.take(20).map((u) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  u.displayName.isEmpty ? u.id : u.displayName,
                                ),
                                subtitle: Text('${u.email} • ${u.role}'),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      onPressed: canManageUsers
                                          ? () => _upsertUser(u)
                                          : null,
                                      icon: const Icon(Icons.edit, size: 18),
                                    ),
                                    IconButton(
                                      tooltip: 'Switch as this user',
                                      onPressed: () {
                                        access.switchActor(
                                          userId: u.id,
                                          userName: u.displayName.isEmpty
                                              ? u.id
                                              : u.displayName,
                                          role: u.role,
                                        );
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.login, size: 18),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Stocktake Sessions',
                        trailing: IconButton(
                          onPressed: canManageStocktake
                              ? _startStocktake
                              : null,
                          icon: const Icon(Icons.add_box_outlined),
                        ),
                      ),
                      StreamBuilder<List<StocktakeSession>>(
                        stream: service.watchStocktakeSessions(limit: 20),
                        builder: (context, snap) {
                          final sessions = snap.data ?? const [];
                          if (sessions.isEmpty) {
                            return const Text(
                              'No stocktake session',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: sessions.map((s) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(s.name),
                                subtitle: Text(
                                  '${s.status} • scanned ${s.scannedAssetIds.length}/${s.totalTargetCount}',
                                ),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'Scan',
                                      onPressed: s.isOpen && canManageStocktake
                                          ? () => _scanInSession(s)
                                          : null,
                                      icon: const Icon(
                                        Icons.qr_code_scanner,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Close',
                                      onPressed: s.isOpen && canManageStocktake
                                          ? () => _closeSession(s)
                                          : null,
                                      icon: const Icon(
                                        Icons.done_all,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Notifications',
                        trailing: IconButton(
                          onPressed: canManageNotifications
                              ? _generateNotifications
                              : null,
                          icon: const Icon(Icons.notifications_active_outlined),
                        ),
                      ),
                      StreamBuilder<List<SystemNotification>>(
                        stream: service.watchNotifications(limit: 30),
                        builder: (context, snap) {
                          final notes = snap.data ?? const [];
                          if (notes.isEmpty) {
                            return const Text(
                              'No open notification',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: notes.map((n) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(n.title),
                                subtitle: Text(
                                  '${n.message}\n${df.format(n.createdAt)} • ${n.level}',
                                ),
                                onTap: n.assetId == null
                                    ? null
                                    : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AssetOperationsPage(
                                            assetId: n.assetId!,
                                          ),
                                        ),
                                      ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'read') {
                                      await service.markNotificationRead(
                                        n.id,
                                        actorName: access.activeUserName,
                                        actorRole: access.activeRole,
                                      );
                                      return;
                                    }
                                    await service.resolveNotification(
                                      n.id,
                                      actorName: access.activeUserName,
                                      actorRole: access.activeRole,
                                    );
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'read',
                                      child: Text('Mark read'),
                                    ),
                                    PopupMenuItem(
                                      value: 'resolve',
                                      child: Text('Resolve'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Import / Export CSV'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: canImportExport ? _exportCsv : null,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Export'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: canImportExport ? _importCsv : null,
                            icon: const Icon(Icons.upload_outlined),
                            label: const Text('Import'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Recent Audit'),
                      StreamBuilder<List<AssetAuditLog>>(
                        stream: service.watchAuditLogs(limit: 30),
                        builder: (context, snap) {
                          if (!canViewAudit) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Permission denied'),
                            );
                          }
                          final logs = snap.data ?? const [];
                          if (logs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('No audit log'),
                            );
                          }
                          return Column(
                            children: logs.map((log) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${log.action} • ${log.entityType}',
                                ),
                                subtitle: Text(
                                  '${log.message}\n${df.format(log.createdAt)} • ${log.actorName} (${log.actorRole})',
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
