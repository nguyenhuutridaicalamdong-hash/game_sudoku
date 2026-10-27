import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/colorful_background.dart';

/// Màn hình Đăng nhập / Đăng ký (chuyển qua lại bằng nút bên dưới).
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();

  bool _isRegister = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final error = _isRegister
        ? await auth.register(_usernameCtrl.text, _passwordCtrl.text, _displayNameCtrl.text)
        : await auth.login(_usernameCtrl.text, _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _error = error);
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _error = null;
    });
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<AuthProvider>().isBusy;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ColorfulBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo mini bàn cờ 3x3
                    Center(child: _buildLogo()),
                    const SizedBox(height: 16),
                    Center(
                      child: RainbowText(
                        'Sudoku Sắc Màu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      _isRegister ? 'Tạo tài khoản để lưu điểm và lên bảng xếp hạng' : 'Đăng nhập để tiếp tục chơi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (_isRegister) ...[
                      TextFormField(
                        controller: _displayNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration('Tên hiển thị', Icons.badge_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên hiển thị' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextFormField(
                      controller: _usernameCtrl,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: _decoration('Tên đăng nhập', Icons.person_outline_rounded),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Nhập tên đăng nhập';
                        if (_isRegister) {
                          if (value.length < 3) return 'Ít nhất 3 ký tự';
                          if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
                            return 'Chỉ dùng chữ không dấu, số, dấu _ hoặc .';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: _isRegister ? TextInputAction.next : TextInputAction.done,
                      onFieldSubmitted: (_) => _isRegister ? null : _submit(),
                      decoration: _decoration(
                        'Mật khẩu',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                        if (_isRegister && v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                        return null;
                      },
                    ),

                    if (_isRegister) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: _decoration('Nhập lại mật khẩu', Icons.lock_reset_rounded),
                        validator: (v) => v != _passwordCtrl.text ? 'Mật khẩu nhập lại không khớp' : null,
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    GestureDetector(
                      onTap: isBusy ? null : _submit,
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.berryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pink.withOpacity(0.45),
                              offset: const Offset(0, 8),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                _isRegister ? '🎉 Đăng ký' : '🚀 Đăng nhập',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: isBusy ? null : _toggleMode,
                      child: Text(
                        _isRegister ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký ngay',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: isBusy ? null : _showServerDialog,
                        icon: const Icon(Icons.dns_rounded, size: 16, color: AppColors.primary),
                        label: Text(
                          'Máy chủ: ${ApiConfig.baseUrl}',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Đổi địa chỉ máy chủ (dùng khi test chung với nhóm).
  Future<void> _showServerDialog() async {
    final ctrl = TextEditingController(text: ApiConfig.baseUrl);
    String? status;
    bool checking = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('🖥️ Địa chỉ máy chủ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                autocorrect: false,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'vd: 192.168.1.5',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Máy ảo trên máy chạy API: 10.0.2.2\n'
                '• Máy khác cùng Wi-Fi: IP máy chủ (vd 192.168.1.5)\n'
                '• Qua Internet: link Dev Tunnel https://...',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
              ),
              if (status != null) ...[
                const SizedBox(height: 10),
                Text(
                  status!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: status!.startsWith('✅') ? AppColors.mintDark : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ApiConfig.save(ApiConfig.defaultBaseUrl);
                ctrl.text = ApiConfig.baseUrl;
                setDialogState(() => status = null);
              },
              child: const Text('Mặc định'),
            ),
            TextButton(
              onPressed: checking
                  ? null
                  : () async {
                      setDialogState(() => checking = true);
                      await ApiConfig.save(ctrl.text);
                      ctrl.text = ApiConfig.baseUrl;
                      final err = await ApiService.checkHealth();
                      setDialogState(() {
                        checking = false;
                        status = err == null ? '✅ Kết nối được máy chủ!' : '❌ $err';
                      });
                    },
              child: Text(checking ? 'Đang thử...' : 'Kiểm tra'),
            ),
            FilledButton(
              onPressed: () async {
                await ApiConfig.save(ctrl.text);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _buildLogo() {
    const digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: AppColors.rainbowGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final d in digits)
            Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                d,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
