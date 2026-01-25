import 'package:go_router/go_router.dart';

import '../pages/forgot_password_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/sign_in_page.dart';
import '../pages/sign_up_page.dart';
import '../pages/verify_email_page.dart';

class AuthRouteNames {
  static const signIn = 'signIn';
  static const signUp = 'signUp';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const verifyEmail = 'verifyEmail';
  static const postAuthRedirect = 'postAuthRedirect';
}

final List<RouteBase> authRoutes = [
  GoRoute(
    name: AuthRouteNames.signIn,
    path: '/sign-in',
    builder: (context, state) => const SignInPage(),
  ),
  GoRoute(
    name: AuthRouteNames.signUp,
    path: '/sign-up',
    builder: (context, state) => const SignUpPage(),
  ),
  GoRoute(
    name: AuthRouteNames.forgotPassword,
    path: '/forgot-password',
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(
    name: AuthRouteNames.resetPassword,
    path: '/reset-password',
    builder: (context, state) => const ResetPasswordPage(),
  ),
  GoRoute(
    name: AuthRouteNames.verifyEmail,
    path: '/verify-email',
    builder: (context, state) => const VerifyEmailPage(),
  ),
];
