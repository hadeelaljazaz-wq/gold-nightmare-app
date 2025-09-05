import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;

  const EmailInputWidget({
    super.key,
    required this.controller,
    this.isLoading = false,
  });

  @override
  State<EmailInputWidget> createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget> {
  bool _isFocused = false;
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = widget.controller.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final isValid = emailRegex.hasMatch(email) && email.isNotEmpty;

    if (isValid != _isValidEmail) {
      setState(() {
        _isValidEmail = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.royalSurface.withValues(alpha: 0.9),
            AppTheme.surfaceColor.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalBlue.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color:
              _isFocused
                  ? AppTheme.aiBlue
                  : _isValidEmail
                  ? AppTheme.luxuryGold
                  : AppTheme.royalBlue.withValues(alpha: 0.3),
          width: _isFocused ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email input field
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              enabled: !widget.isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isFocused ? AppTheme.aiBlue : AppTheme.textAccent,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'example@domain.com',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(3.w),
                  child: Icon(
                    Icons.email_outlined,
                    color:
                        _isFocused
                            ? AppTheme.aiBlue
                            : _isValidEmail
                            ? AppTheme.luxuryGold
                            : AppTheme.textAccent,
                    size: 22,
                  ),
                ),
                suffixIcon:
                    widget.controller.text.isNotEmpty
                        ? Container(
                          padding: EdgeInsets.all(3.w),
                          child:
                              _isValidEmail
                                  ? Icon(
                                    Icons.check_circle,
                                    color: AppTheme.luxuryGold,
                                    size: 20,
                                  )
                                  : Icon(
                                    Icons.error_outline,
                                    color: AppTheme.warningRed,
                                    size: 20,
                                  ),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.5.h,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
          ),

          // Email suggestions (if any)
          if (_isFocused && widget.controller.text.isNotEmpty && !_isValidEmail)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.royalSurface.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.largeRadius),
                  bottomRight: Radius.circular(AppTheme.largeRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اقتراحات:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...['@gmail.com', '@yahoo.com', '@hotmail.com'].map(
                    (domain) => GestureDetector(
                      onTap: () {
                        final currentText = widget.controller.text;
                        if (currentText.contains('@')) {
                          return;
                        }
                        widget.controller.text = currentText + domain;
                        widget
                            .controller
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: widget.controller.text.length),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.aiBlue,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.controller.text.split('@')[0]}$domain',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textAccent,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
