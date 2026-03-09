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

  String _stocktakeStatusLabel(String status) {
    switch (status.trim().toUpperCase()) {
      case 'OPEN':
        return 'เปิดอยู่';
      case 'CLOSED':
        return 'ปิดแล้ว';
      default:
        return status;
    }
  }

  String _notificationLevelLabel(String level) {
    switch (level.trim().toUpperCase()) {
      case AssetService.notificationInfo:
        return 'ข้อมูล';
      case AssetService.notificationWarn:
        return 'เตือน';
      case AssetService.notificationCritical:
        return 'วิกฤต';
      default:
        return level;
    }
  }

  String _notificationStatusLabel(String status) {
    switch (status.trim().toUpperCase()) {
      case AssetService.notificationNew:
        return 'ใหม่';
      case AssetService.notificationRead:
        return 'อ่านแล้ว';
      case AssetService.notificationResolved:
        return 'ปิดแล้ว';
      default:
        return status;
    }
  }

  String _auditActionLabel(String action) {
    switch (action.trim().toUpperCase()) {
      case 'ASSET_CREATE':
        return 'เพิ่มครุภัณฑ์';
      case 'ASSET_UPDATE':
        return 'แก้ไขครุภัณฑ์';
      case 'ASSET_DELETE':
        return 'ลบครุภัณฑ์';
      case 'USER_UPSERT':
        return 'บันทึกผู้ใช้';
      case 'USER_ROLE_CHANGE':
        return 'เปลี่ยนบทบาทผู้ใช้';
      case 'MAINTENANCE_CREATE':
        return 'สร้างใบงานซ่อม';
      case 'MAINTENANCE_STATUS':
        return 'อัปเดตสถานะใบงานซ่อม';
      case 'CHECKOUT_CREATE':
        return 'บันทึกการยืม';
      case 'CHECKOUT_RETURN':
        return 'บันทึกการคืน';
      case 'STOCKTAKE_START':
        return 'เริ่มรอบตรวจนับ';
      case 'STOCKTAKE_SCAN':
        return 'สแกนในรอบตรวจนับ';
      case 'STOCKTAKE_CLOSE':
        return 'ปิดรอบตรวจนับ';
      case 'NOTIFICATION_CREATE':
        return 'สร้างการแจ้งเตือน';
      case 'NOTIFICATION_READ':
        return 'อ่านการแจ้งเตือน';
      case 'NOTIFICATION_RESOLVE':
        return 'ปิดการแจ้งเตือน';
      case 'NOTIFICATION_GENERATE':
        return 'สร้างการแจ้งเตือนอัตโนมัติ';
      case 'ATTACHMENT_ADD':
        return 'เพิ่มไฟล์แนบ';
      case 'ATTACHMENT_REMOVE':
        return 'ลบไฟล์แนบ';
      case 'CSV_IMPORT':
        return 'นำเข้า CSV';
      default:
        return action;
    }
  }

  String _entityTypeLabel(String entityType) {
    switch (entityType.trim().toLowerCase()) {
      case 'asset':
        return 'ครุภัณฑ์';
      case 'user':
        return 'ผู้ใช้';
      case 'maintenance':
        return 'งานซ่อม';
      case 'checkout':
        return 'การยืมคืน';
      case 'stocktake':
        return 'รอบตรวจนับ';
      case 'notification':
        return 'การแจ้งเตือน';
      case 'attachment':
        return 'ไฟล์แนบ';
      default:
        return entityType;
    }
  }

  Future<void> _startStocktake() async {
    final nameCtl = TextEditingController();
    final locationCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เริ่มรอบตรวจนับ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'ชื่อรอบตรวจนับ'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locationCtl,
              decoration: const InputDecoration(
                labelText: 'ที่ตั้ง (ไม่บังคับ)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('เริ่ม'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (nameCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกชื่อรอบตรวจนับ');
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
      _showMessage('เริ่มรอบตรวจนับแล้ว');
    } catch (e) {
      _showMessage('เริ่มรอบตรวจนับไม่สำเร็จ: $e');
    }
  }

  Future<void> _scanInSession(StocktakeSession session) async {
    final codeCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('สแกนในรอบ ${session.name}'),
        content: TextField(
          controller: codeCtl,
          decoration: const InputDecoration(
            labelText: 'รหัสครุภัณฑ์ / ข้อความจาก QR',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('สแกน'),
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
      _showMessage('สแกนสำเร็จ');
    } catch (e) {
      _showMessage('สแกนไม่สำเร็จ: $e');
    }
  }

  Future<void> _closeSession(StocktakeSession session) async {
    try {
      await service.closeStocktakeSession(
        session.id,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('ปิดรอบตรวจนับแล้ว');
    } catch (e) {
      _showMessage('ปิดรอบตรวจนับไม่สำเร็จ: $e');
    }
  }

  Future<void> _generateNotifications() async {
    setState(() => _busy = true);
    try {
      final count = await service.generateSystemNotifications(
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('สร้างการแจ้งเตือน $count รายการ');
    } catch (e) {
      _showMessage('สร้างการแจ้งเตือนไม่สำเร็จ: $e');
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
          title: const Text('ส่งออก CSV'),
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
                _showMessage('คัดลอก CSV แล้ว');
              },
              child: const Text('คัดลอก'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('ส่งออกไม่สำเร็จ: $e');
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
          title: const Text('นำเข้า CSV'),
          content: SizedBox(
            width: 620,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: csvCtl,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'วางข้อมูล CSV',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('เขียนทับข้อมูลครุภัณฑ์เดิม'),
                  value: overwrite,
                  onChanged: (v) => setDialogState(() => overwrite = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('นำเข้า'),
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
        'นำเข้าเสร็จ: เพิ่ม ${result.imported}, อัปเดต ${result.updated}, ข้าม ${result.skipped}',
      );
      if (result.errors.isNotEmpty && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('ข้อผิดพลาดการนำเข้า'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Text(result.errors.join('\n')),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showMessage('นำเข้าไม่สำเร็จ: $e');
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
          title: Text(user == null ? 'เพิ่มผู้ใช้' : 'แก้ไขผู้ใช้'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idCtl,
                  enabled: user == null,
                  decoration: const InputDecoration(labelText: 'รหัสผู้ใช้'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: 'ชื่อที่แสดง'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtl,
                  decoration: const InputDecoration(labelText: 'อีเมล'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'บทบาท'),
                  items: const [
                    DropdownMenuItem(
                      value: AssetService.roleAdmin,
                      child: Text('ผู้ดูแลระบบ'),
                    ),
                    DropdownMenuItem(
                      value: AssetService.roleStaff,
                      child: Text('เจ้าหน้าที่'),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => role = v ?? AssetService.roleStaff),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  title: const Text('ใช้งาน'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    if (idCtl.text.trim().isEmpty || nameCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกรหัสผู้ใช้และชื่อที่แสดง');
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
      _showMessage('บันทึกข้อมูลผู้ใช้แล้ว');
    } catch (e) {
      _showMessage('บันทึกข้อมูลผู้ใช้ไม่สำเร็จ: $e');
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
        title: const Text('ศูนย์ปฏิบัติการ'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'สลับบทบาท',
            onSelected: (v) {
              access.switchRole(v);
              setState(() {});
              _showMessage('สลับบทบาทเป็น ${_roleLabel(v)}');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: AssetService.roleAdmin,
                child: Text('บทบาท: ผู้ดูแลระบบ'),
              ),
              PopupMenuItem(
                value: AssetService.roleStaff,
                child: Text('บทบาท: เจ้าหน้าที่'),
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
                      _sectionTitle('สถานะผู้ใช้และการซิงก์'),
                      const SizedBox(height: 8),
                      Text('ผู้ใช้: ${access.activeUserName}'),
                      Text('บทบาท: ${_roleLabel(access.activeRole)}'),
                      const SizedBox(height: 6),
                      StreamBuilder<AppSyncState>(
                        stream: service.watchSyncState(),
                        builder: (context, snap) {
                          final sync = snap.data;
                          if (sync == null) return const SizedBox.shrink();
                          return Text(
                            'ซิงก์: ${sync.label} (${df.format(sync.observedAt)})',
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
                        'ผู้ใช้และบทบาท',
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
                              'ยังไม่มีข้อมูลผู้ใช้',
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
                                subtitle: Text(
                                  '${u.email} • ${_roleLabel(u.role)}',
                                ),
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
                                      tooltip: 'สลับเป็นผู้ใช้นี้',
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
                        'รอบตรวจนับ',
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
                              'ยังไม่มีรอบตรวจนับ',
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
                                  '${_stocktakeStatusLabel(s.status)} • สแกนแล้ว ${s.scannedAssetIds.length}/${s.totalTargetCount}',
                                ),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'สแกน',
                                      onPressed: s.isOpen && canManageStocktake
                                          ? () => _scanInSession(s)
                                          : null,
                                      icon: const Icon(
                                        Icons.qr_code_scanner,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'ปิด',
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
                        'การแจ้งเตือน',
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
                              'ไม่มีการแจ้งเตือนค้าง',
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
                                  '${n.message}\n${df.format(n.createdAt)} • ${_notificationLevelLabel(n.level)} • ${_notificationStatusLabel(n.status)}',
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
                                      child: Text('ทำเครื่องหมายว่าอ่านแล้ว'),
                                    ),
                                    PopupMenuItem(
                                      value: 'resolve',
                                      child: Text('ปิดการแจ้งเตือน'),
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
                      _sectionTitle('นำเข้า / ส่งออก CSV'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: canImportExport ? _exportCsv : null,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('ส่งออก'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: canImportExport ? _importCsv : null,
                            icon: const Icon(Icons.upload_outlined),
                            label: const Text('นำเข้า'),
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
                      _sectionTitle('ประวัติการทำรายการล่าสุด'),
                      StreamBuilder<List<AssetAuditLog>>(
                        stream: service.watchAuditLogs(limit: 30),
                        builder: (context, snap) {
                          if (!canViewAudit) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('คุณไม่มีสิทธิ์ใช้งาน'),
                            );
                          }
                          final logs = snap.data ?? const [];
                          if (logs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('ยังไม่มีบันทึก'),
                            );
                          }
                          return Column(
                            children: logs.map((log) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${_auditActionLabel(log.action)} • ${_entityTypeLabel(log.entityType)}',
                                ),
                                subtitle: Text(
                                  '${log.message}\n${df.format(log.createdAt)} • ${log.actorName} (${_roleLabel(log.actorRole)})',
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
