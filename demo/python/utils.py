"""
Utility functions demonstrating LSP code navigation.

Try these keybindings on this file:
- gr: Find all references to a function
- K: Hover over a function to see docstring
- gra: Get code actions (e.g., add type hints)
"""

from collections.abc import Sequence
from typing import Any

from calculator import add, multiply


def validate_number(value: Any) -> bool:
    """Check if a value is a valid number."""
    try:
        float(value)
        return True
    except (TypeError, ValueError):
        return False


def calculate_average(numbers: Sequence[int | float]) -> float:
    """Calculate the average of a list of numbers."""
    if not numbers:
        return 0.0
    total: int | float = sum(numbers)  # type: ignore
    count: int = len(numbers)
    return float(total / count)


def apply_discount(
    original_price: int | float, discount_percent: int | float
) -> int | float:
    """Apply a discount to a price."""
    discount_amount: int | float = multiply(original_price, discount_percent / 100)
    final_price: int | float = add(original_price, -discount_amount)
    return final_price


def chain_operations(value: int | float) -> int | float:
    """Demonstrate multiple function calls for reference finding."""
    step1: int | float = add(value, 10)
    step2: int | float = multiply(step1, 2)
    step3: int | float = add(step2, 5)
    return step3
