# Quick Molten Test
# Test jupyter notebook integration in 3 minutes

import numpy as np
import matplotlib.pyplot as plt

# Test 1: Simple calculation
print("=== Test 1: Basic Python ===")
x = 5
y = 10
result = x + y
print(f"x + y = {result}")

# Test 2: Data manipulation
print("\n=== Test 2: NumPy ===")
arr = np.array([1, 2, 3, 4, 5])
print(f"Array: {arr}")
print(f"Sum: {arr.sum()}")
print(f"Mean: {arr.mean()}")

# Test 3: Simple plot
print("\n=== Test 3: Matplotlib ===")
x = np.linspace(0, 10, 100)
y = np.sin(x)
plt.figure(figsize=(8, 4))
plt.plot(x, y)
plt.title("Simple Sin Wave")
plt.xlabel("X")
plt.ylabel("Y")
plt.grid(True)
plt.show()

# Test 4: List comprehension
print("\n=== Test 4: List Comprehension ===")
squares = [i**2 for i in range(10)]
print(f"Squares: {squares}")

# Test 5: Error handling
print("\n=== Test 5: Error Test ===")
try:
    result = 10 / 0
except ZeroDivisionError as e:
    print(f"Caught error: {e}")

print("\n=== All tests complete! ===")