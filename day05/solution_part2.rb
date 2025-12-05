#!/usr/bin/env ruby

# Day 5: Cafeteria - Part 2
# Count all ingredient IDs that the fresh ranges consider to be fresh

def parse_ranges(filename)
  lines = File.readlines(filename, chomp: true)
  
  # Find the blank line that separates ranges from ingredient IDs
  blank_index = lines.index("")
  
  # Parse fresh ID ranges
  ranges = lines[0...blank_index].map do |line|
    start_id, end_id = line.split('-').map(&:to_i)
    (start_id..end_id)
  end
  
  ranges
end

def count_all_fresh_ids(filename)
  ranges = parse_ranges(filename)
  
  # Collect all unique ingredient IDs from all ranges
  fresh_ids = Set.new
  
  ranges.each do |range|
    range.each do |id|
      fresh_ids.add(id)
    end
  end
  
  fresh_ids.size
end

# Alternative more efficient approach: merge overlapping ranges
def count_all_fresh_ids_optimized(filename)
  ranges = parse_ranges(filename)
  
  # Sort ranges by start position
  sorted_ranges = ranges.sort_by(&:first)
  
  # Merge overlapping ranges
  merged = []
  current_start = sorted_ranges[0].first
  current_end = sorted_ranges[0].last
  
  sorted_ranges[1..-1].each do |range|
    if range.first <= current_end + 1
      # Ranges overlap or are adjacent, merge them
      current_end = [current_end, range.last].max
    else
      # No overlap, save current range and start new one
      merged << (current_start..current_end)
      current_start = range.first
      current_end = range.last
    end
  end
  
  # Don't forget the last range
  merged << (current_start..current_end)
  
  # Count total IDs in merged ranges
  merged.sum { |range| range.size }
end

# Main execution
if __FILE__ == $0
  # Test with example
  example_result = count_all_fresh_ids('example.txt')
  puts "Example result: #{example_result} fresh ingredient IDs"
  puts "Expected: 14"
  puts
  
  # Solve with actual input
  result = count_all_fresh_ids_optimized('input.txt')
  puts "Part 2 Answer: #{result} fresh ingredient IDs"
end
