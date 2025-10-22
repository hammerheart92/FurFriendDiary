import 'package:hive/hive.dart';
import '../../domain/models/vet_profile.dart';

class VetRepository {
  final Box<VetProfile> _box;

  VetRepository(this._box);

  // CRUD operations
  Future<void> addVet(VetProfile vet) async {
    try {
      await _box.put(vet.id, vet);
    } catch (e) {
      throw Exception('Failed to add veterinarian: $e');
    }
  }

  Future<void> updateVet(VetProfile vet) async {
    try {
      await _box.put(vet.id, vet);
    } catch (e) {
      throw Exception('Failed to update veterinarian: $e');
    }
  }

  Future<void> deleteVet(String vetId) async {
    try {
      await _box.delete(vetId);
    } catch (e) {
      throw Exception('Failed to delete veterinarian: $e');
    }
  }

  VetProfile? getVetById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      return null;
    }
  }

  List<VetProfile> getAllVets() {
    try {
      return _box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<VetProfile>> getVetsStream() {
    return Stream.value(getAllVets()).asyncExpand((vets) async* {
      yield vets;
      await for (final _ in _box.watch()) {
        yield getAllVets();
      }
    });
  }

  // Business logic
  VetProfile? getPreferredVet() {
    try {
      return _box.values.firstWhere(
        (vet) => vet.isPreferred,
        orElse: () => throw StateError('No preferred vet found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> setPreferredVet(String vetId) async {
    try {
      // Get all vets
      final allVets = getAllVets();

      // Update all vets: set the selected one as preferred, others as not preferred
      for (final vet in allVets) {
        final updatedVet = vet.copyWith(
          isPreferred: vet.id == vetId,
        );
        await _box.put(updatedVet.id, updatedVet);
      }
    } catch (e) {
      throw Exception('Failed to set preferred veterinarian: $e');
    }
  }

  List<VetProfile> getVetsBySpecialty(String specialty) {
    try {
      return _box.values
          .where(
              (vet) => vet.specialty?.toLowerCase() == specialty.toLowerCase())
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateLastVisitDate(String vetId, DateTime date) async {
    try {
      final vet = getVetById(vetId);
      if (vet != null) {
        final updatedVet = vet.copyWith(lastVisitDate: date);
        await _box.put(vetId, updatedVet);
      }
    } catch (e) {
      throw Exception('Failed to update last visit date: $e');
    }
  }

  // Search/Filter
  List<VetProfile> searchVets(String query) {
    try {
      if (query.isEmpty) {
        return getAllVets();
      }

      final lowerQuery = query.toLowerCase();
      return _box.values.where((vet) {
        final nameLower = vet.name.toLowerCase();
        final clinicLower = vet.clinicName.toLowerCase();
        return nameLower.contains(lowerQuery) ||
            clinicLower.contains(lowerQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Statistics
  int getVetCount() {
    return _box.length;
  }

  bool hasPreferredVet() {
    return getPreferredVet() != null;
  }
}
