## 1.0.0

- Initial release of clean_archt_lint
- Implements custom lint rules for Flutter Clean Architecture
- **Rules:**
  - `core_no_flutter`: Prevents Flutter/UI imports in core layer (ERROR)
  - `core_no_data_or_presentation`: Prevents core from depending on data/presentation layers (ERROR)
  - `data_no_presentation`: Prevents data layer from depending on presentation layer (ERROR)
  - `presentation_no_data`: Warns when presentation depends directly on data layer (WARNING, configurable to ERROR)
- Utility functions for import resolution and path normalization
- Comprehensive example project demonstrating correct architecture
- Full documentation and usage guide
