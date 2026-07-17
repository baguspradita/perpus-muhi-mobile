class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegExp = RegExp(r'^[0-9]+$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Nomor telepon hanya boleh angka';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Nomor telepon harus 10-15 digit';
    }
    return null;
  }

  static String? numeric(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    final numericRegExp = RegExp(r'^[0-9]+$');
    if (!numericRegExp.hasMatch(value)) {
      return '$fieldName hanya boleh angka';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }
}