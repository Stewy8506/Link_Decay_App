# Contributing to LinkShelf

We are excited that you want to contribute to LinkShelf! To keep the codebase clean, robust, and maintainable, we ask that all contributors follow these guidelines.

---

## ✦ Project Philosophy

LinkShelf is built around three core principles:
1. **Time as a Constraint**: The exponential/linear freshness decay model is the core of the app. Features should help users read their links rather than hoarding them indefinitely.
2. **Minimalist Aesthetic**: The design uses desaturated, neutral tones inspired by physical materials. Avoid adding bright, saturated primary colors without design review.
3. **Frictionless Onboarding**: We use silent anonymous sign-ins so users can use the app instantly. Any new features must respect and support this guest workflow.

---

## ✦ Coding Standards

To maintain code quality, please follow these Dart/Flutter standards:
- **Immutable Models**: All domain models under `lib/models/` must be immutable. Use `final` variables and provide serialized mapping helpers (`toMap()` / `fromMap()`).
- **Separation of Concerns**: Keep business logic out of widgets.
  - Use **Riverpod Notifiers** to manage state mutations.
  - Use **Services** (under `lib/services/`) for APIs, exports, and background integrations.
- **Null Safety**: Avoid force-unwrap operators (`!`). Use safe fallback operators (`??`) and conditional chains instead.
- **Analysis Profile**: Ensure your code passes all static checks configured in `analysis_options.yaml` without warnings:
  ```bash
  flutter analyze
  ```

---

## ✦ Git Commit & Branch Naming Conventions

We use semantic commit messages to keep our version history clean and readable.

### Commit Types:
- `feat`: A new user-facing feature.
- `fix`: A bug fix.
- `docs`: Documentation edits only.
- `style`: Formatting, missing semicolons, or design tweaks (no logic changes).
- `refactor`: Code changes that neither fix a bug nor add a feature.
- `test`: Adding or correcting tests.

*Example Commit:* `feat: add custom half-life overrides for domains`

### Branch Names:
- New features: `feature/short-description`
- Bug fixes: `bugfix/short-description`
- Documentation: `docs/short-description`

---

## ✦ Pull Request Checklist

Before submitting a Pull Request, ensure that you have completed these steps:

1. **Format Code**:
   ```bash
   flutter format lib/
   ```
2. **Run Static Analysis**:
   ```bash
   flutter analyze
   ```
3. **Verify App Build**:
   Ensure the application compiles and runs successfully on your target test platforms (e.g. Android or macOS).
4. **Documentation**:
   If your change updates or introduces a new architecture layer or feature, update the relevant files in `/docs`.
