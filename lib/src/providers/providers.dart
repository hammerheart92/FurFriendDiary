
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/box_repository.dart';

final feedingsRepoProvider = Provider((_) => BoxRepository('feedings'));
final walksRepoProvider = Provider((_) => BoxRepository('walks'));
final medsRepoProvider = Provider((_) => BoxRepository('meds'));
final apptsRepoProvider = Provider((_) => BoxRepository('appointments'));
