import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../models/address.dart';
import '../../config/app_theme.dart';

///
/// 地址编辑/添加页面
///
class AddressEditPage extends StatefulWidget {
  final Address? initialAddress;

  const AddressEditPage({Key? key, this.initialAddress}) : super(key: key);

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      final addr = widget.initialAddress!;
      _nameController.text = addr.name;
      _phoneController.text = addr.phone;
      _addressController.text = '${addr.province} ${addr.city} ${addr.district} ${addr.detail}';
      _isDefault = addr.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // 简单解析地址，真实应用需要更复杂的省市区选择器
      List<String> addressParts = _addressController.text.split(' ');
      
      final newAddress = Address(
        id: widget.initialAddress?.id ?? const Uuid().v4(),
        name: _nameController.text,
        phone: _phoneController.text,
        province: addressParts.isNotEmpty ? addressParts[0] : '',
        city: addressParts.length > 1 ? addressParts[1] : '',
        district: addressParts.length > 2 ? addressParts[2] : '',
        detail: addressParts.length > 3 ? addressParts.sublist(3).join(' ') : '',
        isDefault: _isDefault,
      );

      if (widget.initialAddress != null) {
        userProvider.updateAddress(newAddress);
      } else {
        userProvider.addAddress(newAddress);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑地址' : '新增地址'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).deleteAddress(widget.initialAddress!.id);
                Navigator.of(context).pop();
              },
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '收货人'),
              validator: (value) => value!.isEmpty ? '请输入收货人姓名' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '手机号码'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? '请输入手机号码' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: '收货地址', hintText: '省 市 区 详细地址'),
              validator: (value) => value!.isEmpty ? '请输入收货地址' : null,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('设为默认地址'),
              value: _isDefault,
              onChanged: (bool value) {
                setState(() {
                  _isDefault = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('保存', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
} 