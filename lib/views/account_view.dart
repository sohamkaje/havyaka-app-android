import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_view_model.dart';
import '../services/network_monitor.dart';
import '../theme/design_system.dart';

enum _AuthScreen { welcome, signUp, logIn }

class AccessView extends StatefulWidget {
  const AccessView({super.key});

  @override
  State<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends State<AccessView> {
  _AuthScreen screen = _AuthScreen.welcome;
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  bool signUpCodeSent = false;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    emailController.clear();
    codeController.clear();
    signUpCodeSent = false;
    final auth = context.read<AuthViewModel>();
    auth.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final network = context.watch<NetworkMonitor>();

    if (auth.infoMessage != null && screen == _AuthScreen.signUp && !signUpCodeSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => signUpCodeSent = true);
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _hero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 28, HAASpacing.lg, 90),
            child: switch (screen) {
              _AuthScreen.welcome => _welcomeContent(),
              _AuthScreen.signUp => _signUpContent(auth, network),
              _AuthScreen.logIn => _logInContent(auth, network),
            },
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final (title, subtitle) = switch (screen) {
      _AuthScreen.welcome => ('My Account', 'Sign up to receive your login code, or log in if you already have it.'),
      _AuthScreen.signUp => ('Sign Up', "Enter the email of whoever registered your group. We'll email the 5-digit login code to that inbox."),
      _AuthScreen.logIn => ('Log In', 'Enter the registrant email and the 5-digit code that was emailed to you.'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [HAAColors.charcoal, HAAColors.deepBrown], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: HAAColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.account_circle, size: 44, color: HAAColors.orange),
          ),
          const SizedBox(height: 14),
          Text(title, style: HAAFonts.serif(20, weight: FontWeight.bold).copyWith(color: HAAColors.heroText)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(subtitle, textAlign: TextAlign.center, style: HAAFonts.sans(13).copyWith(color: HAAColors.mutedLight)),
          ),
        ],
      ),
    );
  }

  Widget _welcomeContent() {
    return Column(
      children: [
        _navButton('Sign Up', Icons.person_add, () { _resetForm(); setState(() => screen = _AuthScreen.signUp); }),
        const SizedBox(height: 12),
        _navButton('Log In', Icons.login, () { _resetForm(); setState(() => screen = _AuthScreen.logIn); }),
      ],
    );
  }

  Widget _navButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HAARadius.md),
          border: Border.all(color: HAAColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: HAAColors.charcoal),
            const SizedBox(width: 10),
            Text(title, style: HAAFonts.sans(16, weight: FontWeight.bold)),
            const Spacer(),
            Icon(Icons.chevron_right, size: 13, color: HAAColors.muted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _signUpContent(AuthViewModel auth, NetworkMonitor network) {
    return Column(
      children: [
        _backButton(),
        _emailField(),
        if (signUpCodeSent) ...[
          _codeField(),
          if (auth.infoMessage != null) _banner(auth.infoMessage!, true),
          if (auth.errorMessage != null) _banner(auth.errorMessage!, false),
          _submitButton(
            loading: auth.isLoading,
            loadingText: 'Signing in…',
            text: 'Complete Sign Up',
            onTap: network.isConnected ? () => auth.login(emailController.text, codeController.text) : null,
          ),
        ] else ...[
          if (auth.errorMessage != null) _banner(auth.errorMessage!, false),
          _submitButton(
            loading: auth.isSendingCode,
            loadingText: 'Sending code…',
            text: 'Send Login Code',
            onTap: network.isConnected ? () => auth.sendLoginCode(emailController.text) : null,
          ),
        ],
        const SizedBox(height: 16),
        _helpCard('If someone else registered for you, use their email address — the login code will be sent to that inbox.'),
      ],
    );
  }

  Widget _logInContent(AuthViewModel auth, NetworkMonitor network) {
    return Column(
      children: [
        _backButton(),
        _emailField(),
        _codeField(),
        if (auth.infoMessage != null) _banner(auth.infoMessage!, true),
        if (auth.errorMessage != null) _banner(auth.errorMessage!, false),
        _submitButton(
          loading: auth.isLoading,
          loadingText: 'Signing in…',
          text: 'Log In',
          onTap: network.isConnected ? () => auth.login(emailController.text, codeController.text) : null,
        ),
        const SizedBox(height: 16),
        _helpCard("Use the registrant email and the 5-digit code from your email. Don't have a code yet? Go back and choose Sign Up."),
      ],
    );
  }

  Widget _backButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () { _resetForm(); setState(() => screen = _AuthScreen.welcome); },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_left, size: 13, color: HAAColors.muted),
            Text('Back', style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _formField('Registrant Email', Icons.email, emailController, keyboardType: TextInputType.emailAddress),
    );
  }

  Widget _codeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _formField('5-Digit Login Code', Icons.lock, codeController, keyboardType: TextInputType.number, maxLength: 5, digitsOnly: true),
    );
  }

  Widget _formField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType, int? maxLength, bool digitsOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(HAARadius.md),
            border: Border.all(color: HAAColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: HAAColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  style: HAAFonts.sans(15).copyWith(color: HAAColors.charcoal),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _submitButton({required bool loading, required String loadingText, required String text, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: loading ? HAAColors.muted : HAAColors.orange,
          borderRadius: BorderRadius.circular(HAARadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            if (loading) const SizedBox(width: 8),
            Text(loading ? loadingText : text, style: HAAFonts.sans(15, weight: FontWeight.bold).copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _banner(String text, bool success) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? HAAColors.successBg : Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(HAARadius.md),
      ),
      child: Text(text, style: HAAFonts.sans(13).copyWith(color: success ? HAAColors.success : Colors.red)),
    );
  }

  Widget _helpCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: HAAColors.goldLight.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(HAARadius.md)),
      child: Text(text, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    final auth = context.read<AuthViewModel>();
    if (auth.profile.hasCheckedIn) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth = context.read<AuthViewModel>();
      final network = context.read<NetworkMonitor>();
      if (auth.profile.hasCheckedIn || !network.isConnected) return;
      final justCheckedIn = await auth.refreshRegistrationStatus();
      if (justCheckedIn && mounted) auth.markCheckedInFromVolunteerScan();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _profileHeader(auth),
          Padding(
            padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 20, HAASpacing.lg, 0),
            child: Column(
              children: [
                _accountCard(auth),
                const SizedBox(height: 10),
                if (auth.profile.hasCheckedIn) _checkedInCard() else _checkInButton(),
                if (auth.infoMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: HAAColors.successBg, borderRadius: BorderRadius.circular(HAARadius.md)),
                    child: Text(auth.infoMessage!, style: HAAFonts.sans(13).copyWith(color: HAAColors.success)),
                  ),
                ],
                const SizedBox(height: 10),
                _helpCard(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 24, HAASpacing.lg, 90),
            child: GestureDetector(
              onTap: () => _confirmLogout(auth),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(HAARadius.md)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 14, color: Colors.red.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text('Sign Out', style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: Colors.red.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(AuthViewModel auth) {
    final initials = '${auth.profile.firstName.isNotEmpty ? auth.profile.firstName[0] : ''}${auth.profile.lastName.isNotEmpty ? auth.profile.lastName[0] : ''}';
    return Container(
      width: double.infinity,
      height: 180,
      color: HAAColors.charcoal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: HAAColors.orange,
            child: Text(initials, style: HAAFonts.sans(26, weight: FontWeight.bold).copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text('${auth.profile.firstName} ${auth.profile.lastName}', style: HAAFonts.serif(20, weight: FontWeight.bold).copyWith(color: HAAColors.heroText)),
          Text(auth.profile.email, style: HAAFonts.sans(12).copyWith(color: HAAColors.mutedLight)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _accountCard(AuthViewModel auth) {
    return HAACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge, size: 15, color: HAAColors.orange),
              const SizedBox(width: 8),
              Text('Account', style: HAAFonts.sans(15, weight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          _profileRow('First Name', auth.profile.firstName),
          _profileRow('Last Name', auth.profile.lastName),
          _profileRow('Linked Email', auth.profile.email),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: HAAFonts.sans(9, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.6)),
          Text(value, style: HAAFonts.sans(13, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _checkedInCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HAAColors.successBg,
        borderRadius: BorderRadius.circular(HAARadius.lg),
        border: Border.all(color: HAAColors.success.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, size: 22, color: HAAColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checked In', style: HAAFonts.sans(15, weight: FontWeight.bold)),
                Text('Your convention check-in is complete.', style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkInButton() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: HAAColors.cream,
        builder: (_) => const CheckInQRSheet(),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: HAAColors.orange, borderRadius: BorderRadius.circular(HAARadius.md)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Check In', style: HAAFonts.sans(15, weight: FontWeight.bold).copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _helpCard() {
    return HAACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help, size: 15, color: HAAColors.ceremonyFg),
              const SizedBox(width: 8),
              Text('Need Help?', style: HAAFonts.sans(15, weight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('mailto:secretary@havyak.org')),
            child: Row(
              children: [
                const Icon(Icons.email, size: 14, color: HAAColors.ceremonyFg),
                const SizedBox(width: 8),
                Text('Contact secretary@havyak.org', style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: HAAColors.ceremonyFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(AuthViewModel auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) await auth.logout();
  }
}

class CheckInQRSheet extends StatefulWidget {
  const CheckInQRSheet({super.key});

  @override
  State<CheckInQRSheet> createState() => _CheckInQRSheetState();
}

class _CheckInQRSheetState extends State<CheckInQRSheet> {
  Timer? _pollTimer;

  static const steps = [
    ('1', 'Head to the Check-In Desk', 'When you arrive at Rosary College Prep, walk to the Check-in Desk at the main entrance.'),
    ('2', 'Show your QR code', 'Present the QR code below to one of our volunteers — on your phone screen or a printout.'),
    ('3', 'Collect your badges & souvenir', "Once scanned, you'll receive your official name badges and your custom convention souvenir packet."),
  ];

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    final auth = context.read<AuthViewModel>();
    final network = context.read<NetworkMonitor>();
    if (auth.profile.hasCheckedIn || !network.isConnected) return;
    final justCheckedIn = await auth.refreshRegistrationStatus();
    if (justCheckedIn && mounted) {
      auth.markCheckedInFromVolunteerScan();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final network = context.watch<NetworkMonitor>();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(HAASpacing.lg),
        children: [
          Row(
            children: [
              Text('Convention Check-In', style: HAAFonts.sans(16, weight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Done', style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.orange))),
            ],
          ),
          Text('How Check-In Works — 3 Easy Steps', style: HAAFonts.serif(20, weight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 13, backgroundColor: HAAColors.orange, child: Text(s.$1, style: HAAFonts.sans(13, weight: FontWeight.bold).copyWith(color: Colors.white))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$2, style: HAAFonts.sans(14, weight: FontWeight.bold)),
                          Text(s.$3, style: HAAFonts.sans(13).copyWith(color: HAAColors.muted, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          _qrSection(auth, network),
        ],
      ),
    );
  }

  Widget _qrSection(AuthViewModel auth, NetworkMonitor network) {
    if (auth.profile.hasCheckedIn) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: HAAColors.successBg, borderRadius: BorderRadius.circular(HAARadius.lg)),
        child: Column(
          children: [
            const Icon(Icons.verified, size: 44, color: HAAColors.success),
            Text("You're checked in!", style: HAAFonts.sans(18, weight: FontWeight.bold)),
            Text('Your registration was confirmed by our volunteers.', textAlign: TextAlign.center, style: HAAFonts.sans(13).copyWith(color: HAAColors.muted)),
          ],
        ),
      );
    }

    final url = auth.profile.checkInURL;
    if (url == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(HAARadius.lg)),
        child: Column(
          children: [
            const Icon(Icons.warning, size: 28, color: HAAColors.orange),
            Text("Your check-in QR code isn't available yet.", textAlign: TextAlign.center, style: HAAFonts.sans(14, weight: FontWeight.w600)),
            Text('Sign out and log in again to refresh your registration details.', textAlign: TextAlign.center, style: HAAFonts.sans(13).copyWith(color: HAAColors.muted)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(HAARadius.lg),
            border: Border.all(color: HAAColors.border, width: 0.5),
          ),
          child: QrImageView(data: url, size: 220, backgroundColor: Colors.white),
        ),
        const SizedBox(height: 12),
        Text('${auth.profile.firstName} ${auth.profile.lastName}', style: HAAFonts.sans(15, weight: FontWeight.bold)),
        Text(auth.profile.email, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
        if (network.isConnected) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: HAAColors.muted)),
              const SizedBox(width: 8),
              Text('Waiting for volunteer to scan your code…', style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
            ],
          ),
        ],
      ],
    );
  }
}
