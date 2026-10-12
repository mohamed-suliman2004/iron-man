import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';

class CountryItem {
  final String nameAr;
  final String nameEn;
  final String dialCode;
  final String flag;

  const CountryItem({
    required this.nameAr,
    required this.nameEn,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryItem> kCountries = [
  CountryItem(nameAr: 'ليبيا', nameEn: 'Libya', dialCode: '+218', flag: '🇱🇾'),
  CountryItem(nameAr: 'مصر', nameEn: 'Egypt', dialCode: '+20', flag: '🇪🇬'),
  CountryItem(nameAr: 'تونس', nameEn: 'Tunisia', dialCode: '+216', flag: '🇹🇳'),
  CountryItem(nameAr: 'الجزائر', nameEn: 'Algeria', dialCode: '+213', flag: '🇩🇿'),
  CountryItem(nameAr: 'المغرب', nameEn: 'Morocco', dialCode: '+212', flag: '🇲🇦'),
  CountryItem(nameAr: 'السعودية', nameEn: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦'),
  CountryItem(nameAr: 'الإمارات', nameEn: 'UAE', dialCode: '+971', flag: '🇦🇪'),
  CountryItem(nameAr: 'قطر', nameEn: 'Qatar', dialCode: '+974', flag: '🇶🇦'),
  CountryItem(nameAr: 'الكويت', nameEn: 'Kuwait', dialCode: '+965', flag: '🇰🇼'),
  CountryItem(nameAr: 'عُمان', nameEn: 'Oman', dialCode: '+968', flag: '🇴🇲'),
  CountryItem(nameAr: 'البحرين', nameEn: 'Bahrain', dialCode: '+973', flag: '🇧🇭'),
  CountryItem(nameAr: 'الأردن', nameEn: 'Jordan', dialCode: '+962', flag: '🇯🇴'),
  CountryItem(nameAr: 'العراق', nameEn: 'Iraq', dialCode: '+964', flag: '🇮🇶'),
  CountryItem(nameAr: 'لبنان', nameEn: 'Lebanon', dialCode: '+961', flag: '🇱🇧'),
  CountryItem(nameAr: 'سوريا', nameEn: 'Syria', dialCode: '+963', flag: '🇸🇾'),
  CountryItem(nameAr: 'فلسطين', nameEn: 'Palestine', dialCode: '+970', flag: '🇵🇸'),
  CountryItem(nameAr: 'السودان', nameEn: 'Sudan', dialCode: '+249', flag: '🇸🇩'),
  CountryItem(nameAr: 'اليمن', nameEn: 'Yemen', dialCode: '+967', flag: '🇾🇪'),
  CountryItem(nameAr: 'تركيا', nameEn: 'Turkey', dialCode: '+90', flag: '🇹🇷'),
  CountryItem(nameAr: 'بريطانيا', nameEn: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
  CountryItem(nameAr: 'أمريكا', nameEn: 'United States', dialCode: '+1', flag: '🇺🇸'),
  CountryItem(nameAr: 'كندا', nameEn: 'Canada', dialCode: '+1', flag: '🇨🇦'),
  CountryItem(nameAr: 'ألمانيا', nameEn: 'Germany', dialCode: '+49', flag: '🇩🇪'),
  CountryItem(nameAr: 'فرنسا', nameEn: 'France', dialCode: '+33', flag: '🇫🇷'),
  CountryItem(nameAr: 'إيطاليا', nameEn: 'Italy', dialCode: '+39', flag: '🇮🇹'),
];

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = true; // إنشاء حساب هي الافتراضية
  bool _isLoading = false;
  bool _obscurePassword = true; // إظهار/إخفاء كلمة المرور

  CountryItem _selectedCountry = kCountries.first; // Default Libya 🇱🇾 +218

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getFullPhoneNumber() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return '';
    // إزالة الصفر الأول إن وجد مع كود الدولة
    final cleanNumber = raw.startsWith('0') ? raw.substring(1) : raw;
    return '${_selectedCountry.dialCode}$cleanNumber';
  }

  Future<void> _handleSubmit(WorkoutProvider workout) async {
    final rawPhone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workout.isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_isSignUp && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workout.isArabic ? 'يرجى إدخال الاسم بالكامل' : 'Please enter your full name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workout.isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter your password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workout.isArabic ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : 'Password must be at least 6 characters'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final fullPhone = _getFullPhoneNumber();

    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    if (_isSignUp) {
      result = await workout.register(
        name: name,
        phone: fullPhone,
        email: email.isNotEmpty ? email : null,
        password: password,
      );
    } else {
      result = await workout.login(
        phone: fullPhone,
        password: password,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? (workout.isArabic ? 'أهلاً بك يا بطل!' : 'Welcome athlete!')),
            backgroundColor: AppTheme.primaryNeon,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? (workout.isArabic ? 'فشلت العملية' : 'Operation failed')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showCountryPicker(BuildContext context, WorkoutProvider workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = kCountries.where((c) {
              final query = searchQuery.toLowerCase();
              return c.nameAr.toLowerCase().contains(query) ||
                  c.nameEn.toLowerCase().contains(query) ||
                  c.dialCode.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    workout.t('select_country'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surfaceHigher,
                      hintText: workout.t('search_country'),
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryNeon, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCountries.length,
                      separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                      itemBuilder: (context, idx) {
                        final country = filteredCountries[idx];
                        final isSelected = country.dialCode == _selectedCountry.dialCode && country.nameEn == _selectedCountry.nameEn;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Text(country.flag, style: const TextStyle(fontSize: 22)),
                          title: Text(
                            workout.isArabic ? country.nameAr : country.nameEn,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryNeon : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Text(
                            country.dialCode,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryNeon : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          onTap: () {
                            setState(() => _selectedCountry = country);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBiometricResetDialog(BuildContext context, WorkoutProvider workout) async {
    // 1. التحقق من دعم الجهاز لمستشعر البصمة
    final isSupported = await BiometricService.isDeviceSupported();
    if (!isSupported) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            workout.isArabic
                ? 'إعادة التعيين بالبصمة متاحة فقط على تطبيق الهاتف (Android) المزود بمستشعر بصمة.'
                : 'Biometric reset is only available on Android app with fingerprint sensor.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. التحقق من وجود حساب مسجل بالبصمة على هذا الجهاز
    final hasLinked = await BiometricService.hasLinkedUser();
    if (!hasLinked) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceHigher,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.fingerprint, color: Colors.orangeAccent, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  workout.isArabic ? 'لا توجد بصمة مرتبطة' : 'No Biometrics Registered',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            workout.isArabic
                ? 'لا يمكنك إعادة تعيين كلمة المرور بالبصمة لعدم وجود حساب مسجل ومرتبط بالبصمة على هذا الهاتف مسبقاً.'
                : 'You cannot reset password via fingerprint because no account has been linked to this device.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                workout.isArabic ? 'إغلاق' : 'Close',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 3. استدعاء مستشعر البصمة الحقيقي الخاص بنظام أندرويد فوراً (Native Android BiometricPrompt)
    final authResult = await BiometricService.authenticateWithResult(
      localizedReason: workout.isArabic
          ? 'يرجى لمس مستشعر بصمة الهاتف لتأكيد هويتك وإعادة تعيين كلمة المرور'
          : 'Touch fingerprint sensor to verify identity and reset password',
      isArabic: workout.isArabic,
    );

    if (!context.mounted) return;

    if (!authResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authResult.errorMessage ??
                (workout.isArabic ? 'لم يتم تأكيد البصمة أو تم إلغاؤها' : 'Fingerprint verification failed'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 4. البصمة تأكدت بنجاح من أندرويد -> جلب الحساب وعرض نموذج كلمة المرور الجديدة
    final linked = await BiometricService.getLinkedUser();
    final linkedPhone = linked?['phone'] ?? '';
    final cleanPhone = linkedPhone.replaceAll('+218', '').replaceAll('+', '').trim();

    final resetPhoneController = TextEditingController(text: cleanPhone.isNotEmpty ? cleanPhone : _phoneController.text.trim());
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    CountryItem resetCountry = _selectedCountry;

    bool isSaving = false;
    bool obscureNewPass = true;
    bool obscureConfirmPass = true;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.border)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.fingerprint, color: AppTheme.primaryNeon, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              workout.t('reset_with_biometrics'),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                      // Step 2: Biometrics Verified -> Reset Password Form
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.primaryNeon, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                workout.t('biometric_verified'),
                                style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone input
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(workout.t('phone_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHigher,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Text(resetCountry.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(resetCountry.dialCode, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: resetPhoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.surfaceHigher,
                                hintText: '913578201',
                                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // New Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(workout.t('new_password_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: newPassController,
                        obscureText: obscureNewPass,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceHigher,
                          hintText: workout.t('password_hint'),
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: obscureNewPass ? AppTheme.textMuted : AppTheme.primaryNeon,
                              size: 16,
                            ),
                            onPressed: () => setDialogState(() => obscureNewPass = !obscureNewPass),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(workout.t('confirm_password_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmPassController,
                        obscureText: obscureConfirmPass,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surfaceHigher,
                          hintText: workout.t('password_hint'),
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          prefixIcon: const Icon(Icons.lock_reset, color: AppTheme.textMuted, size: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: obscureConfirmPass ? AppTheme.textMuted : AppTheme.primaryNeon,
                              size: 16,
                            ),
                            onPressed: () => setDialogState(() => obscureConfirmPass = !obscureConfirmPass),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNeon,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final rPhone = resetPhoneController.text.trim();
                                  final newPass = newPassController.text.trim();
                                  final confirmPass = confirmPassController.text.trim();

                                  if (rPhone.isEmpty || newPass.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(workout.isArabic ? 'يرجى إكمال الحقول المطلوبة' : 'Please fill all required fields'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPass.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(workout.isArabic ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : 'Password must be at least 6 characters'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  if (newPass != confirmPass) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(workout.isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final cleanNum = rPhone.startsWith('0') ? rPhone.substring(1) : rPhone;
                                  final fullPhone = '${resetCountry.dialCode}$cleanNum';

                                  setDialogState(() => isSaving = true);
                                  final res = await workout.resetPassword(phone: fullPhone, newPassword: newPass);

                                  if (context.mounted) {
                                    setDialogState(() => isSaving = false);
                                    if (res['success'] == true) {
                                      Navigator.pop(dialogCtx);
                                      _phoneController.text = rPhone;
                                      _passwordController.text = newPass;
                                      _selectedCountry = resetCountry;
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res['message'] ?? (workout.isArabic ? 'تم تغيير كلمة المرور بنجاح!' : 'Password reset successful!')),
                                          backgroundColor: AppTheme.primaryNeon,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(res['message'] ?? 'فشلت العملية'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : Text(
                                  workout.t('save_new_password_btn'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                        ),
                      ),
                    ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleBiometricLogin(WorkoutProvider workout) async {
    final hasLinked = await BiometricService.hasLinkedUser();
    if (!hasLinked) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceHigher,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fingerprint, color: AppTheme.primaryNeon, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  workout.isArabic ? 'لم يتم ربط حساب بعد' : 'No Account Linked',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            workout.isArabic
                ? 'لا يوجد حساب مرتبط بالبصمة على هذا الجهاز حتى الآن!\n\nيجب عليك أولاً إنشاء حساب جديد أو تسجيل الدخول بكلمة المرور، وسيقوم التطبيق بحفظ وربط بصمتك تلقائياً بهذا الهاتف للدخول السريع في المرات القادمة.'
                : 'No account is linked with biometrics on this device yet!\n\nPlease sign up or log in first, and your fingerprint will be securely linked for future quick access.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                workout.isArabic ? 'حسناً، سأسجل أولاً' : 'Understood',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final res = await workout.loginWithBiometrics();
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                res['message'] ?? (workout.isArabic ? 'تم الدخول بالبصمة بنجاح' : 'Fingerprint authenticated'),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryNeon,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? (workout.isArabic ? 'فشلت المصادقة بالبصمة' : 'Fingerprint failed')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 460 : double.infinity),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شريط أعلى (الشعار وزر اللغة)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fitness_center, color: AppTheme.primaryNeon, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'IRONLOG',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      // زر تبديل اللغة
                      InkWell(
                        onTap: () => workout.toggleLanguage(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language, size: 14, color: AppTheme.primaryNeon),
                              const SizedBox(width: 6),
                              Text(
                                workout.isArabic ? 'English' : 'العربية',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // العناوين الترحيبية المحسنة
                  Text(
                    workout.t('auth_headline'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    workout.t('auth_subheadline'),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // كارت صندوق المصادقة (Auth Container)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // التبديل بين إنشاء حساب وتسجيل الدخول
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isSignUp = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isSignUp ? AppTheme.surface : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: _isSignUp ? Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.5)) : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        workout.t('create_account'),
                                        style: TextStyle(
                                          color: _isSignUp ? AppTheme.primaryNeon : AppTheme.textMuted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isSignUp = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isSignUp ? AppTheme.surface : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: !_isSignUp ? Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.5)) : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        workout.t('sign_in'),
                                        style: TextStyle(
                                          color: !_isSignUp ? AppTheme.primaryNeon : AppTheme.textMuted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // حقل الاسم الكامل (في حال إنشاء الحساب)
                        if (_isSignUp) ...[
                          Text(workout.t('full_name_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceHigher,
                              hintText: workout.t('full_name_hint'),
                              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textMuted, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // حقل رقم الهاتف مع محدد الدولة (رمز وعلم الدولة)
                        Text(workout.t('phone_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // محدد الدولة (العلم والرمز)
                            InkWell(
                              onTap: () => _showCountryPicker(context, workout),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHigher,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.dialCode,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.ltr,
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // حقل إدخال الرقم مع الـ Hint المطلوب (913578201)
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTheme.surfaceHigher,
                                  hintText: workout.t('phone_hint'), // 913578201
                                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // حقل البريد الإلكتروني (اختياري، يظهر في إنشاء الحساب)
                        if (_isSignUp) ...[
                          Text(workout.t('email_optional_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceHigher,
                              hintText: workout.t('email_optional_hint'),
                              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // حقل كلمة المرور
                        Text(workout.t('password_label'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.surfaceHigher,
                            hintText: workout.t('password_hint'),
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: _obscurePassword ? AppTheme.textMuted : AppTheme.primaryNeon,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              tooltip: workout.isArabic
                                  ? (_obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور')
                                  : (_obscurePassword ? 'Show password' : 'Hide password'),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),

                        // رابط "هل نسيت كلمة السر؟ (إعادة التعيين بالبصمة)"
                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: workout.isArabic ? Alignment.centerLeft : Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _showBiometricResetDialog(context, workout),
                              icon: const Icon(Icons.fingerprint, size: 16, color: AppTheme.primaryNeon),
                              label: Text(
                                workout.t('forgot_password'),
                                style: const TextStyle(
                                  color: AppTheme.primaryNeon,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // زر الإجراء الرئيسي
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNeon,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : () => _handleSubmit(workout),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isSignUp ? workout.t('register_submit') : workout.t('login_submit'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(workout.isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 16),
                                  ],
                                ),
                        ),
                        if (!_isSignUp) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryNeon,
                              side: BorderSide(color: AppTheme.primaryNeon.withValues(alpha: 0.8), width: 1.5),
                              backgroundColor: AppTheme.surfaceHighlight,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _isLoading ? null : () => _handleBiometricLogin(workout),
                            icon: const Icon(Icons.fingerprint, color: AppTheme.primaryNeon, size: 22),
                            label: Text(
                              workout.t('biometric_login_btn'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
