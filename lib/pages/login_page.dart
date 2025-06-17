import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';

///
/// 登录页面 (已重构)
///
/// 支持使用用户名/手机号/邮箱作为登录凭证
///
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _credentialController = TextEditingController();  // 重命名为凭证控制器
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
    _credentialController.dispose();  // 更新变量名
    _passwordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  // 密码登录逻辑
  void _loginWithPassword() async {
    final credential = _credentialController.text;  // 更新变量名
    final password = _passwordController.text;
    if (credential.isEmpty || password.isEmpty) {  // 更新变量名和提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录凭证或密码不能为空')),
      );
      return;
    }
    
    // 显示加载状态
    final loadingDialog = _showLoadingDialog();
    
    try {
      final success = await Provider.of<UserProvider>(context, listen: false)
          .login(credential, password);  // 直接使用对应的方法
      
      // 关闭加载对话框
      loadingDialog.dismiss();
      
      if (mounted) {
        if (success) {
          // 登录成功
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录成功')),
          );
          context.pop(); // 登录成功后返回上一页
        } else {
          // 登录失败但没有抛出异常
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录失败: 用户名或密码错误')),
          );
        }
      }
    } catch (error) {
      // 关闭加载对话框
      loadingDialog.dismiss();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $error')),
        );
      }
    }
  }

  // 显示加载对话框
  LoadingDialog _showLoadingDialog() {
    final dialog = LoadingDialog(context: context, message: '登录中...');
    dialog.show();
    return dialog;
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
            controller: _credentialController,  // 更新变量名
            decoration: const InputDecoration(
              labelText: '用户名/手机号/邮箱',  // 更新标签
              hintText: '请输入登录凭证',  // 更新提示文本
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,  // 更改为文本类型
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
            controller: _credentialController, // 更新变量名
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

/// 加载对话框
class LoadingDialog {
  final BuildContext context;
  final String message;
  late BuildContext _dialogContext;

  LoadingDialog({required this.context, required this.message});

  void show() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        _dialogContext = ctx;
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void dismiss() {
    try {
      Navigator.of(_dialogContext).pop();
    } catch (e) {
      // 忽略对话框已关闭的错误
    }
  }
} 