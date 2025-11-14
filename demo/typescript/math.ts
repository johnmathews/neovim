// math.ts: Core mathematical functions demonstrating LSP features
//
// This file is part of the LSP demo. Try these keybindings:
// - gd: Jump to definition of functions
// - gi: Jump to implementations
// - grn: Rename a function/variable (workspace-wide)
// - gra: Code actions (try adding type hints)

/**
 * Add two numbers together
 * @param a First number
 * @param b Second number
 * @returns The sum of a and b
 */
export function add(a: number, b: number): number {
	return a + b;
}

/**
 * Multiply two numbers
 * @param a First number
 * @param b Second number
 * @returns The product of a and b
 */
export function multiply(a: number, b: number): number {
	return a * b;
}

/**
 * Calculate the total of a list of values
 * @param values Array of numbers to sum
 * @returns The sum of all values
 */
export function calculateTotal(values: number[]): number {
	let result = 0;
	for (const value of values) {
		result = add(result, value);
	}
	return result;
}

/**
 * Calculate the product of a list of values
 * @param values Array of numbers to multiply
 * @returns The product of all values
 */
export function calculateProduct(values: number[]): number {
	let result = 1;
	for (const value of values) {
		result = multiply(result, value);
	}
	return result;
}
