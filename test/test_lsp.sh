#!/usr/bin/env bash
# LSP Stack Testing Script
# Tests that LSP servers attach correctly for different filetypes

set -e

NVIM_CONFIG_DIR="$(dirname "$0")/.."
TEST_DIR="$(dirname "$0")"

echo "🧪 Testing LSP Stack"
echo "===================="
echo ""

# Function to test LSP attachment for a file
test_lsp_attachment() {
    local file="$1"
    local expected_lsp="$2"
    local timeout="${3:-3000}"
    
    echo "Testing: $file"
    echo -n "  Expected LSP: $expected_lsp... "
    
    # Run nvim headless, open file, wait for LSP, check if expected server attached
    result=$(nvim --headless -c "edit $file" -c "lua vim.defer_fn(function() local clients = vim.lsp.get_clients({bufnr=0}); for _, client in ipairs(clients) do print(client.name) end; vim.cmd('qall!') end, $timeout)" 2>&1)
    
    if echo "$result" | grep -q "$expected_lsp"; then
        echo "✓ ATTACHED"
        return 0
    else
        echo "✗ NOT ATTACHED"
        echo "  Output: $result"
        return 1
    fi
}

# Test Lua LSP
echo "1. Lua Language Server"
test_lsp_attachment "$TEST_DIR/lua/test_sample.lua" "lua_ls" 3000
echo ""

# Test Python LSP
echo "2. Python Language Server"
test_lsp_attachment "$TEST_DIR/python/test_sample.py" "pyright\|pylsp" 3000
echo ""

# Test JavaScript LSP
echo "3. JavaScript Language Server"
test_lsp_attachment "$TEST_DIR/javascript/test_sample.js" "ts_ls\|tsserver" 3000
echo ""

# Test YAML LSP
echo "4. YAML Language Server"
test_lsp_attachment "$TEST_DIR/yaml/test_sample.yaml" "yamlls" 3000
echo ""

echo "===================="
echo "✅ LSP stack testing complete!"
echo ""
echo "Note: Some LSP servers may require installation via :Mason"
echo "Run ':LspInfo' in nvim to see detailed LSP status"
