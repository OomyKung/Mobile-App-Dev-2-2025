import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'asset_image_view.dart';
import 'asset_service.dart';

class AssetFormPage extends StatefulWidget {
  final String? assetId;

  const AssetFormPage({super.key, this.assetId});

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

  String status = 'NORMAL';
  String? existingImageUrl;
  String? existingImageBase64;
  File? pickedImageFile;
  String? pickedImageBase64;
  bool loading = false;

  final assetService = AssetService();
  final picker = ImagePicker();

  bool get isEdit => widget.assetId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _load();
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
      ).showSnackBar(const SnackBar(content: Text('Asset not found')));
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

  Future<void> _pickImage() async {
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 55,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (x == null) return;

    final bytes = await x.readAsBytes();
    const maxBytes = 700 * 1024;
    if (bytes.length > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image too large. Please choose a smaller image.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      pickedImageFile = File(x.path);
      pickedImageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _save() async {
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
        const SnackBar(content: Text('This asset code already exists')),
      );
      return;
    }

    try {
      if (!isEdit) {
        final id = assetService.newAssetId();
        final imageBase64ToSave = pickedImageBase64;

        await assetService.createAssetWithId(id, {
          'assetCode': code,
          'type': typeCtl.text.trim(),
          'brand': brandCtl.text.trim(),
          'detail': detailCtl.text.trim(),
          'location': locationCtl.text.trim(),
          'status': status,
          'imageUrl': null,
          'imageBase64': imageBase64ToSave,
        });
      } else {
        final id = widget.assetId!;
        final imageBase64ToSave = pickedImageBase64 ?? existingImageBase64;
        final imageUrlToSave =
            pickedImageBase64 != null ? null : existingImageUrl;

        await assetService.updateAsset(id, {
          'assetCode': code,
          'type': typeCtl.text.trim(),
          'brand': brandCtl.text.trim(),
          'detail': detailCtl.text.trim(),
          'location': locationCtl.text.trim(),
          'status': status,
          'imageUrl': imageUrlToSave,
          'imageBase64': imageBase64ToSave,
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Updated successfully' : 'Added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('resource-exhausted') || message.contains('size')
                ? 'Image too large for Firestore. Please choose a smaller image.'
                : 'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String value) {
    switch (value) {
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
    final title = isEdit ? 'Edit Asset' : 'Add Asset';

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
                            label: const Text('Choose image'),
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
                              labelText: 'Asset code',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter asset code'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: typeCtl,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter type'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: brandCtl,
                            decoration: const InputDecoration(
                              labelText: 'Brand',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: detailCtl,
                            decoration: const InputDecoration(
                              labelText: 'Detail',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: locationCtl,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statusChoice('NORMAL', 'Normal'),
                              _statusChoice('REPAIR', 'Repair'),
                              _statusChoice('DISPOSED', 'Disposed'),
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
                              child: Text(isEdit ? 'Save changes' : 'Save'),
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
