#!/usr/bin/env ruby

# Test script to debug zero crossing logic

class SafeDial
  DIAL_SIZE = 100
  STARTING_POSITION = 50

  def initialize
    @position = STARTING_POSITION
    @zero_count = 0
  end

  def rotate_verbose(direction, distance)
    old_position = @position
    
    case direction
    when 'L'
      @position = (@position - distance) % DIAL_SIZE
    when 'R'
      @position = (@position + distance) % DIAL_SIZE
    end

    # Count by actually simulating each click
    actual_zeros = count_zeros_by_simulation(old_position, direction, distance)
    
    # Count using our algorithm
    calculated_zeros = count_zero_crossings(old_position, @position, direction, distance)
    
    puts "#{direction}#{distance}: #{old_position} → #{@position}"
    puts "  Actual zeros (simulation): #{actual_zeros}"
    puts "  Calculated zeros (algorithm): #{calculated_zeros}"
    puts "  ❌ MISMATCH!" if actual_zeros != calculated_zeros
    puts
    
    @zero_count += actual_zeros
    @position
  end

  def count_zeros_by_simulation(start_pos, direction, distance)
    pos = start_pos
    count = 0
    
    distance.times do
      if direction == 'L'
        pos = (pos - 1) % DIAL_SIZE
      else
        pos = (pos + 1) % DIAL_SIZE
      end
      count += 1 if pos == 0
    end
    
    count
  end

  def count_zero_crossings(start_pos, end_pos, direction, distance)
    return 0 if distance == 0
    
    complete_wraps = distance / DIAL_SIZE
    remaining_distance = distance % DIAL_SIZE
    return complete_wraps if remaining_distance == 0
    
    lands_on_zero_in_partial = false
    
    if direction == 'L'
      if start_pos == 0
        lands_on_zero_in_partial = false
      else
        lands_on_zero_in_partial = start_pos <= remaining_distance
      end
    else
      lands_on_zero_in_partial = (start_pos + remaining_distance) >= DIAL_SIZE
    end
    
    total_count = complete_wraps
    total_count += 1 if lands_on_zero_in_partial
    
    total_count
  end

  attr_reader :zero_count, :position
end

# Test with example
puts "Testing with example input:"
puts "=" * 50
dial = SafeDial.new
puts "Starting position: #{dial.position}\n\n"

dial.rotate_verbose('L', 68)
dial.rotate_verbose('L', 30)
dial.rotate_verbose('R', 48)
dial.rotate_verbose('L', 5)
dial.rotate_verbose('R', 60)
dial.rotate_verbose('L', 55)
dial.rotate_verbose('L', 1)
dial.rotate_verbose('L', 99)
dial.rotate_verbose('R', 14)
dial.rotate_verbose('L', 82)

puts "=" * 50
puts "Total zero count: #{dial.zero_count}"
puts "Expected: 6"
