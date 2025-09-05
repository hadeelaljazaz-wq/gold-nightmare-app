import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class BatchOperationsPanel extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onApproveAll;
  final VoidCallback onRejectAll;
  final VoidCallback onClearSelection;

  const BatchOperationsPanel({
    super.key,
    required this.selectedCount,
    required this.onApproveAll,
    required this.onRejectAll,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withAlpha(26),
            const Color(0xFFD4AF37).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.checklist, color: const Color(0xFFD4AF37), size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'تم تحديد $selectedCount مستخدم',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearSelection,
                child: Text(
                  'إلغاء التحديد',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      () => _showConfirmationDialog(
                        context,
                        'موافقة جماعية',
                        'هل أنت متأكد من موافقة $selectedCount مستخدم؟',
                        onApproveAll,
                        Colors.green,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.check_circle, size: 4.w),
                  label: Text(
                    'موافقة الكل',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      () => _showConfirmationDialog(
                        context,
                        'رفض جماعي',
                        'هل أنت متأكد من رفض $selectedCount مستخدم؟',
                        onRejectAll,
                        Colors.red,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.block, size: 4.w),
                  label: Text(
                    'رفض الكل',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
    Color color,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2D2D2D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            content: Text(
              message,
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'تأكيد',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }
}
