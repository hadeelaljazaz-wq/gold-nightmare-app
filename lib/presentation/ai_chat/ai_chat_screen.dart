import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/claude_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ClaudeService _claudeService = ClaudeService();
  final ImagePicker _imagePicker = ImagePicker();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _connectionStatus = 'متصل';
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Animation controllers
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeService();

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _typingAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add welcome message with Gold Nightmare Analyst branding
    _addMessage(
      '📊 مرحباً! أنا Gold Nightmare Analyst - المحلل المالي الأسطوري\n\n🔥 أرسل لي تحليل مالي أو تشارت وسأقدم لك توصية احترافية باستخدام مدرسة الكابوس الذهبية\n\n📷 يمكنك أيضاً إرسال صور التشارتات للتحليل الفوري',
      isUser: false,
    );
  }

  void _initializeService() async {
    try {
      // Test connection
      final isConnected = await _claudeService.testConnection();
      if (mounted) {
        setState(() {
          _connectionStatus = isConnected ? 'متصل' : 'غير متصل';
        });
      }

      // Log configuration for debugging
      debugPrint(
        'Claude Service Configuration: ${_claudeService.getConfiguration()}',
      );
    } catch (e) {
      debugPrint('Failed to initialize Claude Service: $e');
      if (mounted) {
        setState(() {
          _connectionStatus = 'خطأ في الاتصال';
        });

        if (e is ClaudeServiceException) {
          _addMessage('خطأ في الإعداد: ${e.getUserMessage()}', isUser: false);
        }
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(child: _buildMessagesList()),

          // Selected image preview
          if (_selectedImageBytes != null) _buildImagePreview(),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textPrimary,
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen,
                  AppTheme.accentGreen.withValues(alpha: 0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'psychology',
              color: AppTheme.primaryDark,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gold Nightmare Analyst',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTyping ? 'يحلل التشارت...' : _connectionStatus,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _isTyping
                        ? AppTheme.accentGreen
                        : _connectionStatus == 'متصل'
                            ? AppTheme.accentGreen
                            : AppTheme.warningRed,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _clearChat,
          icon: CustomIconWidget(
            iconName: 'delete_outline',
            color: AppTheme.textSecondary,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _showSystemPromptDialog,
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.textSecondary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
            return _buildTypingIndicator();
          }

          final message = _messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: EdgeInsets.only(
        top: 1.h,
        bottom: 1.h,
        left: isUser ? 15.w : 0,
        right: isUser ? 0 : 15.w,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGreen,
                    AppTheme.accentGreen.withValues(alpha: 0.7)
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'psychology',
                color: AppTheme.primaryDark,
                size: 20,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Image preview if message has image
                if (message.imageBytes != null) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    constraints: BoxConstraints(
                      maxWidth: 60.w,
                      maxHeight: 30.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        isUser ? AppTheme.accentGreen : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: !isUser
                        ? Border.all(
                            color: AppTheme.borderColor.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color:
                          isUser ? AppTheme.primaryDark : AppTheme.textPrimary,
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  message.timestamp,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.accentGreen,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(top: 1.h, bottom: 1.h, right: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen,
                  AppTheme.accentGreen.withValues(alpha: 0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'psychology',
              color: AppTheme.primaryDark,
              size: 20,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: AppTheme.borderColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: AppTheme.accentGreen.withValues(
                            alpha: (i == 0)
                                ? _typingAnimation.value
                                : (i == 1)
                                    ? (_typingAnimation.value * 0.7)
                                    : (_typingAnimation.value * 0.4),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedImageName ?? 'صورة التشارت',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'جاهز للتحليل',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentGreen,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImageBytes = null;
                _selectedImageName = null;
              });
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final canSend = _messageController.text.trim().isNotEmpty && !_isTyping;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image picker button
            Container(
              decoration: BoxDecoration(
                color: _selectedImageBytes != null
                    ? AppTheme.accentGreen
                    : AppTheme.primaryDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _selectedImageBytes != null
                      ? AppTheme.accentGreen
                      : AppTheme.borderColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: _pickImage,
                icon: CustomIconWidget(
                  iconName: _selectedImageBytes != null
                      ? 'image'
                      : 'add_photo_alternate',
                  color: _selectedImageBytes != null
                      ? AppTheme.primaryDark
                      : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Text input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _selectedImageBytes != null
                        ? 'وصف إضافي للتشارت... (اختياري)'
                        : 'مثال: حلل سعر الذهب الآن، أو ارسل صورة التشارت',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 14.sp,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: (text) {
                    setState(() {}); // Rebuild to update send button state
                  },
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Send button - Always active when text is present or image is selected
            Container(
              decoration: BoxDecoration(
                color: canSend || _selectedImageBytes != null
                    ? AppTheme.accentGreen
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed:
                    (canSend || _selectedImageBytes != null) && !_isTyping
                        ? _sendMessage
                        : null,
                icon: CustomIconWidget(
                  iconName: 'send',
                  color: canSend || _selectedImageBytes != null
                      ? AppTheme.primaryDark
                      : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: ${e.toString()}'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    }
  }

  void _addMessage(String text, {required bool isUser, Uint8List? imageBytes}) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: _formatTimestamp(DateTime.now()),
          imageBytes: imageBytes,
        ),
      );
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    final imageBytes = _selectedImageBytes;
    final imageName = _selectedImageName;

    // Allow sending if we have text OR image
    if ((messageText.isEmpty && imageBytes == null) || _isTyping) return;

    HapticFeedback.lightImpact();

    // Add user message
    if (imageBytes != null) {
      _addMessage(
        messageText.isEmpty ? 'تحليل هذا التشارت' : messageText,
        isUser: true,
        imageBytes: imageBytes,
      );
    } else {
      _addMessage(messageText, isUser: true);
    }

    _messageController.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _isTyping = true;
    });

    try {
      String response;

      if (imageBytes != null) {
        // Send with image using multimodal capabilities
        final prompt = messageText.isEmpty
            ? 'حلل هذا التشارت المالي وقدم توصية احترافية'
            : messageText;
        response = await _claudeService.sendPromptWithImage(prompt, imageBytes);
      } else {
        // Send text only with Gold Nightmare system prompt
        response = await _claudeService.sendPrompt(messageText);
      }

      setState(() {
        _isTyping = false;
      });

      _addMessage(response, isUser: false);
    } on ClaudeServiceException catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addMessage('❌ خطأ: ${e.getUserMessage()}', isUser: false);

      debugPrint('Claude API error: $e');
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addMessage(
        '❌ عذراً، حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى.',
        isUser: false,
      );

      debugPrint('Unexpected chat error: $e');
    }
  }

  void _showSystemPromptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'psychology',
              color: AppTheme.accentGreen,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Gold Nightmare Analyst',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Prompt المُفعّل:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _claudeService.getSystemPrompt(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11.sp,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'ملاحظة: هذا النظام مُفعّل تلقائياً في كل محادثة',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentGreen,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(color: AppTheme.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'مسح المحادثة',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'هل تريد حقاً مسح جميع الرسائل؟',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addMessage(
                  '📊 مرحباً! أنا Gold Nightmare Analyst - المحلل المالي الأسطوري\n\n🔥 أرسل لي تحليل مالي أو تشارت وسأقدم لك توصية احترافية باستخدام مدرسة الكابوس الذهبية\n\n📷 يمكنك أيضاً إرسال صور التشارتات للتحليل الفوري',
                  isUser: false,
                );
              });
            },
            child: Text(
              'مسح',
              style: TextStyle(color: AppTheme.warningRed),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageBytes,
  });
}
