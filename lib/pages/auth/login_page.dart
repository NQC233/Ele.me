import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';

///
/// 登录页面
///
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  // 密码登录逻辑
  void _loginWithPassword() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;
    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('手机号或密码不能为空')),
      );
      return;
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .login(phone, password);
      if (mounted) {
        context.pop(); // 登录成功后返回上一页
      }
    } catch (error) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $error')),
        );
       }
    }
  }

  // UI 构建
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录/注册'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '密码登录'),
            Tab(text: '短信登录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPasswordLoginTab(),
          _buildSmsLoginTab(),
        ],
      ),
    );
  }

  // 密码登录 Tab
  Widget _buildPasswordLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _loginWithPassword,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }

  // 短信登录 Tab (UI only)
  Widget _buildSmsLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController, // 可与密码登录共用
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _smsController,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    hintText: '请输入验证码',
                    border: OutlineInputBorder(),
                  ),
                   keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // TODO: 实现发送验证码逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('验证码功能暂未实现')),
                  );
                },
                child: const Text('获取验证码'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('短信登录功能暂未实现')),
                  );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
} 