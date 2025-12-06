#!/usr/bin/env ruby

# Day 6: Trash Compactor - Part 2
# Parse vertical math worksheet with right-to-left column reading

def solve(filename)
  lines = File.readlines(filename, chomp: true)
  
  # Find the maximum line length to ensure we process all columns
  max_length = lines.map(&:length).max
  
  # Pad all lines to the same length with spaces
  lines = lines.map { |line| line.ljust(max_length) }
  
  # Transpose to work with columns instead of rows
  columns = []
  max_length.times do |col_idx|
    column = lines.map { |line| line[col_idx] || ' ' }
    columns << column
  end
  
  # Identify problems by finding groups of non-empty columns separated by empty columns
  problems = []
  current_problem = []
  
  columns.each do |column|
    # Check if this column is entirely spaces
    if column.all? { |char| char == ' ' }
      # End of a problem (if we have accumulated columns)
      if !current_problem.empty?
        problems << current_problem
        current_problem = []
      end
    else
      # Part of a problem
      current_problem << column
    end
  end
  
  # Don't forget the last problem if the input doesn't end with spaces
  problems << current_problem unless current_problem.empty?
  
  # Process each problem
  results = []
  
  problems.each_with_index do |problem_columns, idx|
    # For Part 2: Each COLUMN represents one number (read top-to-bottom)
    # We process columns RIGHT-TO-LEFT to get numbers in the correct order
    
    # Get the number of rows
    num_rows = problem_columns.first.length
    operator_row_idx = num_rows - 1
    
    # Extract the operator from the last row
    operator = nil
    problem_columns.each do |col|
      char = col[operator_row_idx].strip
      if char == '+' || char == '*'
        operator = char
        break
      end
    end
    
    # Extract numbers by reading columns right-to-left
    # Each column (read top-to-bottom) forms one number
    numbers = []
    
    # Process columns from right to left
    problem_columns.reverse.each do |col|
      # Read this column top-to-bottom (excluding operator row)
      digits = []
      (0...operator_row_idx).each do |row_idx|
        char = col[row_idx]
        if char != ' '
          digits << char
        end
      end
      
      # If we found digits, form a number
      if !digits.empty?
        number = digits.join('').to_i
        numbers << number
      end
    end
    
    # Calculate the result
    if operator && !numbers.empty?
      result = numbers.first
      numbers[1..-1].each do |num|
        if operator == '+'
          result += num
        elsif operator == '*'
          result *= num
        end
      end
      
      results << result
      puts "Problem #{idx + 1}: #{numbers.join(" #{operator} ")} = #{result}"
    end
  end
  
  # Calculate grand total
  grand_total = results.sum
  puts "\nGrand Total: #{grand_total}"
  grand_total
end

# Main execution
if __FILE__ == $0
  puts "=== Day 6: Trash Compactor - Part 2 ==="
  puts
  
  # Test with example
  puts "Testing with example.txt:"
  example_result = solve('example.txt')
  puts
  puts "Expected: 3263827"
  puts "Got:      #{example_result}"
  puts "✓ Example matches!" if example_result == 3263827
  puts
  
  # Solve with actual input
  if File.exist?('input.txt') && File.read('input.txt').strip != '# Paste your puzzle input here from https://adventofcode.com/2025/day/6/input'
    puts "-" * 50
    puts "Solving with input.txt:"
    result = solve('input.txt')
    puts
    puts "Answer: #{result}"
  else
    puts "⚠️  Please add your puzzle input to input.txt"
  end
end
