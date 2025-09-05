import 'package:flutter/material.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/analysis_results/analysis_results.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/ai_analysis_processing/ai_analysis_processing.dart';
import '../presentation/license_key_activation/license_key_activation.dart';
import '../presentation/analysis_type_selection/analysis_type_selection.dart';
import '../presentation/ai_chat/ai_chat_screen.dart';
import '../presentation/chart_analysis_upload/chart_analysis_upload.dart';
import '../presentation/security_dashboard/security_dashboard.dart';
import '../presentation/admin_activation_codes/admin_activation_codes_screen.dart';
import '../presentation/otp_activation/otp_activation_screen.dart';
import '../presentation/email_registration/email_registration.dart';
import '../presentation/otp_verification/otp_verification.dart';
import '../presentation/password_creation/password_creation.dart';
import '../presentation/email_login/email_login.dart';
import '../presentation/admin_approval_pending/admin_approval_pending.dart';
import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/user_status_management/user_status_management.dart';

class AppRoutes {
  // Existing routes
  static const String splash = '/splash';
  static const String licenseKeyActivation = '/license-key-activation';

  // New OTP activation route
  static const String otpActivation = '/otp-activation';

  // New email-based authentication routes
  static const String emailRegistration = '/email-registration';
  static const String otpVerification = '/otp-verification';

  // New email authentication routes
  static const String passwordCreation = '/password-creation';
  static const String emailLogin = '/email-login';

  // Admin approval system routes
  static const String adminApprovalPending = '/admin-approval-pending';
  static const String adminDashboard = '/admin-dashboard';

  // User management route
  static const String userStatusManagement = '/user-status-management';

  static const String mainDashboard = '/main-dashboard';
  static const String analysisResults = '/analysis-results';
  static const String securityDashboard = '/security-dashboard';
  static const String aiAnalysisProcessing = '/ai-analysis-processing';
  static const String chartAnalysisUpload = '/chart-analysis-upload';
  static const String aiChat = '/ai-chat';
  static const String adminActivationCodes = '/admin-activation-codes';
  static const String analysisTypeSelection = '/analysis-type-selection';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    licenseKeyActivation: (context) => const LicenseKeyActivation(),
    emailRegistration: (context) => const EmailRegistration(),
    otpVerification: (context) => const OtpVerification(),
    otpActivation: (context) => const OtpActivationScreen(),
    adminApprovalPending: (context) => const AdminApprovalPending(),
    adminDashboard: (context) => const AdminDashboard(),
    userStatusManagement: (context) => const UserStatusManagement(),
    mainDashboard: (context) => const MainDashboard(),
    analysisResults: (context) => const AnalysisResults(),
    aiAnalysisProcessing: (context) => const AiAnalysisProcessing(),
    analysisTypeSelection: (context) => const AnalysisTypeSelection(),
    aiChat: (context) => const AIChatScreen(),
    chartAnalysisUpload: (context) => const ChartAnalysisUpload(),
    securityDashboard: (context) => const SecurityDashboard(),
    adminActivationCodes: (context) => const AdminActivationCodesScreen(),
    passwordCreation: (context) => const PasswordCreation(),
    emailLogin: (context) => const EmailLogin(),
  };
}
