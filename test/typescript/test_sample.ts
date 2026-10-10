// Test file for TypeScript LSP, linting, and formatting.
// Contains intentional errors for testing diagnostics.

interface User {
  id: number;
  name: string;
}

function greet(user: User): string {
  // Intentional type error: number is not assignable to string
  const label: string = user.id;
  return `Hello, ${user.name} (${label})`;
}

class Counter {
  private count = 0;

  increment(): number {
    this.count += 1;
    return this.count;
  }
}

// Intentional error: missing property `name`
const bob: User = { id: 1 };

console.log(greet(bob), new Counter().increment());
