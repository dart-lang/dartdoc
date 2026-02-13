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

## 3. Environment Notes
- Some tests depend on a valid Flutter SDK being present in the environment
  (e.g., `model_special_cases_test.dart`). If these fail due to missing
  executables, it may be an environment issue rather than a logic regression.
- Always use `dart analyze .` and `dart format .` before final submission.
