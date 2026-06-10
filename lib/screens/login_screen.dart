import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_state.dart';
import '../data/packages_data.dart';
import '../navigation.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool register = false;
  String role = 'user';
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  String? focusedField;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;

    setState(() => loading = true);

    AppUser? user;
    String? errorMessage;

    if (register) {
      if (nameCtrl.text.trim().isEmpty) {
        errorMessage = 'Please enter your full name.';
      } else {
        user = await appState.registerUser(
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
        );
        if (user == null) {
          errorMessage = 'An account with that email already exists.';
        }
      }
    } else {
      user = await appState.signIn(
        identifier: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        role: role,
      );
      if (user == null) {
        errorMessage = role == 'admin'
            ? 'Invalid Staff ID or Password'
            : 'Invalid email or password.';
      }
    }

    if (!mounted) return;

    if (errorMessage != null || user == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Authentication failed.')),
      );
      return;
    }

    await appState.setCurrentUser(
      CurrentUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      ),
    );

    final target = user.role == 'admin' ? '/admin' : '/menu';
    // Use [rootNavigatorKey]: updating [appState] rebuilds [MaterialApp]; [Navigator.of]
    // from this route's context can be invalid in that frame.
    final nav = rootNavigatorKey.currentState;
    if (nav != null) {
      nav.pushReplacementNamed(target);
    } else if (mounted) {
      await Navigator.of(context).pushReplacementNamed(target);
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.cream.withOpacity(0.4)),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back', style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withOpacity(0.15),
                          AppColors.gold.withOpacity(0.05)
                        ],
                      ),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: _DiamondIconPainter(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    register ? 'Create Account' : 'Welcome Back',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 34, height: 1.15, color: AppColors.cream),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    register
                        ? 'Join Venera to start booking extraordinary private dining experiences.'
                        : 'Sign in to access your reservations and explore our menu packages.',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.cream.withOpacity(0.45)),
                  ),
                  const SizedBox(height: 40),
                  if (!register) ...[
                    Text(
                      'ACCESS LEVEL',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.cream.withOpacity(0.35),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(100),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _RoleChip(
                              label: '👤 Guest',
                              selected: role == 'user',
                              onTap: () => setState(() => role = 'user'),
                            ),
                          ),
                          Expanded(
                            child: _RoleChip(
                              label: '⚙️ Admin',
                              selected: role == 'admin',
                              onTap: () => setState(() => role = 'admin'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (register)
                    _LabeledField(
                      label: 'Full Name',
                      controller: nameCtrl,
                      hint: 'Eleanor Whitmore',
                      focused: focusedField == 'name',
                      onFocus: () => setState(() => focusedField = 'name'),
                      onBlur: () => setState(() => focusedField = null),
                    ),
                  _LabeledField(
                    label: !register && role == 'admin'
                        ? 'Staff ID'
                        : 'Email Address',
                    controller: emailCtrl,
                    hint: !register && role == 'admin'
                        ? '12345'
                        : 'you@example.com',
                    keyboardType: !register && role == 'admin'
                        ? TextInputType.text
                        : TextInputType.emailAddress,
                    focused: focusedField == 'email',
                    onFocus: () => setState(() => focusedField = 'email'),
                    onBlur: () => setState(() => focusedField = null),
                  ),
                  _LabeledField(
                    label: 'Password',
                    controller: passwordCtrl,
                    hint: '••••••••••',
                    obscure: true,
                    focused: focusedField == 'password',
                    onFocus: () => setState(() => focusedField = 'password'),
                    onBlur: () => setState(() => focusedField = null),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: loading
                            ? null
                            : const LinearGradient(
                                colors: [
                                  AppColors.gold,
                                  AppColors.goldLight,
                                  AppColors.gold
                                ],
                              ),
                        color: loading ? AppColors.gold.withOpacity(0.3) : null,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: TextButton(
                        onPressed: loading ? null : _submit,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.canvas,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: loading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.canvas),
                                  ),
                                  SizedBox(width: 8),
                                  Text('AUTHENTICATING...',
                                      style: TextStyle(letterSpacing: 1)),
                                ],
                              )
                            : Text(
                                register ? 'CREATE ACCOUNT' : 'SIGN IN',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    fontSize: 14),
                              ),
                      ),
                    ),
                  ),
                  if (role == 'user') ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.cream.withOpacity(0.4)),
                          children: [
                            TextSpan(
                                text: register
                                    ? 'Already have an account? '
                                    : "Don't have an account? "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  register = !register;
                                  if (register) role = 'user';
                                }),
                                child: Text(
                                  register ? 'Sign in' : 'Create one',
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.gold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.15)),
                    ),
                    child: Text(
                      !register && role == 'admin'
                          ? 'Demo: Admin login — Staff ID: 12345, Password: admin123'
                          : 'Demo: Guest login — Email: demo@venera.com, Password: demo1234',
                      style: TextStyle(
                          fontSize: 11,
                          height: 1.6,
                          color: AppColors.gold.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight])
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: selected
                  ? AppColors.canvas
                  : AppColors.cream.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.focused,
    required this.onFocus,
    required this.onBlur,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool focused;
  final VoidCallback onFocus;
  final VoidCallback onBlur;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color:
                  focused ? AppColors.gold : AppColors.cream.withOpacity(0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Focus(
            onFocusChange: (has) => has ? onFocus() : onBlur(),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14, color: AppColors.cream),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.cream.withOpacity(0.25)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.gold.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.gold.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.gold.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiamondIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()..color = AppColors.gold.withOpacity(0.1);

    final path = Path()
      ..moveTo(size.width / 2, 2)
      ..lineTo(size.width - 2, size.height * 0.35)
      ..lineTo(size.width / 2, size.height - 2)
      ..lineTo(2, size.height * 0.35)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
