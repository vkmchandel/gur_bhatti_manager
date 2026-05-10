import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/locale_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Hero Section - Using bhatti_logo_2.png
                Center(
                  child: Image.asset(
                    'assets/images/bhatti_logo.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.agriculture_rounded,
                      size: 100,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const Spacer(),
                
                // Language Selection using ChoiceChips with secondary color
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('English'),
                      selected: localeProvider.locale.languageCode == 'en',
                      selectedColor: theme.colorScheme.secondary,
                      onSelected: (selected) {
                        if (selected) localeProvider.setLocale(const Locale('en'));
                      },
                      labelStyle: TextStyle(
                        color: localeProvider.locale.languageCode == 'en' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('हिंदी'),
                      selected: localeProvider.locale.languageCode == 'hi',
                      selectedColor: theme.colorScheme.secondary,
                      onSelected: (selected) {
                        if (selected) localeProvider.setLocale(const Locale('hi'));
                      },
                      labelStyle: TextStyle(
                        color: localeProvider.locale.languageCode == 'hi' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Mobile Number Input - Fixed bolding and prefix size matching
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.mobileNumber,
                    hintText: l10n.enterMobileHint,
                    prefixText: '+91 ',
                    prefixStyle: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.normal, 
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.phone_android_rounded, color: theme.colorScheme.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return l10n.mobileRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.push('/otp', extra: _phoneController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.continueButton,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
