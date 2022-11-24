const EPSILON = 2.220446049250313e-16;

export default function approximatelyEqual(a: number, b: number, error = 1e-10) {
  return Math.abs(a - b) - error < EPSILON;
}