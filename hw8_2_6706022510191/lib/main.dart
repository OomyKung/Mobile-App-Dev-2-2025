import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserList(),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final data = await DatabaseHelper.instance.getUsers();
    setState(() => users = data);
  }

  Future<void> deleteAll() async {
    await DatabaseHelper.instance.deleteAllUsers();
    await fetchUsers();
  }

  void addUserDialog() {
    final username = TextEditingController();
    final email = TextEditingController();
    final pwd = TextEditingController();
    final weight = TextEditingController();
    final height = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User (BMI)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: pwd,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: weight,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: height,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final w = double.tryParse(weight.text);
              final h = double.tryParse(height.text);

              if (username.text.trim().isEmpty ||
                  email.text.trim().isEmpty ||
                  pwd.text.trim().isEmpty ||
                  w == null ||
                  h == null ||
                  w <= 0 ||
                  h <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }

              final user = User(
                username: username.text.trim(),
                email: email.text.trim(),
                pwd: pwd.text,
                weight: w,
                height: h,
              );

              await DatabaseHelper.instance.insertUser(user);
              await fetchUsers();

              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void editUserDialog(User oldUser) {
    final username = TextEditingController(text: oldUser.username);
    final email = TextEditingController(text: oldUser.email);
    final pwd = TextEditingController(text: oldUser.pwd);
    final weight = TextEditingController(text: oldUser.weight.toString());
    final height = TextEditingController(text: oldUser.height.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User (BMI)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: pwd,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: weight,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: height,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final w = double.tryParse(weight.text);
              final h = double.tryParse(height.text);

              if (username.text.trim().isEmpty ||
                  email.text.trim().isEmpty ||
                  pwd.text.trim().isEmpty ||
                  w == null ||
                  h == null ||
                  w <= 0 ||
                  h <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }

              // ✅ สร้าง User ใหม่ (BMI/BMI Type จะคำนวณใหม่จาก constructor อัตโนมัติ)
              final updated = User(
                id: oldUser.id,
                username: username.text.trim(),
                email: email.text.trim(),
                pwd: pwd.text,
                weight: w,
                height: h,
              );

              await DatabaseHelper.instance.updateUser(updated);
              await fetchUsers();

              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void openDetail(User u) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserDetail(user: u)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show User List'),
        actions: [
          IconButton(
            tooltip: 'Delete all',
            icon: const Icon(Icons.delete_forever),
            onPressed: deleteAll,
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text('No data yet.\nPress + to add user.'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) {
                final u = users[i];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left icon / bmi picture
                          ClipOval(
                            child: Image.asset(
                              u.bmiImagePath,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.account_circle, size: 42),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // middle text (tap to open detail)
                          Expanded(
                            child: InkWell(
                              onTap: () => openDetail(u),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Username : ${u.username}'),
                                  Text('Email : ${u.email}'),
                                  Text('Password : ${"*" * u.pwd.length}'),
                                  Text(
                                      'Weight: ${u.weight.toStringAsFixed(1)} kg'),
                                  Text(
                                      'Height: ${u.height.toStringAsFixed(1)} cm'),
                                  Text('BMI: ${u.bmi.toStringAsFixed(2)}'),
                                  Text('BMI TYPE: ${u.bmiType}'),
                                  Text(u.healthMessage),
                                ],
                              ),
                            ),
                          ),

                          // right actions
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () => editUserDialog(u), // ✅ ทำงานจริง
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await DatabaseHelper.instance.deleteUser(u.id!);
                                  await fetchUsers();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserDetail extends StatelessWidget {
  final User user;
  const UserDetail({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              user.bmiImagePath,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 80),
            ),
            const SizedBox(height: 12),
            Text(
              user.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('BMI: ${user.bmi.toStringAsFixed(2)}'),
            Text('BMI TYPE: ${user.bmiType}'),
            const SizedBox(height: 8),
            Text(
              user.healthMessage,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
