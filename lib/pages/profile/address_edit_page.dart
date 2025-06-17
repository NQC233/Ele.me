import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../models/address.dart';
import '../../config/app_theme.dart';

///
/// 地址编辑页面 (已重构)
///
/// 用于新增或修改用户地址信息。
///
class AddressEditPage extends StatefulWidget {
  final Address? initialAddress;
  const AddressEditPage({super.key, this.initialAddress});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _phone;
  late String _province;
  late String _city;
  late String _district;
  late String _detail;
  
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，用传入的地址初始化表单
    if (widget.initialAddress != null) {
      _name = widget.initialAddress!.receiverName;
      _phone = widget.initialAddress!.receiverPhone;
      _province = widget.initialAddress!.province;
      _city = widget.initialAddress!.city;
      _district = widget.initialAddress!.district;
      _detail = widget.initialAddress!.detail;
      _isDefault = widget.initialAddress!.isDefault;
    } else {
      // 新增模式，使用空值或默认值
      _name = '';
      _phone = '';
      _province = '';
      _city = '';
      _district = '';
      _detail = '';
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (widget.initialAddress != null) {
        // 编辑已有地址
        final updatedAddress = widget.initialAddress!.copyWith(
          receiverName: _name,
          receiverPhone: _phone,
          province: _province,
          city: _city,
          district: _district,
          detail: _detail,
          isDefault: _isDefault,
        );
        
        await userProvider.updateAddress(updatedAddress);
      } else {
        // 添加新地址
        final newAddress = Address(
          id: '',  // ID由服务器生成
          userId: userProvider.user!.id,
          receiverName: _name,
          receiverPhone: _phone,
          province: _province,
          city: _city,
          district: _district,
          detail: _detail,
          isDefault: _isDefault,
        );
        
        await userProvider.addAddress(newAddress);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存地址失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialAddress != null ? '编辑收货地址' : '添加收货地址';
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: '联系人',
                        hintText: '请输入收货人姓名',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入联系人姓名';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(
                        labelText: '手机号码',
                        hintText: '请输入联系人手机号',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入手机号码';
                        }
                        if (value.length != 11) {
                          return '请输入11位手机号';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _phone = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _province,
                            decoration: const InputDecoration(
                              labelText: '省份',
                              hintText: '请输入省份',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入省份';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _province = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _city,
                            decoration: const InputDecoration(
                              labelText: '城市',
                              hintText: '请输入城市',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入城市';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _city = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _district,
                      decoration: const InputDecoration(
                        labelText: '区县',
                        hintText: '请输入区县',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入区县';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _district = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _detail,
                      decoration: const InputDecoration(
                        labelText: '详细地址',
                        hintText: '请输入详细地址，如街道、门牌号等',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入详细地址';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _detail = value!;
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('设为默认地址'),
                      value: _isDefault,
                      onChanged: (bool value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 