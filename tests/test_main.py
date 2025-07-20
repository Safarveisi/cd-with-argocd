import unittest

import pytest

from app.main import fibonacci, is_prime, normalize_vector


class TestMain(unittest.TestCase):
    def test_is_prime_true(self):
        self.assertTrue(is_prime(13))

    def test_is_prime_false(self):
        self.assertFalse(is_prime(15))
        self.assertFalse(is_prime(1))

    def test_fibonacci_base_cases(self):
        self.assertEqual(fibonacci(0), 0)
        self.assertEqual(fibonacci(1), 1)

    def test_fibonacci_recursive(self):
        self.assertEqual(fibonacci(10), 55)

    def test_fibonacci_negative(self):
        with self.assertRaises(ValueError):
            fibonacci(-1)

    def test_normalize_vector(self):
        vec = [3, 4]
        normed = normalize_vector(vec)
        self.assertAlmostEqual(sum(x**2 for x in normed), 1.0, places=5)

    def test_normalize_zero_vector(self):
        with self.assertRaises(ValueError):
            normalize_vector([0, 0])


@pytest.mark.parametrize("n,expected", [(2, True), (4, False), (17, True)])
def test_is_prime_param(n, expected):
    assert is_prime(n) == expected
