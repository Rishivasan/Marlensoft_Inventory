
import 'package:flutter/material.dart';

class DialogPannelHelper {
  void showAddPannel({
    required BuildContext context,
    required Widget addingItem,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: const Color.fromARGB(36, 0, 0, 0),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;

        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.6,
              height: size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                // ✅ Optional: rounded left side like modern UI
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                // ✅ Reduced padding (your UI was bulky because 24)
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.apply(
                          fontFamily: 'FiraSans',
                        ),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: addingItem,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

