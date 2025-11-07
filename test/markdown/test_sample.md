# Test Markdown File

This file is for testing Markdown features in Neovim.

## Features to Test

1. Syntax highlighting
2. LSP features
3. Formatting
4. Link navigation

### Code Blocks

```python
def hello_world():
    print("Hello from markdown code block")
```

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
}
```

### Links and References

- [Valid Link](https://example.com)
- [Broken Link](file://nonexistent.md)

### Lists

- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
- Item 3

### Intentional Issues

This is a very long line that might trigger formatting or linting warnings if configured to check line length in markdown files. It just keeps going and going.

[Unclosed link(https://example.com)

**Unclosed bold text

*Unclosed italic

### Tables

| Column 1 | Column 2 | Column 3 |
|----------|----------|
| Missing cell | Value 2 |

### YAML Frontmatter

---
title: Test Document
date: 2025-01-13
tags: [test, markdown, nvim
---
