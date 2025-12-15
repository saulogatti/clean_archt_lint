## 1.0.1

- **Documentation improvements** following Dart Effective Documentation guidelines:
  - Added comprehensive doc comments to all public APIs
  - Enhanced library-level documentation with usage examples
  - Improved documentation for all utility functions in `import_resolver.dart`
  - Added detailed examples for each lint rule showing violations and solutions
  - Documented parameters, return values, and edge cases
  - Added code examples using markdown code blocks with syntax highlighting
  - Improved readability with proper formatting and structure
- All documentation now follows Dart conventions:
  - Uses `///` for doc comments
  - Starts with summary sentences
  - Uses third-person verbs for functions
  - Uses noun phrases for properties
  - Includes practical code examples
  - Uses `[]` for identifier references

## 1.0.0

- Initial release of clean_arch_lint
- Implements custom lint rules for Flutter Clean Architecture
- **Rules:**
  - `core_no_flutter`: Prevents Flutter/UI imports in core layer (ERROR)
  - `core_no_data_or_presentation`: Prevents core from depending on data/presentation layers (ERROR)
  - `data_no_presentation`: Prevents data layer from depending on presentation layer (ERROR)
  - `presentation_no_data`: Warns when presentation depends directly on data layer (WARNING, configurable to ERROR)
- Utility functions for import resolution and path normalization
- Comprehensive example project demonstrating correct architecture
- Full documentation and usage guide
