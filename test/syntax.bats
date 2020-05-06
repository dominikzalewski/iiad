#!/usr/bin/env bats

@test "check bash scripts syntax" {
	test/run-shellcheck-on-files.sh $(find . -name '*.sh')
}
