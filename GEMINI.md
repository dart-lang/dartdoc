# Local Verification for AI Agents

To ensure code stability and avoid regressions, AI agents MUST perform the
following verification steps locally before pushing changes.

## 1. Run full build and task suite
The project uses a custom task runner. Execute the `buildbot` task to perform
linting, formatting checks, code generation validation, and full test execution.

```bash
dart run tool/task.dart buildbot
```

**IMPORTANT:** If `buildbot` fails with "generated files needed to be rebuilt",
run:
```bash
dart run tool/task.dart build
```
Then commit the resulting changes before rerunning `buildbot`.

## 2. Verify specific logic areas
If you modified canonicalization or documentation rendering, verify these
specific test groups:

- **Canonicalization:** Run `dart run test test/canonical_for_test.dart` and 
  `dart run test test/model_utils_test.dart`.
- **Warnings:** Many tests assert on the exact number of warnings (e.g., `test/options_test.dart`). 
  If your changes cause new warnings, verify if they are legitimate or if 
  canonicalization is failing.
- **Duplicate Outputs:** Watch for "file already written" errors in test output, 
  which often indicate multiple elements being canonicalized to the same path.

## 3. Environment Notes
- Some tests depend on a valid Flutter SDK being present in the environment
  (e.g., `model_special_cases_test.dart`). If these fail due to missing
  executables, it may be an environment issue rather than a logic regression.
- Always use `dart analyze .` and `dart format .` before final submission.
