"""
Calculator module demonstrating LSP features.

This file is part of the LSP demo. Try these keybindings:
- gd: Jump to definition of functions
- gri: Jump to implementations
- grn: Rename a function/variable (workspace-wide)
- gra: Code actions (try adding type hints)
"""

from collections.abc import Sequence


def add(a: int | float, b: int | float) -> int | float:
	"""Add two numbers together."""
	return a + b


def multiply(a: int | float, b: int | float) -> int | float:
	"""Multiply two numbers."""
	return a * b


def calculate_total(values: Sequence[int | float]) -> int | float:
	"""Calculate the total of a list of values."""
	result: int | float = 0
	for value in values:
		result = add(result, value)
	return result


def calculate_product(values: Sequence[int | float]) -> int | float:
	"""Calculate the product of a list of values."""
	result: int | float = 1
	for value in values:
		result = multiply(result, value)
	return result
