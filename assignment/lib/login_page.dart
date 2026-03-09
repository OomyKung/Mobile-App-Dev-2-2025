import 'package:flutter/material.dart';

import 'asset_service.dart';

class LoginAccount {
  final String userId;
  final String displayName;
  final String username;
  final String password;
  final String role;

  const LoginAccount({
    required this.userId,
    required this.displayName,
    required this.username,
    required this.password,
    required this.role,
  });
}

const demoAccounts = <LoginAccount>[
  LoginAccount(
    userId: 'admin001',
    displayName: 'ผู้ดูแลระบบ',
    username: 'admin',
    password: 'admin123',
    role: AssetService.roleAdmin,
  ),
  LoginAccount(
    userId: 'staff001',
    displayName: 'เจ้าหน้าที่พัสดุ',
    username: 'staff',
    password: 'staff123',
    role: AssetService.roleStaff,
  ),
];

class LoginPage extends StatefulWidget {
  final ValueChanged<LoginAccount> onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;
  String? _error;

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

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _login() {
    final username = _usernameCtl.text.trim().toLowerCase();
    final password = _passwordCtl.text;

    LoginAccount? account;
    for (final item in demoAccounts) {
      if (item.username.toLowerCase() == username &&
          item.password == password) {
        account = item;
        break;
      }
    }

    if (account == null) {
      setState(() {
        _error = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
      });
      return;
    }

    setState(() {
      _error = null;
    });
    widget.onLoginSuccess(account);
  }

  void _fillAccount(LoginAccount account) {
    _usernameCtl.text = account.username;
    _passwordCtl.text = account.password;
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เข้าสู่ระบบจัดการครุภัณฑ์',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'เลือกเข้าสู่ระบบด้วยผู้ใช้ตัวอย่าง 2 บัญชี',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameCtl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อผู้ใช้',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordCtl,
                        obscureText: _obscure,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _obscure = !_obscure);
                            },
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
                          label: const Text('เข้าสู่ระบบ'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'บัญชีตัวอย่าง',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...demoAccounts.map(
                        (account) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${account.username} / ${account.password}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${account.displayName} (${_roleLabel(account.role)})',
                          ),
                          trailing: TextButton(
                            onPressed: () => _fillAccount(account),
                            child: const Text('ใช้บัญชีนี้'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
