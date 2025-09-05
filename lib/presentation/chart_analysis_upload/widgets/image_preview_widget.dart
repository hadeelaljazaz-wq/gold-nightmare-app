import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class ImagePreviewWidget extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const ImagePreviewWidget({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGreen.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            children: [
              Icon(
                Icons.image,
                color: AppTheme.accentGreen,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'معاينة الصورة المحددة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  color: AppTheme.warningRed,
                  size: 20.sp,
                ),
                tooltip: 'إزالة الصورة',
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Image preview
          Container(
            width: double.infinity,
            height: 30.h,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor.withAlpha(77),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        } else if (snapshot.hasError) {
                          return _buildErrorWidget();
                        } else {
                          return _buildLoadingWidget();
                        }
                      },
                    )
                  : Image.file(
                      File(image.path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorWidget();
                      },
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Image info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.textSecondary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'معلومات الصورة',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // File name
                _buildInfoRow(
                  'اسم الملف',
                  _extractFileName(image.name),
                ),

                // File size
                FutureBuilder<int>(
                  future: _getFileSize(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildInfoRow(
                        'حجم الملف',
                        _formatFileSize(snapshot.data!),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Quality indicator
                _buildInfoRow(
                  'جودة الصورة',
                  'عالية ✓',
                  valueColor: AppTheme.accentGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.surfaceColor,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentGreen,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.surfaceColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: AppTheme.warningRed,
            size: 12.w,
          ),
          SizedBox(height: 1.h),
          Text(
            'خطأ في تحميل الصورة',
            style: TextStyle(
              color: AppTheme.warningRed,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _extractFileName(String fullName) {
    if (fullName.length > 25) {
      return '${fullName.substring(0, 22)}...';
    }
    return fullName;
  }

  Future<int> _getFileSize() async {
    try {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return bytes.length;
      } else {
        final file = File(image.path);
        return await file.length();
      }
    } catch (e) {
      return 0;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}