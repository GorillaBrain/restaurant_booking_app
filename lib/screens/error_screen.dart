import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/venera_theme.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.is404 = true, this.detail});

  final bool is404;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withOpacity(0.1),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                is404 ? 'Page Not Found' : 'Something Went Wrong',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(fontSize: 28, color: AppColors.cream),
              ),
              const SizedBox(height: 12),
              Text(
                is404
                    ? "The page you're looking for doesn't exist or has been moved."
                    : 'We encountered an unexpected error. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.cream.withOpacity(0.6)),
              ),
              if (detail != null && detail!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(detail!, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.danger.withOpacity(0.6))),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cream.withOpacity(0.8),
                      side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: goldGradient(), borderRadius: BorderRadius.circular(8)),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
                      style: TextButton.styleFrom(foregroundColor: AppColors.canvas, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      child: const Text('Go Home', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
