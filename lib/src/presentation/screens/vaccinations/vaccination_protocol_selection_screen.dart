// File: lib/src/presentation/screens/vaccinations/vaccination_protocol_selection_screen.dart
// Purpose: Protocol selection screen that generates vaccination events after selection
//
// This screen extends the standard protocol selection flow by:
// 1. Showing available vaccination protocols for the pet's species
// 2. After user confirms selection, calling VaccinationService.generateVaccinationsFromProtocol()
// 3. Creating actual VaccinationEvent records in the database

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../data/services/vaccination_service.dart';
import '../../providers/protocols/vaccination_protocol_provider.dart';
import '../../providers/pet_profile_provider.dart';
import '../../providers/vaccinations_provider.dart';

/// Vaccination Protocol Selection Screen
///
/// This screen allows users to select a vaccination protocol for their pet
/// and generates actual vaccination event records based on the protocol schedule.
///
/// **Flow:**
/// 1. Display available protocols filtered by pet species
/// 2. User taps on a protocol
/// 3. Confirmation bottom sheet shows protocol details
/// 4. On confirm:
///    a. Update pet profile with selected protocol ID
///    b. Call VaccinationService.generateVaccinationsFromProtocol()
///    c. Show success message and return to timeline
class VaccinationProtocolSelectionScreen extends ConsumerWidget {
  final PetProfile pet;
  final Logger _logger = Logger();

  VaccinationProtocolSelectionScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final protocolsAsync = ref.watch(
      vaccinationProtocolsBySpeciesProvider(pet.species),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectVaccinationProtocol),
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

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Semantics(
        label: l10n.loadingProtocols,
        child: const CircularProgressIndicator(),
      ),
    );
  }

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
              l10n.failedToLoadProtocols,
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
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(vaccinationProtocolsBySpeciesProvider(pet.species));
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noProtocolsAvailable,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noProtocolsForSpecies(pet.species),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolList(
    BuildContext context,
    AppLocalizations l10n,
    List<VaccinationProtocol> protocols,
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
            l10n.selectVaccinationProtocol,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          // Helper text
          Text(
            l10n.chooseProtocolMatchingNeeds,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
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

  Future<void> _showConfirmationSheet(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationProtocol protocol,
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
        onConfirm: () => _applyProtocolAndGenerateVaccinations(
          context,
          l10n,
          protocol,
          ref,
        ),
      ),
    );
  }

  /// Apply protocol AND generate vaccination events
  Future<void> _applyProtocolAndGenerateVaccinations(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationProtocol protocol,
    WidgetRef ref,
  ) async {
    try {
      _logger.d('Applying protocol ${protocol.id} to pet ${pet.id} and generating vaccinations');

      // Step 1: Update pet profile with protocol ID
      final updatedPet = pet.copyWith(
        vaccinationProtocolId: protocol.id,
      );
      await ref.read(petProfilesProvider.notifier).createOrUpdate(updatedPet);

      // Step 2: Generate vaccination events from protocol
      final vaccinationService = ref.read(vaccinationServiceProvider);
      final generatedEvents = await vaccinationService.generateVaccinationsFromProtocol(
        pet: updatedPet,
        protocolId: protocol.id,
        lookAheadMonths: 24, // Generate 2 years of vaccinations
      );

      _logger.i('Generated ${generatedEvents.length} vaccination events for pet ${pet.id}');

      // Step 3: Invalidate vaccinations provider to refresh the list
      ref.invalidate(vaccinationsByPetIdProvider(pet.id));
      ref.invalidate(vaccinationProviderProvider);

      if (context.mounted) {
        // Close bottom sheet
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.protocolAppliedSuccess(pet.name),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Return to vaccination timeline
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to apply protocol and generate vaccinations',
          error: e, stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.protocolApplyFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

class _PetInfoHeader extends StatelessWidget {
  final PetProfile pet;

  const _PetInfoHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.pets,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
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
                      label: Text(_getLocalizedSpecies(context, pet.species)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      labelStyle:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatAge(context, pet.birthday),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
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

  String _getLocalizedSpecies(BuildContext context, String species) {
    final l10n = AppLocalizations.of(context);
    switch (species.toLowerCase()) {
      case 'dog':
      case 'câine':
        return l10n.speciesDog;
      case 'cat':
      case 'pisică':
        return l10n.speciesCat;
      default:
        return species;
    }
  }

  String _formatAge(BuildContext context, DateTime? birthday) {
    final l10n = AppLocalizations.of(context);
    if (birthday == null) return l10n.pdfUnknown;
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

class _ProtocolCard extends StatelessWidget {
  final VaccinationProtocol protocol;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.protocol,
    required this.onTap,
  });

  bool get _isCore => protocol.name.toLowerCase().contains('core');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    final displayName =
        (isRomanian && protocol.nameRo != null && protocol.nameRo!.isNotEmpty)
            ? protocol.nameRo!
            : protocol.name;
    final displayDescription = (isRomanian &&
            protocol.descriptionRo != null &&
            protocol.descriptionRo!.isNotEmpty)
        ? protocol.descriptionRo!
        : protocol.description;

    return Card(
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            _isCore ? l10n.coreProtocol : l10n.extendedProtocol,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: _isCore
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.secondaryContainer,
                          labelStyle:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _isCore
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.vaccines,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.vaccinationsCount(protocol.steps.length),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBottomSheet extends StatefulWidget {
  final VaccinationProtocol protocol;
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    final displayName = (isRomanian &&
            widget.protocol.nameRo != null &&
            widget.protocol.nameRo!.isNotEmpty)
        ? widget.protocol.nameRo!
        : widget.protocol.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmProtocolSelection,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

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
                    ...widget.protocol.steps.take(5).map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                step.isRequired
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: step.isRequired
                                    ? Colors.green
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${step.vaccineName} ${l10n.atWeeksAge(step.ageInWeeks)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (widget.protocol.steps.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          l10n.andXMore(widget.protocol.steps.length - 5),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isApplying ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
