# Guia de Uso - clean_arch_lint

Este guia mostra como usar o `clean_arch_lint` em seus projetos Flutter/Dart.

## Instalação

### 1. Adicione as dependências no seu projeto

No arquivo `pubspec.yaml` do seu app Flutter:

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  clean_arch_lint:
    path: ../clean_arch_lint  # Ajuste o caminho conforme necessário
    # Ou, quando publicado:
    # clean_arch_lint: ^1.0.0
```

### 2. Configure o analyzer

No arquivo `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

### 3. Execute o lint

```bash
# Execução única
dart run custom_lint

# Modo watch (re-executa ao salvar arquivos)
dart run custom_lint --watch
```

---

## Estrutura de Camadas

O lint suporta duas estruturas de pastas:

### Estrutura 1: Direta (recomendada para projetos simples)
```
lib/
 ├─ core/          # Lógica de negócio pura
 │   ├─ entities/
 │   └─ usecases/
 ├─ data/          # Implementações técnicas
 │   ├─ models/
 │   ├─ datasources/
 │   └─ repositories/
 └─ presentation/  # Interface do usuário
     ├─ pages/
     ├─ widgets/
     └─ controllers/
```

### Estrutura 2: Com `src/` (comum em projetos maiores)
```
lib/
 └─ src/
     ├─ core/          # Lógica de negócio pura
     │   ├─ entities/
     │   └─ usecases/
     ├─ data/          # Implementações técnicas
     │   ├─ models/
     │   ├─ datasources/
     │   └─ repositories/
     └─ presentation/  # Interface do usuário
         ├─ pages/
         ├─ widgets/
         └─ controllers/
```

**Nota:** O lint detecta automaticamente qual estrutura você está usando. Ambas são totalmente suportadas!

---

## Regras de Lint

### 1. core_no_flutter (ERROR)

**O que faz:** Proíbe imports de Flutter na camada `core`.

**Bloqueios:**
- `package:flutter/*`
- `package:flutter_test/*`
- `dart:ui`

**Por quê:** O core deve ser totalmente independente de UI, permitindo:
- Testes unitários puros (sem depender do Flutter)
- Reutilização da lógica em outras plataformas
- Separação clara de responsabilidades

**Exemplo de violação:**
```dart
// ❌ ERRO em lib/core/entities/user.dart
import 'package:flutter/material.dart';

class User {
  final Color favoriteColor;  // Color é do Flutter!
}
```

**Solução:**
```dart
// ✅ OK em lib/core/entities/user.dart
class User {
  final int favoriteColorValue;  // Use int (0xFFRRGGBB)
}
```

---

### 2. core_no_data_or_presentation (ERROR)

**O que faz:** Proíbe o `core` de importar `data` ou `presentation`.

**Por quê:** O core é a camada mais interna. Dependências devem apontar **para dentro**, nunca para fora.

**Exemplo de violação:**
```dart
// ❌ ERRO em lib/core/usecases/get_user.dart
import '../../data/repositories/user_repository_impl.dart';

class GetUser {
  final UserRepositoryImpl repository;  // Importa implementação!
}
```

**Solução:**
```dart
// ✅ OK em lib/core/usecases/get_user.dart
abstract class UserRepository {
  Future<User?> getUser(String id);
}

class GetUser {
  final UserRepository repository;  // Usa abstração!
  
  const GetUser(this.repository);
  
  Future<User?> call(String id) => repository.getUser(id);
}
```

---

### 3. data_no_presentation (ERROR)

**O que faz:** Proíbe a camada `data` de importar `presentation`.

**Por quê:** Data é infraestrutura, não deve conhecer a UI.

**Exemplo de violação:**
```dart
// ❌ ERRO em lib/data/repositories/user_repository_impl.dart
import '../../presentation/controllers/user_controller.dart';

class UserRepositoryImpl {
  void notifyUI() {
    UserController.instance.update();  // Acoplamento com UI!
  }
}
```

**Solução:**
```dart
// ✅ OK - Use callbacks ou streams
class UserRepositoryImpl {
  final void Function()? onDataChanged;
  
  UserRepositoryImpl({this.onDataChanged});
  
  void notifyListeners() {
    onDataChanged?.call();
  }
}
```

---

### 4. presentation_no_data (WARNING)

**O que faz:** Desencoraja `presentation` de importar `data` diretamente.

**Severidade:** WARNING (configurável para ERROR)

**Por quê:** A UI deve depender apenas de abstrações (core). As implementações devem ser injetadas via DI.

**Exemplo de violação:**
```dart
// ⚠️ WARNING em lib/presentation/pages/user_page.dart
import '../../data/repositories/user_repository_impl.dart';

class UserPage {
  final repository = UserRepositoryImpl();  // Instancia diretamente!
}
```

**Solução:**
```dart
// ✅ OK
import '../../core/usecases/get_user.dart';

class UserPage {
  final GetUser getUser;  // Recebe abstração!
  
  const UserPage({required this.getUser});
}

// No arquivo de DI (ex: lib/core/di/injection.dart):
void setupDependencies() {
  getIt.registerFactory<GetUser>(
    () => GetUser(UserRepositoryImpl()),
  );
}
```

---

## Configuração Avançada

### Tornar presentation_no_data um ERROR

No `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - presentation_no_data:
        severity: error
```

### Ignorar arquivos específicos

Se você precisar ignorar uma regra em um arquivo específico:

```dart
// ignore_for_file: core_no_flutter
import 'package:flutter/material.dart';
```

Ou ignore apenas uma linha:

```dart
// ignore: core_no_data_or_presentation
import '../data/models/user_model.dart';
```

**Atenção:** Use `ignore` apenas em casos excepcionais e documentados!

---

## Fluxo de Dependências Correto

```
┌─────────────┐
│Presentation │  ← Usuário interage
└──────┬──────┘
       │ depende de
       ↓
┌─────────────┐
│    Core     │  ← Usecases e Entidades
└──────┬──────┘
       ↑ implementa
       │
┌─────────────┐
│    Data     │  ← Repositórios, APIs, DB
└─────────────┘
```

**Regra de ouro:** Dependências sempre apontam para dentro (para o core).

---

## Integração com CI/CD

### GitHub Actions

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      
      - name: Install dependencies
        run: dart pub get
      
      - name: Run custom lint
        run: dart run custom_lint
```

---

## Troubleshooting

### "Plugin custom_lint not found"

Execute:
```bash
dart pub get
```

### "No lint issues found" mas há violações

1. Verifique se `analysis_options.yaml` está configurado
2. Certifique-se de que os arquivos estão em `lib/core/`, `lib/data/` ou `lib/presentation/`
3. Execute `dart run custom_lint --watch` para ver em tempo real

### Lint não detecta imports relativos

O lint suporta tanto imports de pacote quanto relativos:
- `package:my_app/data/models/user.dart`
- `../data/models/user.dart`

Se um import não está sendo detectado, verifique se o caminho está correto.

---

## Melhores Práticas

1. **Execute o lint frequentemente** - Preferencialmente no modo watch
2. **Configure no CI** - Não deixe violações chegarem ao main
3. **Eduque o time** - Explique o porquê das regras
4. **Use DI** - Injeção de dependências é essencial para Clean Architecture
5. **Abstraia no core** - Toda regra de negócio deve estar no core

---

## Exemplos Práticos

Veja o diretório `example/` para exemplos completos de:
- ✅ Estrutura correta
- ❌ Violações de cada regra
- 🔧 Como corrigir cada tipo de erro

Execute:
```bash
cd example
dart run clean_archt_lint_example.dart
```

---

## Suporte

Problemas ou dúvidas? Abra uma issue no repositório:
https://github.com/saulogatti/clean_arch_lint/issues
