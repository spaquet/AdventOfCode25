#!/usr/bin/env ruby
# Day 7 - Part 2: Quantum Tachyon Manifold
# Advent of Code 2025

require 'set'

def solve(input_file)
  lines = File.readlines(input_file, chomp: true)
  
  # Find the starting position (S)
  start_row = nil
  start_col = nil
  lines.each_with_index do |line, row|
    col = line.index('S')
    if col
      start_row = row
      start_col = col
      break
    end
  end
  
  # New approach: Count the number of distinct timelines
  # A timeline is uniquely determined by the sequence of LEFT/RIGHT choices made
  # 
  # At each splitter, the particle makes a choice (left or right)
  # The number of timelines = 2^(number of splitters encountered)
  # 
  # But wait - different paths might encounter different numbers of splitters
  # So we need to actually track each unique path
  #
  # Key insight: Instead of storing the full path, we can use a hash
  # to represent the path compactly
  
  # Use a counter: for each unique path signature, count how many times it occurs
  # But all paths are unique by definition...
  
  # Let me re-think: We need to count the number of leaf nodes in the decision tree
  # Each time we hit a splitter, we branch into 2 paths
  # The total number of paths is the number of leaves in this tree
  
  # Simpler approach: Just count paths without storing them
  # Use recursion with memoization based on (row, col)
  
  @memo = {}
  
  def count_paths(lines, row, col)
    # Memoization key
    key = [row, col]
    return @memo[key] if @memo.key?(key)
    
    # Move down one row
    next_row = row + 1
    
    # Base case: exited the manifold
    if next_row >= lines.length
      return 1  # This is one complete path
    end
    
    # Check what we encounter
    char = lines[next_row][col]
    
    count = 0
    
    if char == '.'
      # Continue straight
      count = count_paths(lines, next_row, col)
    elsif char == '^'
      # Quantum split - count paths from both branches
      
      # Left path
      if col > 0
        count += count_paths(lines, next_row, col - 1)
      end
      
      # Right path
      if col < lines[next_row].length - 1
        count += count_paths(lines, next_row, col + 1)
      end
    end
    
    @memo[key] = count
    count
  end
  
  total_timelines = count_paths(lines, start_row, start_col)
  
  puts "Total unique timelines: #{total_timelines}"
  total_timelines
end

# Run with example input
puts "=== Example ==="
example_result = solve('example.txt')
puts "Expected: 40"
puts

puts "=== Actual Input ==="
solve('input.txt')
