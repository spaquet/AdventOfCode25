#!/usr/bin/env python3
"""
Advent of Code 2025 - Day 3: Lobby
Find the maximum joltage from each battery bank and sum them.
"""

def find_max_joltage(bank):
    """
    Find the maximum joltage possible from a battery bank.
    We need to pick exactly 2 batteries to form a 2-digit number.
    The batteries maintain their order (cannot be rearranged).
    Strategy: Try all pairs (i, j) where i < j and find the maximum value.
    """
    max_joltage = 0
    
    # Try all pairs of positions
    for i in range(len(bank)):
        for j in range(i + 1, len(bank)):
            # Form the 2-digit number from positions i and j
            joltage = int(bank[i]) * 10 + int(bank[j])
            max_joltage = max(max_joltage, joltage)
    
    return max_joltage

def solve(filename):
    """Read the input file and calculate total output joltage."""
    total_joltage = 0
    
    with open(filename, 'r') as f:
        for line in f:
            bank = line.strip()
            if bank:  # Skip empty lines
                max_joltage = find_max_joltage(bank)
                total_joltage += max_joltage
    
    return total_joltage

if __name__ == "__main__":
    # Test with the example
    example = [
        "987654321111111",
        "811111111111119",
        "234234234234278",
        "818181911112111"
    ]
    
    print("Testing with example:")
    example_total = 0
    for bank in example:
        max_joltage = find_max_joltage(bank)
        print(f"{bank}: {max_joltage}")
        example_total += max_joltage
    print(f"Example total: {example_total}")
    print(f"Expected: 357")
    print()
    
    # Solve the actual puzzle
    result = solve("input.txt")
    print(f"Total output joltage: {result}")
