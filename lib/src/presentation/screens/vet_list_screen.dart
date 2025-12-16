import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/vet_profile.dart';
import '../providers/vet_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/specialty_helper.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

class VetListScreen extends ConsumerStatefulWidget {
  const VetListScreen({super.key});

  @override
  ConsumerState<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends ConsumerState<VetListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(vetSearchQueryProvider.notifier).state = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    ref.read(vetSearchQueryProvider.notifier).state = query;
  }

  Future<void> _callVet(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidPhone),
            backgroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
        );
      }
    }
  }

  Future<void> _emailVet(String? email) async {
    if (email == null || email.isEmpty) return;

    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidEmail),
            backgroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
        );
      }
    }
  }

  Future<void> _setPreferred(VetProfile vet) async {
    try {
      await ref.read(vetRepositoryProvider).setPreferredVet(vet.id);
      // Invalidate providers to refresh list
      ref.invalidate(vetsProvider);
      ref.invalidate(filteredVetsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${vet.name} ${AppLocalizations.of(context)!.setAsPreferred}'),
            backgroundColor: DesignColors.highlightTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
        );
      }
    }
  }

  Future<void> _deleteVet(VetProfile vet) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_forever, color: dangerColor),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                l10n.deleteVet,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteVetConfirm,
          style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(vetRepositoryProvider).deleteVet(vet.id);
        // Invalidate providers to refresh list
        ref.invalidate(vetsProvider);
        ref.invalidate(filteredVetsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vetDeleted),
              backgroundColor: DesignColors.highlightTeal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: dangerColor,
            ),
          );
        }
      }
    }
  }

  void _showContextMenu(VetProfile vet) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: DesignSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? DesignColors.dDisabled : DesignColors.lDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit, color: DesignColors.highlightYellow),
                ),
                title: Text(
                  l10n.editVet,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/edit-vet/${vet.id}');
                },
              ),
              if (!vet.isPreferred)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignColors.highlightYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.star, color: DesignColors.highlightYellow),
                  ),
                  title: Text(
                    l10n.setAsPreferred,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _setPreferred(vet);
                  },
                ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dangerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete, color: dangerColor),
                ),
                title: Text(
                  l10n.deleteVet,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: dangerColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteVet(vet);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    final filteredVets = ref.watch(filteredVetsProvider);
    final searchQuery = ref.watch(vetSearchQueryProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: _isSearching
            ? Container(
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                  decoration: InputDecoration(
                    hintText: l10n.searchVets,
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.md,
                      vertical: DesignSpacing.sm + 2,
                    ),
                    prefixIcon: Icon(Icons.search, color: DesignColors.highlightYellow),
                  ),
                  onChanged: _onSearchChanged,
                ),
              )
            : Text(
                l10n.veterinarians,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: DesignColors.highlightYellow,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.add, color: DesignColors.highlightYellow),
            onPressed: () => context.push('/add-vet'),
          ),
        ],
      ),
      body: filteredVets.isEmpty
          ? _buildEmptyState(
              context, l10n, searchQuery, primaryText, secondaryText)
          : ListView.builder(
              padding: EdgeInsets.all(DesignSpacing.md),
              itemCount: filteredVets.length,
              itemBuilder: (context, index) {
                final vet = filteredVets[index];
                return _buildVetCard(
                  context,
                  vet,
                  l10n,
                  isDark,
                  surfaceColor,
                  primaryText,
                  secondaryText,
                  disabledColor,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-vet'),
        backgroundColor: DesignColors.highlightYellow,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addVet,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    String searchQuery,
    Color primaryText,
    Color secondaryText,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignColors.highlightYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.local_hospital_outlined,
              size: 40,
              color: DesignColors.highlightYellow,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          Text(
            searchQuery.isNotEmpty ? l10n.noVetsMatchSearch : l10n.noVetsAdded,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            SizedBox(height: DesignSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
              child: Text(
                l10n.addFirstVet,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-vet'),
              icon: const Icon(Icons.add),
              label: Text(
                l10n.addVet,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightYellow,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.sm + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVetCard(
    BuildContext context,
    VetProfile vet,
    AppLocalizations l10n,
    bool isDark,
    Color surfaceColor,
    Color primaryText,
    Color secondaryText,
    Color disabledColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm + 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vet.isPreferred
              ? DesignColors.highlightYellow.withOpacity(0.3)
              : disabledColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/vet-detail/${vet.id}'),
          onLongPress: () => _showContextMenu(vet),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vet icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DesignColors.highlightYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: DesignColors.highlightYellow,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm + 4),
                    // Vet info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vet.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (vet.isPreferred) ...[
                                SizedBox(width: DesignSpacing.xs),
                                Icon(
                                  Icons.star,
                                  color: DesignColors.highlightYellow,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: DesignSpacing.xs / 2),
                          Text(
                            vet.clinicName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Specialty chip
                    if (vet.specialty != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSpacing.sm,
                          vertical: DesignSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColors.highlightTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          SpecialtyHelper.getLocalizedSpecialty(
                            vet.specialty,
                            l10n,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DesignColors.highlightTeal,
                          ),
                        ),
                      ),
                  ],
                ),
                // Contact buttons
                if (vet.phoneNumber != null || vet.email != null) ...[
                  SizedBox(height: DesignSpacing.md),
                  Row(
                    children: [
                      if (vet.phoneNumber != null)
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.phone,
                            label: l10n.callVet,
                            onTap: () => _callVet(vet.phoneNumber),
                            color: DesignColors.highlightBlue,
                          ),
                        ),
                      if (vet.phoneNumber != null && vet.email != null)
                        SizedBox(width: DesignSpacing.sm),
                      if (vet.email != null)
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.email,
                            label: l10n.emailVet,
                            onTap: () => _emailVet(vet.email),
                            color: DesignColors.highlightPurple,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm + 4,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: DesignSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
