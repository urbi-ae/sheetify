# 🤝 Contributing to Sheetify

Thanks for your interest in contributing to **Sheetify** — a modular, customizable sheet framework for Flutter! We welcome all contributions: code, documentation, bug reports, and feature suggestions.

## 🧱 How to Contribute

### 1. Fork & Clone

Start by forking the repository, then clone it:

```bash
git clone https://github.com/urbi-ae/sheetify.git
cd sheetify
```

Make sure you’re working on your own feature branch:

```bash
git checkout -b my-feature-branch
```

### 2. Setup Environment

Ensure you have:
- Flutter (latest stable channel)
- Dart SDK
- An IDE with Flutter support (e.g. VS Code or Android Studio)

Then run:
```bash
flutter pub get
flutter analyze
flutter test
```

### 3. Make Changes

Please follow our style guidelines:
- ✅ Use meaningful naming for widgets and states
- ✅ Add documentation comments (///) for public APIs
- ✅ Prefer const constructors where possible

If you’re adding new sheet behaviors, snapping models, or animations — document them clearly and consider adding them to the example app.

### 4. Write Tests

We appreciate tests! If you’re introducing functionality, include appropriate:
- Unit tests (`test/[sheet_type]/models`/`test/[sheet_type]/behaviors`)
- Widget tests (`test/[sheet_type]/widgets/`)

Run tests with:
```bash
flutter test
```

### 5. Update Docs

If you update public APIs or introduce new features, don’t forget to:
 - Update the README.md with new usage examples
 - Add references in the API Overview section
 - Document behavior in code

### 6. Submit a Pull Request

Once your branch is ready:

```bash
git push origin my-feature-branch
```

Open a pull request to main with:
 - A clear title and description
 - Screenshots or video demos if it's a UI feature
 - Linked issue number (if applicable)

### 🧪 Types of Contributions

You can help by:
 - 📦 Adding new SnappingBehavior or ToggleSheetDelegate types
 - ✨ Improving animations, transitions, or UX patterns
 - 🐞 Fixing bugs or edge cases
 - 🧪 Adding or improving tests
 - 📚 Writing better docs or tutorials
 - 🧰 Creating visual examples in /example

### 🙌 Thank You!
We appreciate your contributions to Sheetify — together we make Flutter UI smoother and more expressive.

If you use Sheetify in a project, share it with us! We'd love to showcase your app.