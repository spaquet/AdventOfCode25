#!/usr/bin/env ruby

# Advent of Code 2025 - Day 1: Safe Dial Password
# 
# Simulates a safe dial that rotates left (L) or right (R) and counts
# how many times the dial points at position 0 after rotations.

class SafeDial
  DIAL_SIZE = 100  # Positions 0-99
  STARTING_POSITION = 50

  def initialize
    @position = STARTING_POSITION
    @zero_count = 0
  end

  def rotate(direction, distance)
    old_position = @position
    
    case direction
    when 'L'
      @position = (@position - distance) % DIAL_SIZE
    when 'R'
      @position = (@position + distance) % DIAL_SIZE
    else
      raise "Invalid direction: #{direction}"
    end

    # Count how many times we pass through 0 during the rotation
    # This includes the final position if it's 0
    zero_crossings = count_zero_crossings(old_position, @position, direction, distance)
    @zero_count += zero_crossings
    
    @position
  end

  # Count how many times the dial lands on 0 during a rotation
  # Each "click" is one position change, and we count how many clicks land exactly on 0
  def count_zero_crossings(start_pos, end_pos, direction, distance)
    # If we don't move, no clicks land on 0
    return 0 if distance == 0
    
    # Calculate how many complete wraps around the dial we make
    # Each complete wrap (100 clicks) lands on 0 exactly once
    complete_wraps = distance / DIAL_SIZE
    
    # Check if we land on 0 in the partial rotation (the remaining clicks)
    remaining_distance = distance % DIAL_SIZE
    return complete_wraps if remaining_distance == 0
    
    lands_on_zero_in_partial = false
    
    if direction == 'L'
      # Moving left (decreasing numbers) for remaining_distance clicks
      # We land on 0 if: start_pos - remaining_distance < 0 (wraps around)
      # Which means: start_pos < remaining_distance
      # BUT we need to check the actual positions we visit
      # From start_pos, going left remaining_distance clicks
      # We visit: start_pos-1, start_pos-2, ..., start_pos-remaining_distance (mod 100)
      # We land on 0 if 0 is in this range
      # This happens when start_pos < remaining_distance (we wrap from positive to 0 to 99...)
      # But we need to be careful: if start_pos == 0, going left doesn't land on 0 again
      # until we wrap all the way around
      if start_pos == 0
        # Starting at 0, going left: 0 → 99 → 98 → ...
        # We don't land on 0 again in the partial rotation
        lands_on_zero_in_partial = false
      else
        # We land on 0 if we go far enough left to reach it
        # From position P, going left D clicks, we land on 0 if P <= D
        # (because P-1, P-2, ..., 1, 0)
        lands_on_zero_in_partial = start_pos <= remaining_distance
      end
    else # direction == 'R'
      # Moving right (increasing numbers) for remaining_distance clicks
      # From start_pos, going right remaining_distance clicks
      # We visit: start_pos+1, start_pos+2, ..., start_pos+remaining_distance (mod 100)
      # We land on 0 if this wraps past 99
      # This happens when start_pos + remaining_distance >= DIAL_SIZE
      lands_on_zero_in_partial = (start_pos + remaining_distance) >= DIAL_SIZE
    end
    
    total_count = complete_wraps
    total_count += 1 if lands_on_zero_in_partial
    
    total_count
  end

  def process_instructions(instructions)
    instructions.each do |instruction|
      # Parse instruction (e.g., "L68" or "R48")
      direction = instruction[0]
      distance = instruction[1..-1].to_i
      
      rotate(direction, distance)
    end

    @zero_count
  end

  def zero_count
    @zero_count
  end

  def current_position
    @position
  end
end

# Main execution
def solve(filename)
  instructions = File.readlines(filename, chomp: true)
  
  dial = SafeDial.new
  password = dial.process_instructions(instructions)
  
  puts "=" * 50
  puts "Advent of Code 2025 - Day 1"
  puts "=" * 50
  puts "Input file: #{filename}"
  puts "Total rotations: #{instructions.length}"
  puts "Final position: #{dial.current_position}"
  puts "-" * 50
  puts "PASSWORD (times dial pointed at 0): #{password}"
  puts "=" * 50
  
  password
end

# Run with example or actual input
if __FILE__ == $0
  if ARGV.length > 0
    solve(ARGV[0])
  elsif File.exist?('input.txt')
    puts "\n🎄 Solving with actual puzzle input...\n\n"
    solve('input.txt')
  elsif File.exist?('example.txt')
    puts "\n🎄 Solving with example input...\n\n"
    solve('example.txt')
  else
    puts "Usage: ruby solution.rb [input_file]"
    puts "Or create input.txt or example.txt in the current directory"
    exit 1
  end
end
