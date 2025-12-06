#!/usr/bin/env ruby

# Day 6: Trash Compactor - Part 1
# Parse vertical math worksheet and calculate grand total

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
    # Transpose back to get rows for this problem
    problem_rows = []
    problem_columns.first.length.times do |row_idx|
      row = problem_columns.map { |col| col[row_idx] }.join('')
      problem_rows << row
    end
    
    # Extract numbers and operator
    numbers = []
    operator = nil
    
    problem_rows.each do |row|
      row_stripped = row.strip
      next if row_stripped.empty?
      
      # Check if this row contains the operator
      if row_stripped == '+' || row_stripped == '*'
        operator = row_stripped
      else
        # This is a number
        numbers << row_stripped.to_i
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
  puts "=== Day 6: Trash Compactor - Part 1 ==="
  puts
  
  # Test with example
  puts "Testing with example.txt:"
  example_result = solve('example.txt')
  puts
  puts "Expected: 4277556"
  puts "Got:      #{example_result}"
  puts "✓ Example matches!" if example_result == 4277556
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
