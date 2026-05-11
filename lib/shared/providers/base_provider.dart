import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

abstract class BaseProvider extends StarterChangeNotifier {
  @override
  Widget get loadingWidget => const CircularProgressIndicator();
}
