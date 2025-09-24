import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }
  
  static bool isValidTitle(String title) {
    return title.trim().isNotEmpty && title.trim().length >= 2;
  }
  
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title is required';
    }
    if (title.trim().length < 2) {
      return 'Title must be at least 2 characters';
    }
    return null;
  }
  
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}