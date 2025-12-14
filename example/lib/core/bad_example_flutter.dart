// EXEMPLO DE VIOLAÇÃO: core_no_flutter
// Este arquivo demonstra o erro que será reportado
// quando o core tentar importar Flutter.

// ignore_for_file: unused_import

// ❌ ERRO: Core não pode depender de Flutter/UI
// import 'package:flutter/material.dart';

/// Este é um exemplo comentado para não quebrar a build.
/// Descomente o import acima para ver o lint em ação.
class BadExampleFlutter {
  void someMethod() {
    // Tentativa de usar Flutter no core
  }
}
