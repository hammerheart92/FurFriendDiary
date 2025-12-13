import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/typography.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

class DesignTokenTestScreen extends StatelessWidget {
  const DesignTokenTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.lBackground,
      appBar: AppBar(
        title: Text(
          'Design Token Test',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: DesignColors.highlightPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Typography
            Text(
              'Typography Test',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: DesignColors.lPrimaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            
            Text(
              'Body Regular Text',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: DesignColors.lSecondaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            
            // Test Cards with Shadows
            Text(
              'Cards & Shadows',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: DesignShadows.md,
              ),
              child: Text(
                'Card with Medium Shadow',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            
            // Test Highlight Colors
            Text(
              'Highlight Colors',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
              children: DesignColors.highlightColors.map((color) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: DesignShadows.sm,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: DesignSpacing.lg),
            
            // Test Status Colors
            Text(
              'Status Colors',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            
            _buildStatusChip('Success', DesignColors.lSuccess),
            SizedBox(height: DesignSpacing.sm),
            _buildStatusChip('Warning', DesignColors.lWarning),
            SizedBox(height: DesignSpacing.sm),
            _buildStatusChip('Danger', DesignColors.lDanger),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}