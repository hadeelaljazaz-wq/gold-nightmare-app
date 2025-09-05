import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LicenseKeyInputWidget extends StatefulWidget {
  final Function(String) onKeyChanged;
  final bool isValidating;
  final bool isValid;
  final String? errorMessage;
  final bool hasInput; // New parameter

  const LicenseKeyInputWidget({
    super.key,
    required this.onKeyChanged,
    this.isValidating = false,
    this.isValid = false,
    this.errorMessage,
    this.hasInput = false, // New parameter
  });

  @override
  State<LicenseKeyInputWidget> createState() => _LicenseKeyInputWidgetState();
}

class _LicenseKeyInputWidgetState extends State<LicenseKeyInputWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showPasteButton = true;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // Enhanced animation for better user feedback
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.hasInput) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LicenseKeyInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start/stop animation based on input state
    if (widget.hasInput && !oldWidget.hasInput) {
      _animationController.repeat(reverse: true);
    } else if (!widget.hasInput && oldWidget.hasInput) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final formattedText = _formatLicenseKey(text);

    if (formattedText != text) {
      final cursorPosition = _controller.selection.baseOffset;
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(
          offset:
              _calculateNewCursorPosition(text, formattedText, cursorPosition),
        ),
      );
    }

    widget.onKeyChanged(formattedText.replaceAll('-', ''));

    setState(() {
      _showPasteButton = formattedText.isEmpty;
    });

    // Provide haptic feedback when typing
    if (formattedText.length % 8 == 0 && formattedText.isNotEmpty) {
      HapticFeedback.lightImpact();
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }

  String _formatLicenseKey(String input) {
    // Remove all non-alphanumeric characters
    String cleaned =
        input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

    // Limit to 40 characters
    if (cleaned.length > 40) {
      cleaned = cleaned.substring(0, 40);
    }

    // Add dashes every 8 characters
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 8 == 0) {
        formatted += '-';
      }
      formatted += cleaned[i];
    }

    return formatted;
  }

  int _calculateNewCursorPosition(
      String oldText, String newText, int oldPosition) {
    if (oldPosition <= 0) return 0;
    if (oldPosition >= newText.length) return newText.length;

    int dashesBeforeOld =
        oldText.substring(0, oldPosition).split('-').length - 1;
    int dashesBeforeNew = newText
            .substring(0, oldPosition + (newText.length - oldText.length))
            .split('-')
            .length -
        1;

    return oldPosition + (dashesBeforeNew - dashesBeforeOld);
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _controller.text = clipboardData!.text!;
        _focusNode.requestFocus();
      }
    } catch (e) {
      // Handle clipboard access error silently
    }
  }

  Widget _buildValidationIcon() {
    if (widget.isValidating) {
      return SizedBox(
        width: 5.w,
        height: 5.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
        ),
      );
    }

    final codeLength = _controller.text.replaceAll('-', '').length;

    if (codeLength == 40) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: CustomIconWidget(
          iconName: widget.isValid ? 'check_circle' : 'error',
          color: widget.isValid ? AppTheme.accentGreen : AppTheme.warningRed,
          size: 5.w,
        ),
      );
    } else if (codeLength > 20) {
      // Show progress indicator for partial codes
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 5.w,
            height: 5.w,
            child: CircularProgressIndicator(
              value: codeLength / 40.0,
              strokeWidth: 2,
              backgroundColor: AppTheme.borderColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
            ),
          ),
          Text(
            '${(codeLength / 40.0 * 100).round()}%',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.accentGreen,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return SizedBox(width: 5.w);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasInput ? _pulseAnimation.value : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مفتاح الترخيص',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  // Show progress when user is typing
                  if (widget.hasInput)
                    AnimatedOpacity(
                      opacity: widget.hasInput ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${_controller.text.replaceAll('-', '').length}/40',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color:
                              _controller.text.replaceAll('-', '').length == 40
                                  ? AppTheme.accentGreen
                                  : AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppTheme.accentGreen
                        : (widget.errorMessage != null
                            ? AppTheme.warningRed
                            : (widget.hasInput
                                ? AppTheme.accentGreen.withValues(alpha: 0.5)
                                : AppTheme.borderColor.withValues(alpha: 0.5))),
                    width: _focusNode.hasFocus || widget.hasInput ? 2 : 1,
                  ),
                  boxShadow: widget.hasInput
                      ? [
                          BoxShadow(
                            color: AppTheme.accentGreen.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: AppTheme.tradingDataMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 14.sp,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText:
                              'XXXXXXXX-XXXXXXXX-XXXXXXXX-XXXXXXXX-XXXXXXXX',
                          hintStyle: AppTheme.tradingDataMedium.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12.sp,
                            letterSpacing: 1.2,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-]')),
                        ],
                        onSubmitted: (_) {
                          // Auto-focus the activation button when code is complete
                          if (_controller.text.replaceAll('-', '').length ==
                                  40 &&
                              widget.isValid) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                    if (_showPasteButton) ...[
                      Container(
                        width: 1,
                        height: 4.h,
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                      ),
                      GestureDetector(
                        onTap: _pasteFromClipboard,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          child: CustomIconWidget(
                            iconName: 'content_paste',
                            color: AppTheme.accentGreen,
                            size: 5.w,
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _buildValidationIcon(),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.errorMessage != null) ...[
                SizedBox(height: 1.h),
                AnimatedOpacity(
                  opacity: widget.errorMessage != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warningRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warningRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'error_outline',
                          color: AppTheme.warningRed,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            widget.errorMessage!,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.warningRed,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 1.h),
              Text(
                'أدخل مفتاح الترخيص المكون من 40 حرف',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      },
    );
  }
}
