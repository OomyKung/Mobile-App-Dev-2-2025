import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowInf extends StatefulWidget {
  const ShowInf({Key? key}) : super(key: key);

  @override
  State<ShowInf> createState() => _ShowInfState();
}

class _ShowInfState extends State<ShowInf> {
  static const String baseUrl = "http://10.0.2.2:10000";

  List<dynamic> list = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();

  // -------------------------
  // GET /emp
  // -------------------------
  Future<void> listData() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/emp"),
        headers: {"Accept": "application/json"},
      );

      debugPrint("GET /emp status=${res.statusCode}");
      // debugPrint("GET /emp body=${res.body}");

      if (res.statusCode != 200) {
        debugPrint(res.body);
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        if (!mounted) return;
        setState(() => list = decoded);
        debugPrint("list length=${list.length}");
      } else {
        debugPrint("JSON is not a List: $decoded");
      }
    } catch (e) {
      debugPrint("GET /emp exception: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    listData();
  }

  // -------------------------
  // POST /create
  // -------------------------
  Future<bool> addData() async {
    final Map<String, dynamic> data = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "age": int.tryParse(_ageController.text.trim()),
      "major": _majorController.text.trim(),
    };

    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/create"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint("POST /create status=${res.statusCode}");
      debugPrint("POST /create body=${res.body}");

      if (res.statusCode == 200) {
        await listData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("POST /create exception: $e");
      return false;
    }
  }

  // -------------------------
  // PUT /update/<id>
  // -------------------------
  Future<void> updateData(int id) async {
    final Map<String, dynamic> data = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "age": int.tryParse(_ageController.text.trim()),
      "major": _majorController.text.trim(),
    };

    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      debugPrint("PUT /update/$id status=${res.statusCode}");
      debugPrint("PUT /update/$id body=${res.body}");

      if (res.statusCode == 200) {
        await listData();
      }
    } catch (e) {
      debugPrint("PUT /update exception: $e");
    }
  }

  // -------------------------
  // DELETE /delete/<id>
  // -------------------------
  Future<void> delData(int id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/delete/$id"),
        headers: {"Accept": "application/json"},
      );

      debugPrint("DELETE /delete/$id status=${res.statusCode}");
      debugPrint("DELETE /delete/$id body=${res.body}");

      if (res.statusCode == 200) {
        await listData();
      }
    } catch (e) {
      debugPrint("DELETE exception: $e");
    }
  }

  // -------------------------
  // Dialog: Add
  // -------------------------
  Future<void> showAddDialog() async {
    bool saving = false;

    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _ageController.clear();
    _majorController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('เพิ่มข้อมูล'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                    ),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Age"),
                    ),
                    TextField(
                      controller: _majorController,
                      decoration: const InputDecoration(labelText: "Major"),
                    ),
                    const SizedBox(height: 8),
                    if (saving)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);

                          final ok = await addData();

                          setDialogState(() => saving = false);

                          if (!context.mounted) return;

                          if (ok) {
                            Navigator.of(dialogContext).pop(); // ปิดเมื่อสำเร็จ
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "บันทึกไม่สำเร็จ: ตรวจสอบว่า Flask เปิดพอร์ต 10000 และ endpoint /create ใช้งานได้",
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('ยืนยัน'),
                ),
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('ยกเลิก'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------
  // Dialog: Edit
  // -------------------------
  Future<void> showEditDialog(Map<String, dynamic> item) async {
    final int id = int.parse(item["id"].toString());

    _nameController.text = (item["name"] ?? "").toString();
    _emailController.text = (item["email"] ?? "").toString();
    _phoneController.text = (item["phone"] ?? "").toString();
    _addressController.text = (item["address"] ?? "").toString();
    _ageController.text = (item["age"] ?? "").toString();
    _majorController.text = (item["major"] ?? "").toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูล ID: $id'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: _majorController,
                  decoration: const InputDecoration(labelText: "Major"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () async {
                await updateData(id);
                if (mounted) Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  // Dialog: Delete
  // -------------------------
  Future<void> showDeleteDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('ลบข้อมูล ID: $id'),
          content: const Text('ยืนยันการลบข้อมูล?'),
          actions: [
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () async {
                await delData(id);
                if (mounted) Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DB Test"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => listData(),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text("ยังไม่มีข้อมูลในระบบ"))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: Text(item["id"].toString()),
                    title: Text(item["name"].toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${item["email"] ?? ""}"),
                        Text("Phone: ${item["phone"] ?? ""}"),
                        Text("Address: ${item["address"] ?? ""}"),
                        Text("Age: ${item["age"] ?? ""}"),
                        Text("Major: ${item["major"] ?? ""}"),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 5,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => showDeleteDialog(
                            int.parse(item["id"].toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showAddDialog(),
      ),
    );
  }
}
