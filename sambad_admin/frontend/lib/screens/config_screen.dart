import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // These would be loaded/saved via backend in a real app
    final ValueNotifier<bool> otpEnabled = ValueNotifier(false);
    final ValueNotifier<bool> googleEnabled = ValueNotifier(false);
    final ValueNotifier<bool> appleEnabled = ValueNotifier(false);

    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tune, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 18),
              Text('Login Config', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: otpEnabled,
                builder: (context, value, _) => SwitchListTile.adaptive(
                  value: value,
                  onChanged: (v) => otpEnabled.value = v,
                  title: const Text('Enable OTP Login'),
                  subtitle: const Text('Allow users to login with OTP'),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: googleEnabled,
                builder: (context, value, _) => SwitchListTile.adaptive(
                  value: value,
                  onChanged: (v) => googleEnabled.value = v,
                  title: const Text('Enable Google Login'),
                  subtitle: const Text('Allow users to login with Google'),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: appleEnabled,
                builder: (context, value, _) => SwitchListTile.adaptive(
                  value: value,
                  onChanged: (v) => appleEnabled.value = v,
                  title: const Text('Enable Apple Login'),
                  subtitle: const Text('Allow users to login with Apple ID'),
                ),
              ),
              const SizedBox(height: 18),
              Text('Configuration changes are saved and pushed to user app in real time.', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
