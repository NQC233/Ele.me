import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../models/address.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/empty_placeholder.dart';
import '../../config/app_theme.dart';

///
/// 地址列表页面
///
class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的地址'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AppRoutes.router.push(AppRoutes.addressAdd);
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final addresses = userProvider.addresses;
          if (addresses.isEmpty) {
            return const EmptyPlaceholder(
              icon: Icons.location_off_outlined,
              title: '您还没有添加地址',
              subtitle: '添加一个地址以便我们为您配送',
            );
          }
          
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressItem(context, address, userProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, Address address, UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          address.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
          color: address.isDefault ? AppTheme.primaryColor : Colors.grey,
        ),
        title: Text('${address.province} ${address.city} ${address.district}'),
        subtitle: Text(address.detail),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppTheme.secondaryTextColor),
          onPressed: () {
            AppRoutes.router.push(AppRoutes.addressEdit, extra: address);
          },
        ),
        onTap: () {
          // 点击将地址设置为默认
          userProvider.setDefaultAddress(address.id);
        },
      ),
    );
  }
}