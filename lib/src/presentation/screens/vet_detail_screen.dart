import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../domain/models/vet_profile.dart';
import '../../domain/models/appointment_entry.dart';
import '../providers/vet_provider.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../../l10n/app_localizations.dart';

class VetDetailScreen extends ConsumerWidget {
  final String vetId;

  const VetDetailScreen({super.key, required this.vetId});

  Future<void> _callVet(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidPhone),
          ),
        );
      }
    }
  }

  Future<void> _emailVet(BuildContext context, String? email) async {
    if (email == null || email.isEmpty) return;

    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidEmail),
          ),
        );
      }
    }
  }

  Future<void> _openWebsite(BuildContext context, String? website) async {
    if (website == null || website.isEmpty) return;

    // Add https:// if not present
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidWebsite),
          ),
        );
      }
    }
  }

  Future<void> _deleteVet(BuildContext context, WidgetRef ref, VetProfile vet) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVet),
        content: Text(l10n.deleteVetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(vetRepositoryProvider).deleteVet(vet.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.vetDeleted)),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _togglePreferred(BuildContext context, WidgetRef ref, VetProfile vet) async {
    try {
      if (vet.isPreferred) {
        // Cannot unset preferred directly, need to set another vet as preferred
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is already your preferred vet'),
          ),
        );
      } else {
        await ref.read(vetRepositoryProvider).setPreferredVet(vet.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vet.name} ${AppLocalizations.of(context)!.setAsPreferred}'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vet = ref.watch(vetDetailProvider(vetId));

    if (vet == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vetDetails)),
        body: const Center(child: Text('Vet not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vetDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-vet/$vetId'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteVet(context, ref, vet),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vet.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (vet.isPreferred)
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 32,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vet.clinicName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (vet.specialty != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(vet.specialty!),
                    ),
                  ],
                  if (!vet.isPreferred) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _togglePreferred(context, ref, vet),
                        icon: const Icon(Icons.star_border),
                        label: Text(l10n.setAsPreferred),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Card
          if (vet.phoneNumber != null ||
              vet.email != null ||
              vet.address != null ||
              vet.website != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (vet.phoneNumber != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone),
                        title: Text(vet.phoneNumber!),
                        trailing: IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () => _callVet(context, vet.phoneNumber),
                        ),
                      ),
                    ],
                    if (vet.email != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.email),
                        title: Text(vet.email!),
                        trailing: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _emailVet(context, vet.email),
                        ),
                      ),
                    ],
                    if (vet.address != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on),
                        title: Text(vet.address!),
                      ),
                    ],
                    if (vet.website != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.language),
                        title: Text(vet.website!),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _openWebsite(context, vet.website),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Statistics Card
          FutureBuilder<List<AppointmentEntry>>(
            future: ref.read(appointmentRepositoryProvider).getAllAppointments(),
            builder: (context, snapshot) {
              final allAppointments = snapshot.data ?? [];
              final vetAppointments = allAppointments
                  .where((apt) => apt.vetId == vetId)
                  .toList();

              // Sort by date descending
              vetAppointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

              final recentAppointments = vetAppointments.take(5).toList();

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: l10n.totalAppointments,
                                  value: vetAppointments.length.toString(),
                                  icon: Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  label: l10n.lastVisit,
                                  value: vet.lastVisitDate != null
                                      ? DateFormat.yMMMd().format(vet.lastVisitDate!)
                                      : 'N/A',
                                  icon: Icons.access_time,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recent Appointments
                  if (recentAppointments.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recentAppointments,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ...recentAppointments.map((appointment) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    appointment.isCompleted
                                        ? Icons.check_circle
                                        : Icons.schedule,
                                    color: appointment.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  title: Text(appointment.reason),
                                  subtitle: Text(
                                    DateFormat.yMMMd().format(appointment.appointmentDate),
                                  ),
                                  trailing: Icon(
                                    appointment.isCompleted
                                        ? Icons.check
                                        : Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Notes Card
          if (vet.notes != null && vet.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notes,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(vet.notes!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
