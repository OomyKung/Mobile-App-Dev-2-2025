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
              title: const Text('Check Out Asset'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: borrowerCtl,
                      decoration: const InputDecoration(
                        labelText: 'Borrower name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contactCtl,
                      decoration: const InputDecoration(labelText: 'Contact'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: purposeCtl,
                      decoration: const InputDecoration(labelText: 'Purpose'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dueAt == null
                                ? 'No due date'
                                : 'Due: ${DateFormat('dd/MM/yyyy').format(dueAt!)}',
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
                          child: const Text('Pick due date'),
                        ),
                      ],
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
                  child: const Text('Check Out'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    if (borrowerCtl.text.trim().isEmpty) {
      _showMessage('Borrower name is required');
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
      _showMessage('Checked out successfully');
    } catch (e) {
      _showMessage('Checkout failed: $e');
    }
  }

  Future<void> _returnCheckout(CheckoutRecord record) async {
    try {
      await service.returnAssetById(
        record.id,
        actorName: access.activeUserName,
        actorRole: access.activeRole,
      );
      _showMessage('Returned successfully');
    } catch (e) {
      _showMessage('Return failed: $e');
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
            title: const Text('Create Maintenance Ticket'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtl,
                    decoration: const InputDecoration(labelText: 'Issue title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailCtl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: assigneeCtl,
                    decoration: const InputDecoration(labelText: 'Assigned to'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueAt == null
                              ? 'No due date'
                              : 'Due: ${DateFormat('dd/MM/yyyy').format(dueAt!)}',
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
                        child: const Text('Pick'),
                      ),
                    ],
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
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;
    if (titleCtl.text.trim().isEmpty) {
      _showMessage('Issue title is required');
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
      _showMessage('Maintenance ticket created');
    } catch (e) {
      _showMessage('Create ticket failed: $e');
    }
  }

  Future<void> _openAttachmentDialog(AssetItem asset) async {
    final nameCtl = TextEditingController();
    final urlCtl = TextEditingController();
    final noteCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Attachment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlCtl,
                decoration: const InputDecoration(
                  labelText: 'URL / storage path',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtl,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 2,
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
    );

    if (ok != true) return;
    if (nameCtl.text.trim().isEmpty || urlCtl.text.trim().isEmpty) {
      _showMessage('Name and URL are required');
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
      _showMessage('Attachment added');
    } catch (e) {
      _showMessage('Add attachment failed: $e');
    }
  }

  Future<void> _openTransferDialog(AssetItem asset) async {
    final locationCtl = TextEditingController(text: asset.location);
    final noteCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationCtl,
                decoration: const InputDecoration(labelText: 'New location'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtl,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 2,
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
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (locationCtl.text.trim().isEmpty) {
      _showMessage('Location is required');
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
      _showMessage('Location updated');
    } catch (e) {
      _showMessage('Transfer failed: $e');
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
      appBar: AppBar(title: const Text('Asset Operations')),
      body: StreamBuilder<AssetItem?>(
        stream: service.watchById(widget.assetId),
        builder: (context, assetSnap) {
          if (assetSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (assetSnap.hasError) {
            return const Center(child: Text('Failed to load asset'));
          }

          final asset = assetSnap.data;
          if (asset == null) {
            return const Center(child: Text('Asset not found'));
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
                      Text('Code: ${asset.assetCode}'),
                      Text(
                        'Location: ${asset.location.isEmpty ? '-' : asset.location}',
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
                        'Checkout / Return',
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
                                label: const Text('Check Out'),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Borrower: ${active.borrowerName}'),
                              if (active.purpose.isNotEmpty)
                                Text('Purpose: ${active.purpose}'),
                              if (active.dueAt != null)
                                Text(
                                  'Due: ${DateFormat('dd/MM/yyyy').format(active.dueAt!)}',
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed: canManageCheckout
                                        ? () => _returnCheckout(active)
                                        : null,
                                    icon: const Icon(Icons.assignment_return),
                                    label: const Text('Return'),
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
                              'Maintenance',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Add ticket',
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
                              'No active maintenance ticket',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          return Column(
                            children: tickets.map((ticket) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(ticket.title),
                                subtitle: Text(
                                  '${ticket.status}'
                                  '${ticket.dueAt == null ? '' : ' • Due ${DateFormat('dd/MM/yyyy').format(ticket.dueAt!)}'}',
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
                                      child: Text('Set In Progress'),
                                    ),
                                    PopupMenuItem(
                                      value: AssetService.maintenanceDone,
                                      child: Text('Set Done'),
                                    ),
                                    PopupMenuItem(
                                      value: AssetService.maintenanceCancelled,
                                      child: Text('Cancel'),
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
                              'Attachments',
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
                              'No attachment',
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
                                      tooltip: 'Copy URL',
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: a.url),
                                        );
                                        _showMessage('Copied URL');
                                      },
                                      icon: const Icon(Icons.copy, size: 18),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove',
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
                          'Transfer Location',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: canEditAssets
                            ? () => _openTransferDialog(asset)
                            : null,
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Transfer'),
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
                        'Recent Audit',
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
                              'No audit entry',
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
