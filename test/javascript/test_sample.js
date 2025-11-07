/**
 * Test file for JavaScript LSP and linting.
 * Contains intentional errors for testing diagnostics.
 */

// Intentional unused variable
const unusedVar = 10;

// Function with type error
function calculateSum(a, b) {
  // Intentional type mismatch
  return a + b + undefinedVariable;
}

// Missing semicolon (ESLint test)
const greeting = "Hello, World!"

// Unused function
function unusedFunction() {
  const x = 5;
  // Missing return
}

// Class with issues
class SampleClass {
  constructor(name) {
    this.name = name;
    this.unusedProperty = null;
  }

  greet() {
    console.log(`Hello, ${this.name}`);
    // Intentional undefined variable
    return undefinedVar;
  }
}

// Main execution
const result = calculateSum(5, 10);
console.log(result);
