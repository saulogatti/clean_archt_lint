# Contribuindo para clean_archt_lint

Obrigado por considerar contribuir com o clean_archt_lint! 🎉

## Como Contribuir

### Reportando Bugs

1. Verifique se o bug já não foi reportado nas [Issues](https://github.com/saulogatti/clean_archt_lint/issues)
2. Abra uma nova issue incluindo:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs. atual
   - Versão do Dart/Flutter
   - Exemplo de código que causa o problema

### Sugerindo Melhorias

1. Abra uma issue com a tag `enhancement`
2. Descreva claramente:
   - O problema que a melhoria resolve
   - A solução proposta
   - Exemplos de uso

### Contribuindo com Código

1. **Fork** o repositório
2. **Clone** seu fork:
   ```bash
   git clone https://github.com/seu-usuario/clean_archt_lint.git
   cd clean_archt_lint
   ```

3. **Crie uma branch** para sua feature/fix:
   ```bash
   git checkout -b feature/minha-feature
   ```

4. **Instale as dependências**:
   ```bash
   dart pub get
   ```

5. **Faça suas alterações** seguindo os padrões:
   - Siga o [Effective Dart](https://dart.dev/guides/language/effective-dart)
   - Use nomes descritivos para variáveis e funções
   - Adicione comentários quando necessário
   - Mantenha as linhas com até 80 caracteres quando possível

6. **Adicione testes** para suas alterações:
   ```bash
   dart test
   ```

7. **Commit suas mudanças**:
   ```bash
   git add .
   git commit -m "feat: adiciona nova funcionalidade X"
   ```
   
   Use [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` para novas funcionalidades
   - `fix:` para correções de bugs
   - `docs:` para mudanças na documentação
   - `test:` para adição/modificação de testes
   - `refactor:` para refatorações

8. **Push para seu fork**:
   ```bash
   git push origin feature/minha-feature
   ```

9. **Abra um Pull Request** explicando:
   - O que foi alterado
   - Por que foi alterado
   - Como testar as mudanças

## Estrutura do Projeto

```
clean_archt_lint/
├── lib/
│   ├── clean_archt_lint.dart       # Entry point do plugin
│   └── src/
│       ├── rules/                   # Regras de lint
│       │   ├── core_no_flutter.dart
│       │   ├── core_no_data_or_presentation.dart
│       │   ├── data_no_presentation.dart
│       │   └── presentation_no_data.dart
│       └── utils/
│           └── import_resolver.dart # Utilitários de resolução de imports
├── example/                         # Exemplo de uso
├── test/                           # Testes
└── docs/                           # Documentação adicional
```

## Adicionando uma Nova Regra de Lint

1. **Crie o arquivo da regra** em `lib/src/rules/`:
   ```dart
   // lib/src/rules/minha_regra.dart
   import 'package:analyzer/error/error.dart';
   import 'package:analyzer/error/listener.dart';
   import 'package:custom_lint_builder/custom_lint_builder.dart';
   
   class MinhaRegra extends DartLintRule {
     const MinhaRegra() : super(code: _code);
     
     static const _code = LintCode(
       name: 'minha_regra',
       problemMessage: 'Descrição do problema',
       correctionMessage: 'Como corrigir',
       errorSeverity: ErrorSeverity.WARNING,
     );
     
     @override
     void run(
       CustomLintResolver resolver,
       ErrorReporter reporter,
       CustomLintContext context,
     ) {
       // Implementação da regra
     }
   }
   ```

2. **Registre a regra** em `lib/clean_archt_lint.dart`:
   ```dart
   import 'src/rules/minha_regra.dart';
   
   class _CleanArchitectureLintPlugin extends PluginBase {
     @override
     List<LintRule> getLintRules(CustomLintConfigs configs) => [
           // ... outras regras
           const MinhaRegra(),
         ];
   }
   ```

3. **Adicione testes** em `test/`:
   ```dart
   test('minha_regra detecta violações corretamente', () {
     // Teste aqui
   });
   ```

4. **Documente** no README.md e USAGE.md

5. **Adicione exemplo** em `example/`

## Testando Localmente

### Teste o package principal:
```bash
dart test
```

### Teste com o exemplo:
```bash
cd example
dart pub get
dart run custom_lint
```

### Teste com um projeto real:
```bash
# No seu projeto de teste
dart pub get
dart run custom_lint
```

## Padrões de Código

### Documentação

- Use `///` para doc comments
- Documente todas as APIs públicas
- Inclua exemplos quando apropriado

### Nomenclatura

- Classes: `UpperCamelCase`
- Funções/variáveis: `lowerCamelCase`
- Constantes: `lowerCamelCase` (preferencial) ou `SCREAMING_CAPS`
- Arquivos: `snake_case.dart`

### Imports

1. Imports `dart:`
2. Imports `package:`
3. Imports relativos
4. Ordenação alfabética em cada grupo

Exemplo:
```dart
import 'dart:async';

import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/import_resolver.dart';
```

## Código de Conduta

- Seja respeitoso e profissional
- Aceite feedback construtivo
- Foque no que é melhor para o projeto
- Seja paciente com novos contribuidores

## Dúvidas?

Abra uma issue com a tag `question` ou entre em contato através do repositório.

Obrigado por contribuir! 🚀
