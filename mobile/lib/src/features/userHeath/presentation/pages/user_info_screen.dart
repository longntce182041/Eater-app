import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_setup_provider.dart';

// State management for user info
class UserInfoState {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isSubmitting;
  final String? firstNameError;
  final String? lastNameError;
  final String? phoneNumberError;

  UserInfoState({
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.isSubmitting = false,
    this.firstNameError,
    this.lastNameError,
    this.phoneNumberError,
  });

  UserInfoState copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isSubmitting,
    String? firstNameError,
    String? lastNameError,
    String? phoneNumberError,
  }) {
    return UserInfoState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      phoneNumberError: phoneNumberError,
    );
  }

  bool get isValid {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        phoneNumber.trim().length >= 8;
  }
}

// StateNotifier for managing user info state
class UserInfoNotifier extends StateNotifier<UserInfoState> {
  UserInfoNotifier() : super(UserInfoState());

  void setFirstName(String value) {
    state = state.copyWith(firstName: value, firstNameError: null);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value, lastNameError: null);
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value, phoneNumberError: null);
  }

  bool validate() {
    String? firstNameError;
    String? lastNameError;
    String? phoneNumberError;

    if (state.firstName.trim().isEmpty) {
      firstNameError = 'First name is required';
    }

    if (state.lastName.trim().isEmpty) {
      lastNameError = 'Last name is required';
    }

    if (state.phoneNumber.trim().isEmpty) {
      phoneNumberError = 'Phone number is required';
    } else if (state.phoneNumber.trim().length < 8) {
      phoneNumberError = 'Phone number must be at least 8 digits';
    }

    if (firstNameError != null ||
        lastNameError != null ||
        phoneNumberError != null) {
      state = state.copyWith(
        firstNameError: firstNameError,
        lastNameError: lastNameError,
        phoneNumberError: phoneNumberError,
      );
      return false;
    }

    return true;
  }

  void reset() {
    state = UserInfoState();
  }
}

// Provider for user info state
final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoState>(
  (ref) {
    return UserInfoNotifier();
  },
);

class UserInfoScreen extends ConsumerWidget {
  const UserInfoScreen({super.key});

  void _handleContinue(BuildContext context, WidgetRef ref) {
    // Validate the form
    final isValid = ref.read(userInfoProvider.notifier).validate();
    if (!isValid) return;

    final state = ref.read(userInfoProvider);

    // Save to profile setup provider
    final userId = ref.read(profileSetupProvider('')).data.userId ?? '';
    final profileNotifier = ref.read(profileSetupProvider(userId).notifier);

    profileNotifier.setFirstName(state.firstName.trim());
    profileNotifier.setLastName(state.lastName.trim());
    profileNotifier.setPhoneNumber(state.phoneNumber.trim());

    // Navigate to age screen
    if (!context.mounted) return;
    context.push('/set-age');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoState = ref.watch(userInfoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // Light beige
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tell us about you',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter your details',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Input fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // First Name Field
                    _InputFieldCard(
                      label: 'First name',
                      placeholder: 'Enter your first name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.text,
                      errorText: userInfoState.firstNameError,
                      onChanged: (value) {
                        ref.read(userInfoProvider.notifier).setFirstName(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Last Name Field
                    _InputFieldCard(
                      label: 'Last name',
                      placeholder: 'Enter your last name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.text,
                      errorText: userInfoState.lastNameError,
                      onChanged: (value) {
                        ref.read(userInfoProvider.notifier).setLastName(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Number Field
                    _InputFieldCard(
                      label: 'Phone number',
                      placeholder: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: userInfoState.phoneNumberError,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        ref
                            .read(userInfoProvider.notifier)
                            .setPhoneNumber(value);
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: userInfoState.isSubmitting
                      ? null
                      : () => _handleContinue(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: userInfoState.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable input field card widget
class _InputFieldCard extends StatefulWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final TextInputType keyboardType;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _InputFieldCard({
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.keyboardType,
    required this.onChanged,
    this.errorText,
    this.inputFormatters,
  });

  @override
  State<_InputFieldCard> createState() => _InputFieldCardState();
}

class _InputFieldCardState extends State<_InputFieldCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? Colors.red
                  : _isFocused
                  ? const Color(0xFFFF9800)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  widget.icon,
                  size: 22,
                  color: hasError
                      ? Colors.red
                      : _isFocused
                      ? const Color(0xFFFF9800)
                      : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
