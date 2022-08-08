export type Result<T, E> = ValueResult<T> | ErrorResult<E>;

export type ValueResult<T> = { ok: true; value: T };
export type ErrorResult<E> = { ok: false; error: E };

export function ok<T, E>(value: T): Result<T, E> {
  return { ok: true, value };
}

export function err<T, E>(error: E): Result<T, E> {
  return { ok: false, error };
}

export function unwrap<T, E>(result: Result<T, E>): T {
  if (result.ok) return result.value;
  throw new Error("Attempted to unwrap error result.");
}
