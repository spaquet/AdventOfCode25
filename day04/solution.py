#!/usr/bin/env python3
"""
Advent of Code 2025 - Day 4: Printing Department
Count how many paper rolls can be accessed by forklifts.
A roll can be accessed if it has fewer than 4 rolls in the 8 adjacent positions.
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

def solve(filename):
    """Read the grid and count accessible rolls."""
    # Read the grid
    with open(filename, 'r') as f:
        grid = [line.strip() for line in f if line.strip()]
    
    accessible_count = 0
    
    # Check each position in the grid
    for row in range(len(grid)):
        for col in range(len(grid[row])):
            # Only check positions that have a roll
            if grid[row][col] == '@':
                adjacent_rolls = count_adjacent_rolls(grid, row, col)
                # A roll can be accessed if there are fewer than 4 adjacent rolls
                if adjacent_rolls < 4:
                    accessible_count += 1
    
    return accessible_count

def visualize_accessible(filename):
    """Visualize which rolls are accessible (for debugging)."""
    with open(filename, 'r') as f:
        grid = [line.strip() for line in f if line.strip()]
    
    result = []
    for row in range(len(grid)):
        result_row = []
        for col in range(len(grid[row])):
            if grid[row][col] == '@':
                adjacent_rolls = count_adjacent_rolls(grid, row, col)
                if adjacent_rolls < 4:
                    result_row.append('x')  # Accessible
                else:
                    result_row.append('@')  # Not accessible
            else:
                result_row.append('.')
        result.append(''.join(result_row))
    
    return result

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
    example_result = solve("example.txt")
    print(f"Accessible rolls: {example_result}")
    print(f"Expected: 13")
    print()
    
    print("Visualization of accessible rolls (x = accessible, @ = not accessible):")
    visualization = visualize_accessible("example.txt")
    for line in visualization:
        print(line)
    print()
    
    # Solve the actual puzzle
    result = solve("input.txt")
    print(f"Total accessible rolls: {result}")
