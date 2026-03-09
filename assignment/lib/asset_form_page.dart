import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'access_control.dart';
import 'asset_image_view.dart';
import 'asset_service.dart';

class AssetFormPage extends StatefulWidget {
  final String? assetId;
  final String? initialAssetCode;

  const AssetFormPage({super.key, this.assetId, this.initialAssetCode});

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  final _formKey = GlobalKey<FormState>();

  final assetCodeCtl = TextEditingController();
  final typeCtl = TextEditingController();
  final brandCtl = TextEditingController();
  final detailCtl = TextEditingController();
  final locationCtl = TextEditingController();

  String status = AssetService.statusNormal;
  String? existingImageUrl;
  String? existingImageBase64;
  File? pickedImageFile;
  String? pickedImageBase64;
  bool loading = false;

  final assetService = AssetService();
  final access = AccessControl.instance;
  final picker = ImagePicker();

  bool get isEdit => widget.assetId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _load();
      return;
    }
    final presetCode = widget.initialAssetCode?.trim() ?? '';
    if (presetCode.isNotEmpty) {
      assetCodeCtl.text = assetService.normalizeAssetCode(presetCode);
    }
  }

  @override
  void dispose() {
    assetCodeCtl.dispose();
    typeCtl.dispose();
    brandCtl.dispose();
    detailCtl.dispose();
    locationCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final item = await assetService.getById(widget.assetId!);
    if (!mounted) return;

    if (item == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลครุภัณฑ์')));
      Navigator.pop(context);
      return;
    }

    assetCodeCtl.text = item.assetCode;
    typeCtl.text = item.type;
    brandCtl.text = item.brand;
    detailCtl.text = item.detail;
    locationCtl.text = item.location;
    status = item.status;
    existingImageUrl = item.imageUrl;
    existingImageBase64 = item.imageBase64;

    setState(() => loading = false);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final x = await picker.pickImage(
        source: source,
        imageQuality: 55,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (x == null) return;

      final bytes = await x.readAsBytes();
      const maxBytes = 700 * 1024;
      if (bytes.length > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('รูปภาพมีขนาดใหญ่เกินไป')));
        return;
      }

      if (!mounted) return;
      setState(() {
        pickedImageFile = File(x.path);
        pickedImageBase64 = base64Encode(bytes);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเข้าถึงกล้องหรือแกลเลอรีได้')),
      );
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('ถ่ายรูป'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('เลือกจากแกลเลอรี'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (!mounted || source == null) return;
    await _pickImageFromSource(source);
  }

  Future<void> _save() async {
    final hasPermission = isEdit
        ? access.can(AssetService.permissionEditAsset)
        : access.can(AssetService.permissionCreateAsset);
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('คุณไม่มีสิทธิ์ใช้งาน')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final code = assetCodeCtl.text.trim();
    setState(() => loading = true);

    final exists = await assetService.assetCodeExists(
      code,
      exceptId: widget.assetId,
    );
    if (exists) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสครุภัณฑ์นี้มีอยู่แล้ว')),
      );
      return;
    }

    try {
      if (!isEdit) {
        final id = assetService.newAssetId();
        final imageBase64ToSave = pickedImageBase64;

        await assetService.createAssetWithId(
          id,
          {
            'assetCode': code,
            'type': typeCtl.text.trim(),
            'brand': brandCtl.text.trim(),
            'detail': detailCtl.text.trim(),
            'location': locationCtl.text.trim(),
            'status': status,
            'imageUrl': null,
            'imageBase64': imageBase64ToSave,
          },
          actorName: access.activeUserName,
          actorRole: access.activeRole,
        );
      } else {
        final id = widget.assetId!;
        final imageBase64ToSave = pickedImageBase64 ?? existingImageBase64;
        final imageUrlToSave = pickedImageBase64 != null
            ? null
            : existingImageUrl;

        await assetService.updateAsset(
          id,
          {
            'assetCode': code,
            'type': typeCtl.text.trim(),
            'brand': brandCtl.text.trim(),
            'detail': detailCtl.text.trim(),
            'location': locationCtl.text.trim(),
            'status': status,
            'imageUrl': imageUrlToSave,
            'imageBase64': imageBase64ToSave,
          },
          actorName: access.activeUserName,
          actorRole: access.activeRole,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'แก้ไขเรียบร้อย' : 'เพิ่มเรียบร้อย')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('resource-exhausted') || message.contains('size')
                ? 'รูปภาพใหญ่เกินขนาดที่ Firestore รองรับ กรุณาเลือกรูปเล็กลง'
                : 'เกิดข้อผิดพลาด: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String value) {
    switch (value) {
      case AssetService.statusNormal:
        return const Color(0xFF23B734);
      case AssetService.statusRepair:
        return const Color(0xFFE77A2B);
      case AssetService.statusDisposed:
        return const Color(0xFF8A8A8A);
      default:
        return const Color(0xFF6D6D6D);
    }
  }

  Widget _statusChoice(String value, String label) {
    final selected = status == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => status = value),
      backgroundColor: const Color(0xFF3A3A3A),
      selectedColor: _statusColor(value),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'แก้ไขครุภัณฑ์' : 'เพิ่มครุภัณฑ์';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          if (pickedImageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                pickedImageFile!,
                                height: 190,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (isEdit)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AssetImageView(
                                imageUrl: existingImageUrl,
                                imageBase64: existingImageBase64,
                                height: 190,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  height: 190,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.white54,
                                    size: 54,
                                  ),
                                ),
                                error: Container(
                                  height: 190,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.white54,
                                    size: 54,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 190,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.white54,
                                size: 54,
                              ),
                            ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('เลือกรูปภาพ'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: assetCodeCtl,
                            decoration: const InputDecoration(
                              labelText: 'รหัสครุภัณฑ์',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'กรุณากรอกรหัสครุภัณฑ์'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: typeCtl,
                            decoration: const InputDecoration(
                              labelText: 'ประเภท',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'กรุณากรอกประเภท'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: brandCtl,
                            decoration: const InputDecoration(
                              labelText: 'ยี่ห้อ',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: detailCtl,
                            decoration: const InputDecoration(
                              labelText: 'รายละเอียด',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: locationCtl,
                            decoration: const InputDecoration(
                              labelText: 'ที่ตั้ง',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'สถานะ',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statusChoice(AssetService.statusNormal, 'ปกติ'),
                              _statusChoice(AssetService.statusRepair, 'ชำรุด'),
                              _statusChoice(
                                AssetService.statusDisposed,
                                'จำหน่าย',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2D8CFF),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _save,
                              child: Text(isEdit ? 'บันทึกการแก้ไข' : 'บันทึก'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
