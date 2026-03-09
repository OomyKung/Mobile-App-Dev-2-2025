import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'access_control.dart';
import 'asset_item.dart';
import 'asset_ops_models.dart';
import 'asset_service.dart';

class AssetOperationsPage extends StatefulWidget {
  final String assetId;

  const AssetOperationsPage({super.key, required this.assetId});

  @override
  State<AssetOperationsPage> createState() => _AssetOperationsPageState();
}

class _AssetOperationsPageState extends State<AssetOperationsPage> {
  final service = AssetService();
  final access = AccessControl.instance;
  final df = DateFormat('dd/MM/yyyy HH:mm');

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _maintenanceStatusLabel(String status) {
    switch (status.trim().toUpperCase()) {
      case AssetService.maintenanceOpen:
        return 'เปิดใบงาน';
      case AssetService.maintenanceInProgress:
        return 'กำลังดำเนินการ';
      case AssetService.maintenanceDone:
        return 'เสร็จสิ้น';
      case AssetService.maintenanceCancelled:
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  Future<void> _openCheckoutDialog(AssetItem asset) async {
    final borrowerCtl = TextEditingController();
    final contactCtl = TextEditingController();
    final purposeCtl = TextEditingController();
    DateTime? dueAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('ยืมครุภัณฑ์'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: borrowerCtl,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อผู้ยืม',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contactCtl,
                      decoration: const InputDecoration(
                        labelText: 'ช่องทางติดต่อ',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: purposeCtl,
                      decoration: const InputDecoration(
                        labelText: 'วัตถุประสงค์',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dueAt == null
                                ? 'ไม่กำหนดวันครบกำหนด'
                                : 'ครบกำหนด: ${DateFormat('dd/MM/yyyy').format(dueAt!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(
                                const Duration(days: 7),
                              ),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked == null) return;
                            setDialogState(() => dueAt = picked);
                          },
                          child: const Text('เลือกวันครบกำหนด'),
                        ),
                      ],
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
                  child: const Text('ยืมออก'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    if (borrowerCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกชื่อผู้ยืม');
      return;
    }

    try {
      await service.checkoutAsset(
        assetId: asset.id,
        borrowerName: borrowerCtl.text.trim(),
        borrowerContact: contactCtl.text.trim(),
        purpose: purposeCtl.text.trim(),
        dueAt: dueAt,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('ยืมครุภัณฑ์สำเร็จ');
    } catch (e) {
      _showMessage('ยืมครุภัณฑ์ไม่สำเร็จ: $e');
    }
  }

  Future<void> _returnCheckout(CheckoutRecord record) async {
    try {
      await service.returnAssetById(
        record.id,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('คืนครุภัณฑ์สำเร็จ');
    } catch (e) {
      _showMessage('คืนครุภัณฑ์ไม่สำเร็จ: $e');
    }
  }

  Future<void> _openMaintenanceDialog(AssetItem asset) async {
    final titleCtl = TextEditingController();
    final detailCtl = TextEditingController();
    final assigneeCtl = TextEditingController();
    DateTime? dueAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('สร้างใบงานซ่อม'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtl,
                    decoration: const InputDecoration(labelText: 'หัวข้อปัญหา'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailCtl,
                    decoration: const InputDecoration(labelText: 'รายละเอียด'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: assigneeCtl,
                    decoration: const InputDecoration(
                      labelText: 'ผู้รับผิดชอบ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueAt == null
                              ? 'ไม่กำหนดวันครบกำหนด'
                              : 'ครบกำหนด: ${DateFormat('dd/MM/yyyy').format(dueAt!)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked == null) return;
                          setDialogState(() => dueAt = picked);
                        },
                        child: const Text('เลือกวัน'),
                      ),
                    ],
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
                child: const Text('สร้าง'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;
    if (titleCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกหัวข้อปัญหา');
      return;
    }

    try {
      await service.createMaintenanceTicket(
        assetId: asset.id,
        title: titleCtl.text.trim(),
        description: detailCtl.text.trim(),
        assignedTo: assigneeCtl.text.trim(),
        dueAt: dueAt,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('สร้างใบงานซ่อมสำเร็จ');
    } catch (e) {
      _showMessage('สร้างใบงานซ่อมไม่สำเร็จ: $e');
    }
  }

  Future<void> _openAttachmentDialog(AssetItem asset) async {
    final nameCtl = TextEditingController();
    final urlCtl = TextEditingController();
    final noteCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เพิ่มไฟล์แนบ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'ชื่อไฟล์'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlCtl,
                decoration: const InputDecoration(labelText: 'ลิงก์/พาธไฟล์'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtl,
                decoration: const InputDecoration(labelText: 'หมายเหตุ'),
                maxLines: 2,
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
    );

    if (ok != true) return;
    if (nameCtl.text.trim().isEmpty || urlCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกชื่อไฟล์และลิงก์');
      return;
    }
    try {
      await service.addAttachment(
        assetId: asset.id,
        name: nameCtl.text.trim(),
        url: urlCtl.text.trim(),
        note: noteCtl.text.trim(),
        createdBy: access.activeUserName,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('เพิ่มไฟล์แนบแล้ว');
    } catch (e) {
      _showMessage('เพิ่มไฟล์แนบไม่สำเร็จ: $e');
    }
  }

  Future<void> _openTransferDialog(AssetItem asset) async {
    final locationCtl = TextEditingController(text: asset.location);
    final noteCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ย้ายที่ตั้ง'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationCtl,
                decoration: const InputDecoration(labelText: 'ที่ตั้งใหม่'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtl,
                decoration: const InputDecoration(labelText: 'หมายเหตุ'),
                maxLines: 2,
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
            child: const Text('ย้าย'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (locationCtl.text.trim().isEmpty) {
      _showMessage('กรุณากรอกที่ตั้ง');
      return;
    }
    try {
      await service.transferAssetLocation(
        asset.id,
        locationCtl.text.trim(),
        note: noteCtl.text.trim(),
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('อัปเดตที่ตั้งแล้ว');
    } catch (e) {
      _showMessage('ย้ายที่ตั้งไม่สำเร็จ: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case AssetService.statusNormal:
        return const Color(0xFF32C759);
      case AssetService.statusRepair:
        return const Color(0xFFFF9F0A);
      case AssetService.statusDisposed:
        return const Color(0xFF8E8E93);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManageCheckout = access.can(AssetService.permissionManageCheckout);
    final canManageMaintenance = access.can(
      AssetService.permissionManageMaintenance,
    );
    final canManageAttachments = access.can(
      AssetService.permissionManageAttachments,
    );
    final canEditAssets = access.can(AssetService.permissionEditAsset);

    return Scaffold(
      appBar: AppBar(title: const Text('การดำเนินการครุภัณฑ์')),
      body: StreamBuilder<AssetItem?>(
        stream: service.watchById(widget.assetId),
        builder: (context, assetSnap) {
          if (assetSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (assetSnap.hasError) {
            return const Center(child: Text('โหลดข้อมูลครุภัณฑ์ไม่สำเร็จ'));
          }

          final asset = assetSnap.data;
          if (asset == null) {
            return const Center(child: Text('ไม่พบข้อมูลครุภัณฑ์'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.type.isEmpty ? asset.assetCode : asset.type,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('รหัส: ${asset.assetCode}'),
                      Text(
                        'ที่ตั้ง: ${asset.location.isEmpty ? '-' : asset.location}',
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(asset.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          asset.status,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
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
                      const Text(
                        'การยืม / คืน',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<CheckoutRecord>>(
                        stream: service.watchCheckoutRecords(
                          assetId: asset.id,
                          activeOnly: true,
                          limit: 1,
                        ),
                        builder: (context, snap) {
                          final active = (snap.data ?? []).isEmpty
                              ? null
                              : (snap.data ?? []).first;
                          if (active == null) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: canManageCheckout
                                    ? () => _openCheckoutDialog(asset)
                                    : null,
                                icon: const Icon(
                                  Icons.assignment_returned_outlined,
                                ),
                                label: const Text('ยืมออก'),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ผู้ยืม: ${active.borrowerName}'),
                              if (active.purpose.isNotEmpty)
                                Text('วัตถุประสงค์: ${active.purpose}'),
                              if (active.dueAt != null)
                                Text(
                                  'ครบกำหนด: ${DateFormat('dd/MM/yyyy').format(active.dueAt!)}',
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed: canManageCheckout
                                        ? () => _returnCheckout(active)
                                        : null,
                                    icon: const Icon(Icons.assignment_return),
                                    label: const Text('คืน'),
                                  ),
                                ],
                              ),
                            ],
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'งานซ่อมบำรุง',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'เพิ่มใบงาน',
                            onPressed: canManageMaintenance
                                ? () => _openMaintenanceDialog(asset)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      StreamBuilder<List<MaintenanceTicket>>(
                        stream: service.watchMaintenanceTickets(
                          assetId: asset.id,
                          openOnly: true,
                          limit: 20,
                        ),
                        builder: (context, snap) {
                          final tickets = snap.data ?? const [];
                          if (tickets.isEmpty) {
                            return const Text(
                              'ไม่มีใบงานซ่อมที่เปิดอยู่',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: tickets.map((ticket) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(ticket.title),
                                subtitle: Text(
                                  '${_maintenanceStatusLabel(ticket.status)}'
                                  '${ticket.dueAt == null ? '' : ' • ครบกำหนด ${DateFormat('dd/MM/yyyy').format(ticket.dueAt!)}'}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    service.updateMaintenanceStatus(
                                      ticket.id,
                                      v,
                                      actorName: access.activeUserName,
                                      actorRole: access.activeRole,
                                    );
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: AssetService.maintenanceInProgress,
                                      child: Text('เปลี่ยนเป็นกำลังดำเนินการ'),
                                    ),
                                    PopupMenuItem(
                                      value: AssetService.maintenanceDone,
                                      child: Text('เปลี่ยนเป็นเสร็จสิ้น'),
                                    ),
                                    PopupMenuItem(
                                      value: AssetService.maintenanceCancelled,
                                      child: Text('ยกเลิก'),
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ไฟล์แนบ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: canManageAttachments
                                ? () => _openAttachmentDialog(asset)
                                : null,
                            icon: const Icon(Icons.attach_file),
                          ),
                        ],
                      ),
                      StreamBuilder<List<AssetAttachment>>(
                        stream: service.watchAttachments(asset.id, limit: 30),
                        builder: (context, snap) {
                          final attachments = snap.data ?? const [];
                          if (attachments.isEmpty) {
                            return const Text(
                              'ไม่มีไฟล์แนบ',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: attachments.map((a) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(a.name),
                                subtitle: Text(a.note.isEmpty ? a.url : a.note),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'คัดลอกลิงก์',
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: a.url),
                                        );
                                        _showMessage('คัดลอกลิงก์แล้ว');
                                      },
                                      icon: const Icon(Icons.copy, size: 18),
                                    ),
                                    IconButton(
                                      tooltip: 'ลบ',
                                      onPressed: canManageAttachments
                                          ? () => service.removeAttachment(
                                              a.id,
                                              actorName: access.activeUserName,
                                              actorRole: access.activeRole,
                                            )
                                          : null,
                                      icon: const Icon(
                                        Icons.delete_outline,
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
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'ย้ายที่ตั้ง',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: canEditAssets
                            ? () => _openTransferDialog(asset)
                            : null,
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('ย้าย'),
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
                      const Text(
                        'ประวัติการทำรายการล่าสุด',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<AssetAuditLog>>(
                        stream: service.watchAuditLogs(
                          entityType: 'asset',
                          entityId: asset.id,
                          limit: 20,
                        ),
                        builder: (context, snap) {
                          final logs = snap.data ?? const [];
                          if (logs.isEmpty) {
                            return const Text(
                              'ยังไม่มีบันทึก',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: logs.map((log) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(log.action),
                                subtitle: Text(
                                  '${log.message}\n${df.format(log.createdAt)} • ${log.actorName}',
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
          );
        },
      ),
    );
  }
}
