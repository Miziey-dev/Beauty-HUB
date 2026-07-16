import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_data_source.dart';
import '../../l10n/strings.dart';

/// Auth gate (docs/consumer-flow.md, Screen 5b): phone OTP is primary,
/// Google is the alternative. Pushed on top of the booking flow right
/// before a request is created; pops `true` once signed in.
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

enum _Step { enterPhone, enterCode }

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  _Step _step = _Step.enterPhone;
  final _phoneController = TextEditingController(text: '+27');
  final _codeController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthDataSource>().sendPhoneOtp(_phoneController.text.trim());
      if (!mounted) return;
      setState(() => _step = _Step.enterCode);
    } catch (e) {
      setState(() => _error = Strings.sendOtpFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthDataSource>().verifyPhoneOtp(
            phone: _phoneController.text.trim(),
            token: _codeController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = Strings.verifyOtpFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthDataSource>().signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = Strings.googleSignInFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.signInToContinue)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_step == _Step.enterPhone) ...[
              const Text(Strings.phoneOtpExplainer),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: Strings.phoneNumberLabel, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _sendOtp,
                child: _busy ? const _Spinner() : const Text(Strings.sendCode),
              ),
              const SizedBox(height: 12),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(Strings.or)), Expanded(child: Divider())]),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text(Strings.continueWithGoogle),
              ),
            ] else ...[
              Text(Strings.codeSentTo(_phoneController.text.trim())),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: Strings.verificationCodeLabel, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _verifyOtp,
                child: _busy ? const _Spinner() : const Text(Strings.verify),
              ),
              TextButton(
                onPressed: _busy ? null : () => setState(() => _step = _Step.enterPhone),
                child: const Text(Strings.changeNumber),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
}

/// Pushes [PhoneAuthScreen] if the user isn't signed in yet and waits for
/// the result; returns true immediately if already signed in.
Future<bool> ensureSignedIn(BuildContext context) async {
  final auth = context.read<AuthDataSource>();
  if (auth.isSignedIn) return true;
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
  );
  return result ?? false;
}
