import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Token actual en memoria para inyectarlo en el cliente HTTP.
final authTokenProvider = StateProvider<String?>((ref) => null);
