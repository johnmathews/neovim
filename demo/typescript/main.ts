// main.ts: Main entry point for the LSP demo
//
// This file demonstrates LSP features like:
// - grn: Rename variables across multiple files
// - gr: See all places where a function is used
// - gd: Jump to where something is defined
// - gi: Find all implementations of a function

import { calculateTotal, calculateProduct } from "./math";
import { calculateAverage, applyDiscount, chainOperations } from "./utils";

/**
 * Main function showcasing all the demo utilities
 * @returns Object containing results from all demo operations
 */
function main(): Record<string, number> {
	// Test data
	const numbers: number[] = [1, 2, 3, 4, 5];

	// Test calculateTotal (defined in math.ts)
	// Try: gd to jump to the definition
	const total: number = calculateTotal(numbers);
	console.log(`Total: ${total}`);

	// Test calculateProduct (defined in math.ts)
	// Try: grn on calculateProduct to rename it everywhere
	const product: number = calculateProduct(numbers);
	console.log(`Product: ${product}`);

	// Test calculateAverage (defined in utils.ts)
	// Try: gr on calculateAverage to see all references
	const average: number = calculateAverage(numbers);
	console.log(`Average: ${average}`);

	// Test applyDiscount
	// Try: K on applyDiscount to see the docstring
	const price: number = 100.0;
	const discount: number = 10.0;
	const finalPrice: number = applyDiscount(price, discount);
	console.log(`Price after ${discount}% discount: $${finalPrice.toFixed(2)}`);

	// Test chainOperations
	// Try: gr on chainOperations to see where it's called
	const result: number = chainOperations(5);
	console.log(`Chain result: ${result}`);

	return {
		total,
		product,
		average,
		finalPrice,
		chainResult: result,
	};
}

// Run the main function
if (require.main === module) {
	const output = main();
	console.log("\nFinal results:");
	for (const [key, value] of Object.entries(output)) {
		console.log(`  ${key}: ${value}`);
	}
}

export { main };
