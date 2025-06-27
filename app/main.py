import math
from functools import lru_cache


def is_prime(n: int) -> bool:
    """Check if a number is prime."""
    if n <= 1:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.sqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


@lru_cache(maxsize=128)
def fibonacci(n: int) -> int:
    """Return the nth Fibonacci number using memoization."""
    if n < 0:
        raise ValueError("Fibonacci number is not defined for negative integers.")
    if n in (0, 1):
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


def normalize_vector(vec: list[float]) -> list[float]:
    """Normalize a vector to unit length."""
    norm = math.sqrt(sum(x**2 for x in vec))
    if norm == 0:
        raise ValueError("Zero vector cannot be normalized.")
    return [x / norm for x in vec]


if __name__ == "__main__":
    print("🔍 Prime check for 29:", is_prime(29))
    print("🧮 Fibonacci(10):", fibonacci(10))
    print("📐 Normalized vector [3, 4]:", normalize_vector([3, 4]))
