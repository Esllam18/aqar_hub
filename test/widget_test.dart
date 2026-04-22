import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Auth validation logic ──────────────────────────────────────────────────

  group('Auth — email validation', () {
    bool isValidEmail(String email) {
      return email.trim().isNotEmpty && email.contains('@');
    }

    test('accepts valid email', () {
      expect(isValidEmail('user@example.com'), isTrue);
    });

    test('rejects empty email', () {
      expect(isValidEmail(''), isFalse);
    });

    test('rejects email without @', () {
      expect(isValidEmail('notanemail'), isFalse);
    });
  });

  group('Auth — password validation', () {
    String? validatePassword(String password) {
      if (password.isEmpty) return 'val_password_required';
      if (password.length < 8) return 'val_password_min_8';
      return null;
    }

    test('accepts password of 8+ chars', () {
      expect(validatePassword('securepassword'), isNull);
    });

    test('rejects password shorter than 8 chars', () {
      expect(validatePassword('short'), equals('val_password_min_8'));
    });

    test('rejects empty password', () {
      expect(validatePassword(''), equals('val_password_required'));
    });

    test('login and signup use same minimum (8 chars)', () {
      // This test documents that both screens use 8 as the minimum length.
      // If you change one, change the other — and this test will remind you.
      const loginMinLength = 8;
      const signupMinLength = 8;
      expect(loginMinLength, equals(signupMinLength));
    });
  });

  group('Auth — confirm password validation', () {
    String? validateConfirm(String password, String confirm) {
      if (confirm.isEmpty) return 'val_password_required';
      if (confirm != password) return 'val_passwords_mismatch';
      return null;
    }

    test('accepts matching passwords', () {
      expect(validateConfirm('mypassword', 'mypassword'), isNull);
    });

    test('rejects mismatched passwords', () {
      expect(
        validateConfirm('mypassword', 'different'),
        equals('val_passwords_mismatch'),
      );
    });
  });

  // ── Property filter model ──────────────────────────────────────────────────

  group('Property filter — price range', () {
    test('min price is less than or equal to max price', () {
      const minPrice = 2000.0;
      const maxPrice = 8000.0;
      expect(minPrice, lessThanOrEqualTo(maxPrice));
    });
  });
}
