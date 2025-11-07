#!/usr/bin/env bash
# Test file for Bash LSP and linting
# Contains intentional errors for testing diagnostics

# Intentional unused variable
UNUSED_VAR="unused"

# Function with intentional errors
calculate_sum() {
    local a=$1
    local b=$2
    # Intentional undefined variable
    echo $((a + b + undefined_var))
}

# Missing quotes (shellcheck warning)
file_path=/path/to/file with spaces.txt

# Unused function
unused_function() {
    local x=5
    # No return or output
}

# Missing error handling
cd /nonexistent/directory
ls -la

# Intentional syntax error (unclosed quote)
# echo "This is unclosed

# Deprecated syntax
if [ $x == "test" ]; then  # Should use = not ==
    echo "Equal"
fi

# Main execution
result=$(calculate_sum 5 10)
echo "Result: $result"
