import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthResult {
  final bool success;
  final String? errorMessage;

  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
  });
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static const String _keyPhone = 'bio_linked_phone';
  static const String _keyName = 'bio_linked_name';
  static const String _keyToken = 'bio_linked_token';
  static const String _keyEnabled = 'bio_enabled';

  /// هل الجهاز يدعم فحص البصمة؟
  static Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// هل توجد بصمة مسجلة في الهاتف؟
  static Future<bool> hasEnrolledBiometrics() async {
    if (kIsWeb) return false;
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// طلب فحص البصمة الحقيقي عبر مستشعر أندرويد (BiometricPrompt) مع تفاصيل النتيجة
  static Future<BiometricAuthResult> authenticateWithResult({
    required String localizedReason,
    bool isArabic = true,
  }) async {
    if (kIsWeb) {
      return BiometricAuthResult(
        success: false,
        errorMessage: isArabic
            ? 'مستشعر البصمة الحقيقي متاح حصرياً عبر تطبيق الهاتف (Android).'
            : 'Hardware fingerprint sensor is only available on Android mobile app.',
      );
    }

    try {
      final supported = await isDeviceSupported();
      if (!supported) {
        return BiometricAuthResult(
          success: false,
          errorMessage: isArabic
              ? 'هذا الجهاز لا يدعم مستشعر البصمة الحيوية.'
              : 'This device does not support biometric hardware.',
        );
      }

      // محاولة التحقق عبر نافذة أندرويد الأصلية
      final didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );

      if (didAuthenticate) {
        return const BiometricAuthResult(success: true);
      } else {
        return BiometricAuthResult(
          success: false,
          errorMessage: isArabic
              ? 'تم إلغاء المصادقة أو لم تتطابق البصمة.'
              : 'Biometric authentication cancelled or unrecognized.',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: ${e.code} - ${e.message}');
      String msg;
      if (e.code == 'NotAvailable') {
        msg = isArabic
            ? 'مستشعر البصمة غير متاح حالياً على هذا الهاتف.'
            : 'Biometrics not available on this device.';
      } else if (e.code == 'NotEnrolled') {
        msg = isArabic
            ? 'لا توجد بصمات مسجلة في هاتفك. يرجى إضافة بصمة إصبع في إعدادات الهاتف أولاً.'
            : 'No biometrics enrolled. Please set up fingerprint in phone settings.';
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        msg = isArabic
            ? 'تم قفل البصمة مؤقتاً لكثرة المحاولات. استخدم قفل الشاشة أولاً.'
            : 'Biometric locked out. Please unlock your phone first.';
      } else {
        msg = isArabic
            ? 'فشلت قراءة البصمة: ${e.message ?? e.code}'
            : 'Fingerprint failed: ${e.message ?? e.code}';
      }
      return BiometricAuthResult(success: false, errorMessage: msg);
    } catch (e) {
      debugPrint('Biometric general error: $e');
      return BiometricAuthResult(
        success: false,
        errorMessage: isArabic ? 'حدث خطأ أثناء فحص البصمة' : 'Biometric error occurred',
      );
    }
  }

  /// التوافق مع الكود السابق الذي ينتظر bool
  static Future<bool> authenticate({required String localizedReason}) async {
    final result = await authenticateWithResult(localizedReason: localizedReason);
    return result.success;
  }

  /// حفظ بيانات المستخدم المرتبط بالبصمة
  static Future<void> saveLinkedUser({
    required String phone,
    required String name,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, phone.trim());
    await prefs.setString(_keyName, name.trim());
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_keyToken, token);
    }
    await prefs.setBool(_keyEnabled, true);
  }

  /// جلب بيانات المستخدم المرتبط بالبصمة
  static Future<Map<String, String>?> getLinkedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_keyPhone);
    final name = prefs.getString(_keyName);
    final token = prefs.getString(_keyToken) ?? '';
    final enabled = prefs.getBool(_keyEnabled) ?? false;
    if (enabled && phone != null && phone.trim().isNotEmpty) {
      return {
        'phone': phone.trim(),
        'name': name?.trim() ?? '',
        'token': token,
      };
    }
    return null;
  }

  /// التحقق من وجود حساب مرتبط بالبصمة
  static Future<bool> hasLinkedUser() async {
    final linked = await getLinkedUser();
    return linked != null && linked['phone']!.isNotEmpty;
  }

  /// إزالة الحساب المرتبط
  static Future<void> clearLinkedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyName);
    await prefs.remove(_keyToken);
    await prefs.setBool(_keyEnabled, false);
  }
}
