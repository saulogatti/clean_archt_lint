# Exemplo de uso do clean_arch_lint

Este exemplo demonstra como usar o `clean_arch_lint` para garantir a arquitetura limpa em projetos Flutter/Dart.

## Estrutura

```
lib/
 ├─ core/
 │   ├─ entities/
 │   │   └─ user.dart
 │   └─ usecases/
 │       └─ get_user.dart
 ├─ data/
 │   ├─ models/
 │   │   └─ user_model.dart
 │   └─ repositories/
 │       └─ user_repository_impl.dart
 └─ presentation/
     └─ pages/
         └─ user_page.dart
```

## Como testar os lints

1. Execute o exemplo para ver a estrutura correta:
   ```bash
   dart run clean_archt_lint_example.dart
   ```

2. Para ver os lints em ação, descomente os imports nos arquivos:
   - `lib/core/bad_example_flutter.dart` - Demonstra `core_no_flutter`
   - `lib/core/bad_example_data.dart` - Demonstra `core_no_data_or_presentation`
   - `lib/data/bad_example_presentation.dart` - Demonstra `data_no_presentation`
   - `lib/presentation/bad_example_data.dart` - Demonstra `presentation_no_data`

3. Execute o custom_lint:
   ```bash
   dart run custom_lint
   ```

## Regras demonstradas

### ✅ Imports permitidos

- **core** → core
- **data** → core, data
- **presentation** → core, presentation

### ❌ Imports proibidos

- **core** → Flutter/UI (ERROR)
- **core** → data, presentation (ERROR)
- **data** → presentation (ERROR)
- **presentation** → data (WARNING configurável para ERROR)

## Arquitetura correta

```dart
// Dependency Injection
final GetUser getUser = UserRepositoryImpl();

// Presentation recebe apenas o contrato do core
final userPage = UserPage(getUser: getUser);

// Usa o usecase
await userPage.loadUser('1');
```

A presentation depende apenas da abstração (GetUser do core), e a implementação (UserRepositoryImpl do data) é injetada via DI.
