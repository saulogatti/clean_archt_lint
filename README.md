# clean_arch_lint

Lint customizado para **Flutter Clean Architecture**, focado em **enforce de camadas** usando análise estática (AST) com `custom_lint`.

Este package atua como um **guardião da arquitetura**: se uma camada depender de quem não deve, o erro aparece na hora.

---

## 🎯 Objetivo

Garantir que a estrutura abaixo seja respeitada automaticamente:

```
lib/
 ├─ core/
 ├─ data/
 └─ presentation/
```

Sem discussão em PR. Sem “foi sem querer”. O lint resolve.

---

## 🧱 Conceito das camadas

### core

Camada pura, sem Flutter e sem infraestrutura.

Contém:

- entidades
- usecases
- contratos (interfaces)
- regras de negócio

### data

Implementações técnicas.

Contém:

- datasources
- models / DTOs
- mappers
- implementações de repositórios (`Impl`)

### presentation

Interface do usuário.

Contém:

- widgets
- pages
- bloc / cubit
- viewmodels / controllers

---

## 🚨 Regras de lint

### 1️⃣ core\_no\_flutter (ERROR)

❌ Proíbe imports de Flutter no `core`.

Bloqueia:

- `package:flutter/*`
- `dart:ui`
- `package:flutter_test/*`

Motivo: Core precisa ser totalmente independente de UI.

---

### 2️⃣ core\_no\_data\_or\_presentation (ERROR)

❌ Proíbe o `core` de depender de `data` ou `presentation`.

Regra de ouro da Clean Architecture:

> Dependências sempre apontam para dentro.

---

### 3️⃣ data\_no\_presentation (ERROR)

❌ `data` não pode importar nada de `presentation`.

Motivo:

- Evita acoplamento de infraestrutura com UI
- Garante testabilidade

---

### 4️⃣ presentation\_no\_data (WARNING configurável)

⚠️ Por padrão, `presentation` **não deve depender diretamente de `data`**.

✔️ Usecases e contratos devem vir do `core`.

Essa regra pode ser configurada para **ERROR**.

---

## 📦 Instalação

### 1) Adicione as dependências no app Flutter

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  clean_arch_lint:
    path: ../clean_arch_lint
    # Ou, quando publicado:
    # clean_arch_lint: ^1.0.0
```

> Ajuste o `path` conforme sua estrutura de repositórios.

---

### 2) Habilite o plugin no `analysis_options.yaml`

```yaml
analyzer:
  plugins:
    - custom_lint
```

---

## ▶️ Como rodar

```bash
# Execução única
dart run custom_lint

# Modo watch (re-executa ao salvar arquivos)
dart run custom_lint --watch
```

No VSCode / Android Studio:

- Os erros aparecem automaticamente no editor
- Funciona em tempo real enquanto você digita

---

## ⚙️ Configuração

### Tornar `presentation_no_data` um ERROR

```yaml
custom_lint:
  rules:
    - presentation_no_data:
        severity: error
```

---

### Ignorar paths específicos (exemplo)

```yaml
custom_lint:
  rules:
    - core_no_flutter:
        ignore:
          - lib/core/di/**
```

Útil para casos muito específicos como bootstrap de DI.

---

## ✅ Exemplos

### Import permitido

```dart
import 'package:my_app/core/usecases/get_user.dart';
```

### Import proibido (core → flutter)

```dart
import 'package:flutter/material.dart'; // ❌ erro
```

### Import proibido (presentation → data)

```dart
import 'package:my_app/data/user_repository_impl.dart'; // ⚠️ ou ❌
```

---

## 🧠 Boas práticas recomendadas

- Interfaces sempre no `core`
- Implementações sempre no `data`
- UI depende apenas de abstrações
- Injeção de dependência resolve o resto

---

## ❌ O que este lint NÃO faz

- Não gera código
- Não corrige automaticamente
- Não substitui code review

Ele apenas aponta o erro antes de virar dívida técnica.

---

## 🧩 Stack técnica

- Dart SDK >= 3.0
- analyzer
- custom\_lint\_builder
- path

Sem `build_runner`. Sem `source_gen`.

---

## 🏁 Resumo rápido

| Camada       | Pode depender de   |
| ------------ | ------------------ |
| core         | core apenas         |
| data         | core, data         |
| presentation | core, presentation |

Se passar disso, o lint apita.

---

Arquitetura limpa não é opinião. É contrato.

