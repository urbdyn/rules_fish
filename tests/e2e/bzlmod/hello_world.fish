#!/usr/bin/env fish

echo "hello fish"
echo "status current-command: $(status current-command)"
echo "status fish-path: $(status fish-path)"
echo "status current-commandline: $(status current-commandline)"
set -l fish (status fish-path)
$fish --version
