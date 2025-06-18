import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../config/app_theme.dart';

///
/// 登录页面 (已美化)
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
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // 清除焦点当切换标签时
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _credentialController.dispose();  
    _passwordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  // 密码登录逻辑
  void _loginWithPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final credential = _credentialController.text;
    final password = _passwordController.text;
    
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
            const SnackBar(
              content: Text('登录成功'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // 登录成功后返回上一页
        } else {
          // 登录失败但没有抛出异常
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录失败: 用户名或密码错误'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // 关闭加载对话框
      loadingDialog.dismiss();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: $error'),
            backgroundColor: Colors.red,
          ),
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
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 背景装饰
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.9),
                  theme.colorScheme.primary,
                ],
              ),
            ),
          ),
          
          // 主要内容
          SafeArea(
            child: Column(
              children: [
                // 头部Logo和欢迎信息
                const SizedBox(height: 40),
                Icon(
                  Icons.restaurant_rounded,
                  size: 70,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  '欢迎来到饿了么',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '美食随时随地，触手可得',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // 主要登录内容卡片
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab 导航栏
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            tabs: const [
                              Tab(text: '密码登录'),
                              Tab(text: '短信登录'),
                            ],
                          ),
                        ),
                        
                        // Tab 内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPasswordLoginTab(),
                              _buildSmsLoginTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 底部其他选项
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '没有账号？',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 注册功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('注册功能暂未实现')),
                          );
                        },
                        child: Text(
                          '立即注册',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // 密码登录 Tab
  Widget _buildPasswordLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 登录凭证输入框
            TextFormField(
              controller: _credentialController,
              decoration: InputDecoration(
                labelText: '用户名/手机号/邮箱',
                hintText: '请输入登录凭证',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入登录凭证';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // 密码输入框
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
              onFieldSubmitted: (_) => _loginWithPassword(),
            ),
            
            const SizedBox(height: 12),
            
            // 忘记密码链接
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: 忘记密码功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('忘记密码功能暂未实现')),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text('忘记密码？'),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 登录按钮
            ElevatedButton(
              onPressed: _loginWithPassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 第三方登录选项
            Center(
              child: Column(
                children: [
                  const Text(
                    '其他登录方式',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialLoginButton(
                        icon: Icons.wechat,
                        color: Colors.green,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('微信登录功能暂未实现')),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialLoginButton(
                        icon: Icons.phone_android,
                        color: Colors.orange,
                        onTap: () {
                          _tabController.animateTo(1);
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialLoginButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Apple登录功能暂未实现')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 第三方登录按钮
  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  // 短信登录 Tab
  Widget _buildSmsLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 手机号输入框
            TextFormField(
              controller: _credentialController,
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入手机号';
                }
                // TODO: 添加手机号格式验证
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // 验证码输入框
            TextFormField(
              controller: _smsController,
              decoration: InputDecoration(
                labelText: '验证码',
                hintText: '请输入验证码',
                prefixIcon: const Icon(Icons.security),
                suffixIcon: TextButton(
                  onPressed: () {
                    // TODO: 实现发送验证码逻辑
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('验证码功能暂未实现')),
                    );
                  },
                  child: const Text('获取验证码'),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入验证码';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 30),
            
            // 登录按钮
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('短信登录功能暂未实现')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 登录政策提示
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '登录即表示您同意《用户协议》和《隐私政策》',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
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