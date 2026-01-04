#!/usr/bin/env zsh
# Test file for zsh LSP, linting, and formatting support

# Test basic zsh syntax
test_function() {
  local var="hello"
  echo "$var world"
}

# Test zsh arrays (start at 1, not 0)
arr=(first second third)
echo "${arr[1]}"

# Test parameter expansion
name="test"
echo "${name:u}"

# Intentional shellcheck warning - missing quotes
file=test file.txt
echo $file

# Test conditionals
if [[ -f ~/.zshrc ]]; then
  echo "zshrc exists"
fi

test_function
