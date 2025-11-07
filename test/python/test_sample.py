"""
Test file for Python LSP, linting, and formatting.
Contains intentional errors for testing diagnostics.
"""

import os
import sys


def calculate_sum(a, b):
    """Calculate sum of two numbers."""
    # Intentional type error for LSP testing
    return a + b + "string"


def unused_function():
    """This function is intentionally unused for linter testing."""
    x = 10  # Unused variable
    pass


class SampleClass:
    def __init__(self, name):
        self.name = name
        self.unused_attr = None  # Unused attribute

    def greet(self):
        # Missing return type annotation
        print(f"Hello, {self.name}")
        # Intentional undefined variable
        return undefined_var


if __name__ == "__main__":
    result = calculate_sum(5, 10)
    print(result)
