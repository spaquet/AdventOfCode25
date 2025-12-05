#!/usr/bin/env python3
"""
Advent of Code 2025 - Day 4 Part 2: Printing Department
Simulate the iterative removal of accessible paper rolls.
"""

def count_adjacent_rolls(grid, row, col):
    """
    Count the number of paper rolls (@) in the 8 adjacent positions.
    """
    rows = len(grid)
    cols = len(grid[0])
    count = 0
    
    # Check all 8 directions: up, down, left, right, and 4 diagonals
    directions = [
        (-1, -1), (-1, 0), (-1, 1),  # top-left, top, top-right
        (0, -1),           (0, 1),    # left, right
        (1, -1),  (1, 0),  (1, 1)     # bottom-left, bottom, bottom-right
    ]
    
    for dr, dc in directions:
        new_row = row + dr
        new_col = col + dc
        
        # Check if the position is within bounds
        if 0 <= new_row < rows and 0 <= new_col < cols:
            if grid[new_row][new_col] == '@':
                count += 1
    
    return count

def find_accessible_rolls(grid):
    """
    Find all rolls that can be accessed (have fewer than 4 adjacent rolls).
    Returns a list of (row, col) tuples.
    """
    accessible = []
    
    for row in range(len(grid)):
        for col in range(len(grid[row])):
            if grid[row][col] == '@':
                adjacent_rolls = count_adjacent_rolls(grid, row, col)
                if adjacent_rolls < 4:
                    accessible.append((row, col))
    
    return accessible

def remove_rolls(grid, positions):
    """
    Remove rolls at the given positions by replacing them with '.'.
    Modifies the grid in place.
    """
    for row, col in positions:
        grid[row][col] = '.'

def solve_part2(filename):
    """
    Simulate the iterative removal process.
    Keep removing accessible rolls until no more can be removed.
    """
    # Read the grid
    with open(filename, 'r') as f:
        grid = [list(line.strip()) for line in f if line.strip()]
    
    total_removed = 0
    iteration = 0
    
    while True:
        # Find all accessible rolls
        accessible = find_accessible_rolls(grid)
        
        if not accessible:
            # No more rolls can be removed
            break
        
        # Remove the accessible rolls
        remove_rolls(grid, accessible)
        total_removed += len(accessible)
        iteration += 1
        
        print(f"Iteration {iteration}: Removed {len(accessible)} rolls (total: {total_removed})")
    
    return total_removed

if __name__ == "__main__":
    # Test with the example
    example = [
        "..@@.@@@@.",
        "@@@.@.@.@@",
        "@@@@@.@.@@",
        "@.@@@@..@.",
        "@@.@@@@.@@",
        ".@@@@@@@.@",
        ".@.@.@.@@@",
        "@.@@@.@@@@",
        ".@@@@@@@@.",
        "@.@.@@@.@."
    ]
    
    # Write example to a temporary file
    with open("example.txt", "w") as f:
        for line in example:
            f.write(line + "\n")
    
    print("Testing with example:")
    example_result = solve_part2("example.txt")
    print(f"Total rolls removed: {example_result}")
    print(f"Expected: 43")
    print()
    
    # Solve the actual puzzle
    print("Solving Part 2:")
    result = solve_part2("input.txt")
    print(f"\nTotal rolls removed (Part 2): {result}")
