"""
Main entry point for the LSP demo.

This file demonstrates LSP features like:
- grn: Rename variables across multiple files
- gr: See all places where a function is used
- gd: Jump to where something is defined
- gri: Find all implementations of a function
"""

from .calculator import calculate_product, calculate_total
from .utils import apply_discount, calculate_average, chain_operations


def main() -> dict[str, int | float]:
    """Main function showcasing all the demo utilities."""
    # Test data
    numbers: list[int] = [1, 2, 3, 4, 5]

    # Test calculate_total (defined in calculator.py)
    # Try: gd to jump to the definition
    total: int | float = calculate_total(numbers)
    print(f"Total: {total}")

    # Test calculate_product (defined in calculator.py)
    # Try: grn on calculate_product to rename it everywhere
    product: int | float = calculate_product(numbers)
    print(f"Product: {product}")

    # Test calculate_average (defined in utils.py)
    # Try: gr on calculate_average to see all references
    average: float = calculate_average(numbers)
    print(f"Average: {average}")

    # Test apply_discount
    # Try: K on apply_discount to see the docstring
    price: float = 100.0
    discount: float = 10.0
    final_price: int | float = apply_discount(price, discount)
    print(f"Price after {discount}% discount: ${final_price}")

    # Test chain_operations
    # Try: gr on chain_operations to see where it's called
    result: int | float = chain_operations(5)
    print(f"Chain result: {result}")

    return {
        "total": total,
        "product": product,
        "average": average,
        "final_price": final_price,
        "chain_result": result,
    }


if __name__ == "__main__":
    output: dict[str, int | float] = main()
    print("\nFinal results:")
    for key, value in output.items():
        print(f"  {key}: {value}")
