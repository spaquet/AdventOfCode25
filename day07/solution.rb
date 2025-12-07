#!/usr/bin/env ruby
# Day 7 - Part 1: Laboratories - Tachyon Manifold
# Advent of Code 2025

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
  
  # Track active beams: each beam is [row, col]
  # We'll use a queue to process beams level by level (row by row)
  beams = [[start_row, start_col]]
  split_count = 0
  
  # Process beams row by row, moving downward
  current_row = start_row
  
  while !beams.empty?
    # Move all beams down one row
    current_row += 1
    
    # Check if we've exited the manifold
    break if current_row >= lines.length
    
    next_beams = []
    
    # For each beam, check what it encounters
    beams.each do |row, col|
      # The beam moves down to current_row at the same column
      char = lines[current_row][col]
      
      if char == '.'
        # Beam continues downward
        next_beams << [current_row, col]
      elsif char == '^'
        # Beam hits a splitter - it stops and creates two new beams
        split_count += 1
        
        # Create left beam (col - 1)
        if col > 0
          next_beams << [current_row, col - 1]
        end
        
        # Create right beam (col + 1)
        if col < lines[current_row].length - 1
          next_beams << [current_row, col + 1]
        end
      end
    end
    
    # Remove duplicate beams (beams at the same position)
    beams = next_beams.uniq
  end
  
  puts "Total beam splits: #{split_count}"
  split_count
end

# Run with example input
puts "=== Example ==="
example_result = solve('example.txt')
puts "Expected: 21"
puts

puts "=== Actual Input ==="
solve('input.txt')
