import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './user_status_card_widget.dart';

class UserListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Function(String, bool) onToggleStatus;

  const UserListWidget({
    super.key,
    required this.users,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.sp),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserStatusCardWidget(user: user, onToggleStatus: onToggleStatus);
      },
    );
  }
}
