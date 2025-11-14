// utils.ts: Utility functions that import from math.ts
//
// This file demonstrates importing functions from another module
// and using LSP to find references and implementations

import { add, multiply, calculateTotal } from "./math";

/**
 * Calculate the average of a list of values
 * @param values Array of numbers to average
 * @returns The mean of all values
 */
export function calculateAverage(values: number[]): number {
	const total = calculateTotal(values);
	return total / values.length;
}

/**
 * Apply a discount percentage to a price
 * @param price The original price
 * @param discount The discount percentage (0-100)
 * @returns The final price after discount
 */
export function applyDiscount(price: number, discount: number): number {
	const discountAmount = price * (discount / 100);
	return price - discountAmount;
}

/**
 * Chain multiple operations together
 * @param value The starting value
 * @returns The result after chaining operations
 */
export function chainOperations(value: number): number {
	const step1 = add(value, 10);
	const step2 = multiply(step1, 2);
	return add(step2, 5);
}
