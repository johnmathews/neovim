// Test file for TSX: commenting inside and outside JSX, and ts_ls diagnostics.
// Contains an intentional error for testing diagnostics.

type Props = { name: string };

export function Greeting({ name }: Props) {
  const upper = name.toUpperCase();
  return (
    <div className="greeting">
      <span>{upper}</span>
    </div>
  );
}

// Intentional error: missing prop `name`
export const broken = <Greeting />;
