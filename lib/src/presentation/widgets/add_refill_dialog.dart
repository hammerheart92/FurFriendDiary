import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/medication_purchase.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/medications_provider.dart';
import '../../../l10n/app_localizations.dart';

class AddRefillDialog extends ConsumerStatefulWidget {
  final MedicationEntry medication;

  const AddRefillDialog({
    super.key,
    required this.medication,
  });

  @override
  ConsumerState<AddRefillDialog> createState() => _AddRefillDialogState();
}

class _AddRefillDialogState extends ConsumerState<AddRefillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _pharmacyController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _pharmacyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: l10n.purchaseDate,
    );

    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final quantity = int.parse(_quantityController.text);
      final cost = double.parse(
          _costController.text.isEmpty ? '0' : _costController.text);

      // Create purchase record
      final purchase = MedicationPurchase(
        medicationId: widget.medication.id,
        petId: widget.medication.petId,
        quantity: quantity,
        cost: cost,
        purchaseDate: _purchaseDate,
        pharmacy:
            _pharmacyController.text.isEmpty ? null : _pharmacyController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Add purchase to repository
      final purchaseRepo = ref.read(purchaseRepositoryProvider);
      await purchaseRepo.addPurchase(purchase);

      // Update medication stock
      final medicationRepo = ref.read(medicationsRepositoryProvider);
      await medicationRepo.addStock(widget.medication.id, quantity);

      // Update last purchase date
      final updatedMedication = widget.medication.copyWith(
        lastPurchaseDate: _purchaseDate,
      );
      await medicationRepo.updateMedication(updatedMedication);

      // Refresh medications list
      await ref.read(medicationsProvider.notifier).refresh();

      // Invalidate all inventory-related providers to ensure UI updates
      ref.invalidate(purchaseHistoryProvider(widget.medication.id));
      ref.invalidate(lowStockMedicationsProvider(widget.medication.petId));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.purchaseAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addRefill,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.medication.medicationName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity Field (Required)
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: '${l10n.quantityPurchased} *',
                      hintText: widget.medication.stockUnit ?? l10n.quantity,
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.invalidQuantity;
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return l10n.invalidQuantity;
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  // Cost Field (Optional)
                  TextFormField(
                    controller: _costController,
                    decoration: InputDecoration(
                      labelText: '${l10n.cost} (${l10n.optional})',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final cost = double.tryParse(value);
                        if (cost == null || cost < 0) {
                          return l10n.invalidCost;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Purchase Date Field
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.purchaseDate,
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(_purchaseDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pharmacy Field (Optional)
                  TextFormField(
                    controller: _pharmacyController,
                    decoration: InputDecoration(
                      labelText: '${l10n.pharmacy} (${l10n.optional})',
                      hintText: 'e.g., CVS, Walgreens',
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Notes Field (Optional)
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: '${l10n.notes} (${l10n.optional})',
                      hintText: 'Additional details...',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _savePurchase,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
