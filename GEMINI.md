# Local Verification for AI Agents

To ensure code stability and avoid regressions, AI agents MUST perform the following verification steps locally before pushing changes.

## 1. Run full build and task suite
The project uses a custom task runner. Execute the `buildbot` task to perform linting, formatting checks, code generation validation, and full test execution.

```bash
dart run tool/task.dart buildbot
```

**IMPORTANT:** If `buildbot` fails with "generated files needed to be rebuilt", run:
```bash
dart run tool/task.dart build
```
Then commit the resulting changes before rerunning `buildbot`.

## 2. Verify specific logic areas
If you modified canonicalization or documentation rendering, verify these specific test groups:

```bash
# Canonicalization and @canonicalFor
dart run test test/canonical_for_test.dart

# SDK and inherited members interlinking
dart run test --plain-name="Missing and Remote" test/end2end/model_test.dart
dart run test --plain-name="inherited method from the core SDK" test/end2end/model_test.dart

# Documentation rendering (especially inherited members)
dart run test --plain-name="Docs as HTML full documentation references" test/end2end/model_test.dart
```

## 3. Verify against external reproductions
Always verify changes against known complex scenarios, like `google_cloud`:

1. Clone or navigate to the reproduction repository.
2. Run `dartdoc` using the local version of the tool.
3. Check for unexpected warnings or broken links.

## 4. Environment Notes
- Some tests depend on a valid Flutter SDK being present in the environment (e.g., `model_special_cases_test.dart`). If these fail due to missing executables, it may be an environment issue rather than a logic regression.
- Always use `dart analyze .` and `dart format .` before final submission.
