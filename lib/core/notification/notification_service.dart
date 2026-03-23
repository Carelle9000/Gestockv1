import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class NotificationService {
  
  /// Affiche un petit message discret en bas de l'écran (Success)
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Affiche une boîte de dialogue visuelle pour une action importante
  static void showSuccessDialog(BuildContext context, {required String title, required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      btnOkOnPress: () {
        // Force la fermeture si autoDismiss échoue
      },
      btnOkColor: Colors.green,
    ).show();
  }

  /// Affiche une erreur critique
  static void showErrorDialog(BuildContext context, {required String title, required String desc}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkOnPress: () {
        // Force la fermeture si autoDismiss échoue
      },
      btnOkColor: Colors.redAccent,
    ).show();
  }

  /// Affiche un avertissement (ex: Stock faible)
  static void showWarningDialog(BuildContext context, {required String title, required String desc, VoidCallback? onConfirm}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: title,
      desc: desc,
      btnCancelOnPress: () {},
      btnOkOnPress: onConfirm ?? () {},
      btnOkColor: Colors.orange,
    ).show();
  }
}
