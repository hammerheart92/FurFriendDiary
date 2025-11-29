import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';
import '../../providers/protocols/deworming_protocol_provider.dart';
import '../../providers/pet_profile_provider.dart';

/// Deworming Protocol Selection Screen - Allows users to select a deworming protocol for their pet
///
/// This screen displays available deworming protocols filtered by the pet's species
/// and allows the user to select one to apply to their pet.
///
/// Navigation: Expects a `PetProfile` object via state.extra
/// Returns: bool (true if protocol was applied successfully)
class DewormingProtocolSelectionScreen extends ConsumerWidget {
  final PetProfile pet;
  final Logger _logger = Logger();

  DewormingProtocolSelectionScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final protocolsAsync = ref.watch(
      dewormingProtocolsBySpeciesProvider(pet.species),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectDewormingProtocol),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Semantics(
          label: l10n.selectProtocolForPet(pet.name),
          child: protocolsAsync.when(
            loading: () => _buildLoadingState(l10n),
            error: (error, stack) => _buildErrorState(context, l10n, error, ref),
            data: (protocols) => protocols.isEmpty
                ? _buildEmptyState(context, l10n)
                : _buildProtocolList(context, l10n, protocols, ref),
          ),
        ),
      ),
    );
  }

  /// Loading state widget
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Semantics(
        label: l10n.loadingDewormingProtocols,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadDewormingProtocols,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().length > 100
                  ? '${error.toString().substring(0, 100)}...'
                  : error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(dewormingProtocolsBySpeciesProvider(pet.species));
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pest_control_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDewormingProtocolsAvailable,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noDewormingProtocolsForSpecies(pet.species),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  /// Main protocol list widget
  Widget _buildProtocolList(
    BuildContext context,
    AppLocalizations l10n,
    List<DewormingProtocol> protocols,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet info header
          _PetInfoHeader(pet: pet),
          const SizedBox(height: 16),

          // Section title
          Text(
            l10n.selectDewormingProtocol,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          // Helper text
          Text(
            l10n.chooseDewormingProtocol,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 16),

          // Protocol cards list
          Expanded(
            child: ListView.separated(
              itemCount: protocols.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final protocol = protocols[index];
                return _ProtocolCard(
                  protocol: protocol,
                  onTap: () => _showConfirmationSheet(context, l10n, protocol, ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation bottom sheet
  Future<void> _showConfirmationSheet(
    BuildContext context,
    AppLocalizations l10n,
    DewormingProtocol protocol,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _ConfirmationBottomSheet(
        protocol: protocol,
        pet: pet,
        onConfirm: () => _applyProtocol(context, l10n, protocol, ref),
      ),
    );
  }

  /// Apply protocol to pet
  Future<void> _applyProtocol(
    BuildContext context,
    AppLocalizations l10n,
    DewormingProtocol protocol,
    WidgetRef ref,
  ) async {
    try {
      _logger.d('Applying deworming protocol ${protocol.id} to pet ${pet.id}');

      // Update pet with new protocol ID
      final updatedPet = pet.copyWith(
        dewormingProtocolId: protocol.id,
      );

      await ref.read(petProfilesProvider.notifier).createOrUpdate(updatedPet);

      if (context.mounted) {
        // Close bottom sheet
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dewormingProtocolApplied(pet.name)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Return to previous screen with success result
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to apply deworming protocol', error: e, stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dewormingProtocolApplyFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: () => _applyProtocol(context, l10n, protocol, ref),
            ),
          ),
        );
      }
    }
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

/// Pet info header widget - displays pet details
class _PetInfoHeader extends StatelessWidget {
  final PetProfile pet;

  const _PetInfoHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Localize species display
    String getLocalizedSpecies(String species) {
      final lowerSpecies = species.toLowerCase();
      if (lowerSpecies == 'dog' || lowerSpecies == 'câine') {
        return l10n.speciesDog;
      } else if (lowerSpecies == 'cat' || lowerSpecies == 'pisică') {
        return l10n.speciesCat;
      }
      return species; // Fallback to original if not recognized
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pet photo/avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: pet.photoPath != null && pet.photoPath!.isNotEmpty
                ? AssetImage(pet.photoPath!)
                : null,
            child: pet.photoPath == null || pet.photoPath!.isEmpty
                ? Icon(
                    Icons.pets,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Pet name and species/age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(getLocalizedSpecies(pet.species)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatAge(pet.birthday, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(DateTime? birthday, AppLocalizations l10n) {
    if (birthday == null) return l10n.noBirthdaySet;
    final now = DateTime.now();
    final age = now.difference(birthday);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return l10n.ageYearsShort(years);
    } else if (months > 0) {
      return l10n.ageMonthsShort(months);
    } else {
      final weeks = age.inDays ~/ 7;
      return l10n.ageWeeksShort(weeks);
    }
  }
}

/// Protocol card widget - displays a single protocol
class _ProtocolCard extends StatelessWidget {
  final DewormingProtocol protocol;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.protocol,
    required this.onTap,
  });

  /// Determine if protocol is standard by checking if name contains "Standard"
  bool get _isStandard => protocol.name.toLowerCase().contains('standard');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    // Use Romanian translations if available
    final displayName = isRomanian && protocol.nameRo != null
        ? protocol.nameRo!
        : protocol.name;
    final displayDescription = isRomanian && protocol.descriptionRo != null
        ? protocol.descriptionRo!
        : protocol.description;

    return Semantics(
      label: '$displayName, '
          '${_isStandard ? l10n.coreProtocol : l10n.extendedProtocol}, '
          '${l10n.treatmentsCount(protocol.schedules.length)}, '
          '${protocol.region ?? 'Unknown'}',
      button: true,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Protocol name and badges
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Standard/Intensive badge
                          Chip(
                            label: Text(
                              _isStandard
                                  ? l10n.coreProtocol
                                  : l10n.extendedProtocol,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            backgroundColor: _isStandard
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.secondaryContainer,
                            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _isStandard
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                          ),
                          const SizedBox(width: 4),

                          // Predefined/Custom badge
                          Chip(
                            label: Text(
                              protocol.isCustom
                                  ? l10n.customProtocol
                                  : l10n.predefinedProtocol,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            backgroundColor: protocol.isCustom
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.tertiaryContainer,
                            side: protocol.isCustom
                                ? BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                  )
                                : null,
                            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: protocol.isCustom
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.onTertiaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        displayDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Metadata (treatment count and region)
                      Row(
                        children: [
                          Icon(
                            Icons.pest_control,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.treatmentsCount(protocol.schedules.length),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.public,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            protocol.region ?? 'Unknown',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron icon
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation bottom sheet - shows protocol summary and confirmation buttons
class _ConfirmationBottomSheet extends StatefulWidget {
  final DewormingProtocol protocol;
  final PetProfile pet;
  final VoidCallback onConfirm;

  const _ConfirmationBottomSheet({
    required this.protocol,
    required this.pet,
    required this.onConfirm,
  });

  @override
  State<_ConfirmationBottomSheet> createState() =>
      _ConfirmationBottomSheetState();
}

class _ConfirmationBottomSheetState extends State<_ConfirmationBottomSheet> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    // Use Romanian translations if available
    final displayName = isRomanian && widget.protocol.nameRo != null
        ? widget.protocol.nameRo!
        : widget.protocol.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              l10n.confirmProtocolSelection,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Protocol summary card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(height: 16),

                    // Show first 5 deworming schedules
                    ...widget.protocol.schedules
                        .take(5)
                        .map((schedule) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    schedule.dewormingType == 'internal'
                                        ? Icons.medication
                                        : Icons.pest_control,
                                    size: 16,
                                    color: schedule.dewormingType == 'internal'
                                        ? Colors.blue
                                        : Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${schedule.dewormingType == 'internal' ? l10n.internalDeworming : l10n.externalDeworming} ${l10n.atWeeksAge(schedule.ageInWeeks)}${schedule.productName != null ? ' - ${schedule.productName}' : ''}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                    // Show "...and X more" if there are more schedules
                    if (widget.protocol.schedules.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          l10n.andXMore(
                              widget.protocol.schedules.length - 5),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isApplying
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    label: l10n.applyProtocolToPet(
                      displayName,
                      widget.pet.name,
                    ),
                    button: true,
                    child: FilledButton(
                      onPressed: _isApplying
                          ? null
                          : () {
                              setState(() => _isApplying = true);
                              widget.onConfirm();
                            },
                      child: _isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.applyProtocol),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
