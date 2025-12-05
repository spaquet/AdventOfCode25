#!/usr/bin/env python3
"""
Advent of Code 2025 - Day 3 Part 2: Lobby
Find the maximum joltage from each battery bank by selecting exactly 12 batteries.
"""

def find_max_joltage_12(bank, k=12):
    """
    Find the maximum k-digit number by selecting k batteries from the bank.
    Uses a greedy approach: at each position, pick the largest digit that still
    allows us to pick enough remaining digits.
    
    This is similar to the "Remove K Digits" problem but in reverse.
    """
    n = len(bank)
    if k >= n:
        # If we need to select all or more digits than available, return the whole bank
        return int(bank)
    
    # We need to skip (n - k) digits
    to_skip = n - k
    
    # Use a stack-based approach to build the maximum number
    stack = []
    
    for i, digit in enumerate(bank):
        # While we can still skip digits and the current digit is larger than the last in stack
        # Remove smaller digits from the stack
        while stack and to_skip > 0 and stack[-1] < digit:
            stack.pop()
            to_skip -= 1
        
        stack.append(digit)
    
    # If we still need to skip digits, remove from the end
    while to_skip > 0:
        stack.pop()
        to_skip -= 1
    
    # Convert to integer
    result = int(''.join(stack))
    return result

def solve(filename, k=12):
    """Read the input file and calculate total output joltage."""
    total_joltage = 0
    
    with open(filename, 'r') as f:
        for line in f:
            bank = line.strip()
            if bank:  # Skip empty lines
                max_joltage = find_max_joltage_12(bank, k)
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
    
    print("Testing with example (Part 2 - 12 batteries):")
    example_total = 0
    for bank in example:
        max_joltage = find_max_joltage_12(bank, 12)
        print(f"{bank}: {max_joltage}")
        example_total += max_joltage
    print(f"Example total: {example_total}")
    print(f"Expected: 3121910778619")
    print()
    
    # Solve the actual puzzle
    result = solve("input.txt", 12)
    print(f"Total output joltage (Part 2): {result}")
