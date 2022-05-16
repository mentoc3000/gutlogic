import 'dart:math' as math;

export 'dart:math';

/// Returns the radian representation of [degrees].
double radians(num degrees) => degrees * math.pi / 180;

/// Returns the unclamped linear interpolation of range [a, b] by t.
double lerp(double t, double a, double b) => a + t * (b - a);

/// Returns the unclamped linear normalization of t within range [a, b].
double unlerp(double t, double a, double b) => (t - a) / (b - a);

/// Returns the unclamped linear remapping of t from range [a, b] to range [c, d].
double remap(double t, double a, double b, double c, double d) => lerp(unlerp(t, a, b), c, d);

/// Returns the clamped value of t within the range [a, b].
double clamp(double t, double a, double b) => math.max(math.min(t, b), a);

/// Returns the clamped value of t within the range [0, 1].
double saturate(double t) => clamp(t, 0.0, 1.0);
