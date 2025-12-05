#!/usr/bin/env ruby

# Advent of Code 2025 - Day 2: Gift Shop - Invalid Product IDs
#
# Find all invalid product IDs (numbers that are a pattern repeated twice)
# within given ranges and sum them up.

class ProductIDValidator
  # Check if a number is invalid (pattern repeated at least twice)
  def self.invalid_id?(num)
    str = num.to_s
    len = str.length
    
    # Try all possible pattern lengths from 1 to len/2
    # A pattern of length p repeated at least twice means the total length
    # must be divisible by p and at least 2*p
    (1..(len / 2)).each do |pattern_length|
      # Check if the string length is divisible by pattern length
      next unless len % pattern_length == 0
      
      # Extract the pattern
      pattern = str[0...pattern_length]
      
      # Check if repeating this pattern fills the entire string
      repeated = pattern * (len / pattern_length)
      return true if repeated == str
    end
    
    false
  end
  
  # Find all invalid IDs in a range
  def self.find_invalid_ids_in_range(start_id, end_id)
    invalid_ids = []
    
    (start_id..end_id).each do |id|
      invalid_ids << id if invalid_id?(id)
    end
    
    invalid_ids
  end
  
  # Parse ranges from input string
  def self.parse_ranges(input)
    ranges = []
    input.strip.split(',').each do |range_str|
      start_id, end_id = range_str.split('-').map(&:to_i)
      ranges << [start_id, end_id]
    end
    ranges
  end
  
  # Process all ranges and return sum of invalid IDs
  def self.process_ranges(input)
    ranges = parse_ranges(input)
    total_sum = 0
    invalid_count = 0
    
    ranges.each do |start_id, end_id|
      invalid_ids = find_invalid_ids_in_range(start_id, end_id)
      
      unless invalid_ids.empty?
        puts "Range #{start_id}-#{end_id}: Found #{invalid_ids.length} invalid ID(s): #{invalid_ids.join(', ')}"
      end
      
      total_sum += invalid_ids.sum
      invalid_count += invalid_ids.length
    end
    
    puts "\n" + "=" * 60
    puts "Total invalid IDs found: #{invalid_count}"
    puts "Sum of all invalid IDs: #{total_sum}"
    puts "=" * 60
    
    total_sum
  end
end

# Main execution
def solve(filename)
  input = File.read(filename)
  
  puts "=" * 60
  puts "Advent of Code 2025 - Day 2: Gift Shop"
  puts "=" * 60
  puts "Input file: #{filename}\n\n"
  
  ProductIDValidator.process_ranges(input)
end

# Run with example or actual input
if __FILE__ == $0
  if ARGV.length > 0
    solve(ARGV[0])
  elsif File.exist?('input.txt')
    puts "🎄 Solving with actual puzzle input...\n\n"
    solve('input.txt')
  elsif File.exist?('example.txt')
    puts "🎄 Solving with example input...\n\n"
    solve('example.txt')
  else
    puts "Usage: ruby solution.rb [input_file]"
    puts "Or create input.txt or example.txt in the current directory"
    exit 1
  end
end
