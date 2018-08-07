import "mustache_context_test.dart" as context_test;
import "mustache_issues_test.dart" as issues_test;
import "mustache_line_test.dart" as line_test;
import "mustache_specs_test.dart" as specs_test;
import "mustache_test.dart" as general_test;
import "mustache_context_reflect_test.dart" as reflect_test;

void main() {
  context_test.main();
  issues_test.main();
  line_test.main();
  specs_test.main();
  general_test.main();
  reflect_test.main();
}
