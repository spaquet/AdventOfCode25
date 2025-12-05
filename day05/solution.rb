#!/usr/bin/env ruby

# Day 5: Cafeteria - Part 1
# Determine how many available ingredient IDs are fresh

def parse_input(filename)
  lines = File.readlines(filename, chomp: true)
  
  # Find the blank line that separates ranges from ingredient IDs
  blank_index = lines.index("")
  
  # Parse fresh ID ranges
  ranges = lines[0...blank_index].map do |line|
    start_id, end_id = line.split('-').map(&:to_i)
    (start_id..end_id)
  end
  
  # Parse available ingredient IDs
  ingredient_ids = lines[(blank_index + 1)..-1].map(&:to_i)
  
  [ranges, ingredient_ids]
end

def is_fresh?(ingredient_id, ranges)
  ranges.any? { |range| range.cover?(ingredient_id) }
end

def count_fresh_ingredients(filename)
  ranges, ingredient_ids = parse_input(filename)
  
  fresh_count = ingredient_ids.count do |id|
    is_fresh?(id, ranges)
  end
  
  fresh_count
end

# Main execution
if __FILE__ == $0
  # Test with example
  example_result = count_fresh_ingredients('example.txt')
  puts "Example result: #{example_result} fresh ingredients"
  puts "Expected: 3"
  puts
  
  # Solve with actual input
  result = count_fresh_ingredients('input.txt')
  puts "Part 1 Answer: #{result} fresh ingredients"
end
