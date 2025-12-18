import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/medication_purchase.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/medications_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../ui/widgets/medication_card.dart'; // Import for StockUnitTranslation extension

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
  final _logger = Logger();

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

      // Debug logging for purchase record
      _logger.i('💊 Creating purchase record:');
      _logger.i('  Medication: ${widget.medication.medicationName}');
      _logger.i('  Quantity: $quantity');
      _logger.i('  Cost: \$${cost.toStringAsFixed(2)}');
      _logger.i('  Pharmacy: ${purchase.pharmacy ?? "(not specified)"}');
      _logger.i('  Date: ${DateFormat('MMM dd, yyyy').format(_purchaseDate)}');

      // Add purchase to repository
      final purchaseRepo = ref.read(purchaseRepositoryProvider);
      await purchaseRepo.addPurchase(purchase);

      // Update medication stock AND last purchase date together
      final medicationRepo = ref.read(medicationsRepositoryProvider);

      // Get current medication to calculate new stock
      final currentMedication =
          await medicationRepo.getMedicationById(widget.medication.id);
      if (currentMedication != null) {
        final currentStock = currentMedication.stockQuantity ?? 0;
        final newStock = currentStock + quantity;

        // Debug logging
        _logger.i('🔄 Adding refill to ${currentMedication.medicationName}');
        _logger.i('📊 Current stock: $currentStock');
        _logger.i('➕ Adding quantity: $quantity');
        _logger.i('📈 New stock will be: $newStock');

        // Update both stock and last purchase date in one operation
        final updatedMedication = currentMedication.copyWith(
          stockQuantity: newStock,
          lastPurchaseDate: _purchaseDate,
        );
        await medicationRepo.updateMedication(updatedMedication);

        _logger.i('✅ Stock update saved successfully to Hive');
      } else {
        _logger.e('🚨 Medication not found with ID: ${widget.medication.id}');
        throw Exception('Medication not found');
      }

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
    } catch (e, stackTrace) {
      _logger.e('🚨 Failed to add refill', error: e, stackTrace: stackTrace);
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
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? DesignShadows.darkLg : DesignShadows.lg,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DesignColors.highlightTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: DesignColors.highlightTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addRefill,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: DesignSpacing.xs),
                            Text(
                              widget.medication.medicationName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSpacing.lg),

                  // Quantity Field (Required)
                  TextFormField(
                    controller: _quantityController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: '${l10n.quantityPurchased} *',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText:
                          l10n.translateStockUnit(widget.medication.stockUnit),
                      hintStyle: GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.inventory_2, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightTeal,
                          width: 2,
                        ),
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
                  const SizedBox(height: DesignSpacing.md),

                  // Cost Field (Optional)
                  TextFormField(
                    controller: _costController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: '${l10n.cost} (${l10n.optional})',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText: '0.00',
                      hintStyle: GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.attach_money, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightTeal,
                          width: 2,
                        ),
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
                  const SizedBox(height: DesignSpacing.md),

                  // Purchase Date Field
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.purchaseDate,
                        labelStyle: GoogleFonts.inter(color: secondaryText),
                        prefixIcon: Icon(Icons.calendar_today, color: secondaryText),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        DateFormat.yMMMd().format(_purchaseDate),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Pharmacy Field (Optional)
                  TextFormField(
                    controller: _pharmacyController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: '${l10n.pharmacy} (${l10n.optional})',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText: 'e.g., CVS, Walgreens',
                      hintStyle: GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.store, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Notes Field (Optional)
                  TextFormField(
                    controller: _notesController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: '${l10n.notes} (${l10n.optional})',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText: 'Additional details...',
                      hintStyle: GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.note, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignSpacing.lg),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.md),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _savePurchase,
                        style: FilledButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignSpacing.lg,
                            vertical: DesignSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                        label: Text(
                          l10n.save,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
