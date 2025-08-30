// An abstract base class for all failures that can occur during authentication.
// This allows us to catch all auth-related failures generally.
abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

// Specific failure classes for each conceivable case.
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('User not found or password is incorrect.');
}

class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure() : super('This email address is already in use.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('The password is too weak. It must be at least 6 characters long.');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('The email address has an invalid format.');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Network error. Please check your internet connection.');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure() : super('An unknown error occurred. Please try again.');
}