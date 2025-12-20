require 'set'

def solve_machine_joltage(targets, button_sets)
  num_counters = targets.size
  num_buttons = button_sets.size
  
  # Build the coefficient matrix
  # matrix[counter][button] = 1 if button affects counter, 0 otherwise
  matrix = Array.new(num_counters) { Array.new(num_buttons, 0) }
  button_sets.each_with_index do |buttons, b_idx|
    buttons.each { |counter| matrix[counter][b_idx] = 1 }
  end
  
  # Use Gaussian elimination to solve the system
  # Create augmented matrix [A | b]
  aug = matrix.map.with_index { |row, i| row.dup + [targets[i]] }
  
  # Forward elimination with partial pivoting
  pivot_cols = []
  current_row = 0
  
  num_buttons.times do |col|
    # Find pivot
    pivot_row = (current_row...num_counters).max_by { |r| aug[r][col].abs }
    
    next if aug[pivot_row][col] == 0
    
    # Swap rows
    aug[current_row], aug[pivot_row] = aug[pivot_row], aug[current_row]
    pivot_cols << col
    
    # Eliminate below
    ((current_row + 1)...num_counters).each do |row|
      if aug[row][col] != 0
        factor = Rational(aug[row][col], aug[current_row][col])
        (col..num_buttons).each do |c|
          aug[row][c] -= factor * aug[current_row][c]
        end
      end
    end
    
    current_row += 1
    break if current_row >= num_counters
  end
  
  # Back substitution
  # Check for inconsistency
  (current_row...num_counters).each do |row|
    return nil if aug[row][num_buttons] != 0
  end
  
  # Identify free variables
  free_vars = (0...num_buttons).to_a - pivot_cols
  
  if free_vars.empty?
    # Unique solution - back substitute
    solution = Array.new(num_buttons, 0)
    (pivot_cols.size - 1).downto(0) do |i|
      col = pivot_cols[i]
      val = aug[i][num_buttons]
      ((col + 1)...num_buttons).each do |j|
        val -= aug[i][j] * solution[j]
      end
      val = Rational(val, aug[i][col])
      return nil if val < 0 || val.denominator != 1
      solution[col] = val.to_i
    end
    return solution.sum
  end
  
  # Multiple solutions - need to minimize sum
  # For small number of free variables, enumerate possibilities
  if free_vars.size > 8
    # Too many free variables, use greedy approach
    return greedy_solve(targets, button_sets)
  end
  
  # Try all combinations of free variables
  min_sum = Float::INFINITY
  
  # Estimate max value for free variables
  max_free = targets.max * 2
  
  def enumerate_free(free_vars, idx, current_vals, aug, pivot_cols, num_buttons, targets, min_sum_ref, max_free)
    if idx == free_vars.size
      # Calculate dependent variables
      solution = Array.new(num_buttons, 0)
      free_vars.each_with_index { |fv, i| solution[fv] = current_vals[i] }
      
      # Back substitute for pivot variables
      (pivot_cols.size - 1).downto(0) do |i|
        col = pivot_cols[i]
        val = aug[i][num_buttons]
        ((col + 1)...num_buttons).each do |j|
          val -= aug[i][j] * solution[j]
        end
        val = Rational(val, aug[i][col])
        return if val < 0 || val.denominator != 1
        solution[col] = val.to_i
      end
      
      total = solution.sum
      min_sum_ref[0] = [min_sum_ref[0], total].min
      return
    end
    
    fv = free_vars[idx]
    (0..max_free).each do |val|
      current_vals[idx] = val
      enumerate_free(free_vars, idx + 1, current_vals, aug, pivot_cols, num_buttons, targets, min_sum_ref, max_free)
      break if min_sum_ref[0] < Float::INFINITY && val > min_sum_ref[0] # Pruning
    end
  end
  
  min_sum_ref = [min_sum]
  enumerate_free(free_vars, 0, Array.new(free_vars.size), aug, pivot_cols, num_buttons, targets, min_sum_ref, max_free)
  
  min_sum_ref[0] == Float::INFINITY ? nil : min_sum_ref[0]
end

def greedy_solve(targets, button_sets)
  # Greedy approach: repeatedly press the button that affects the most needed counters
  counters = targets.dup
  total_presses = 0
  
  while counters.any? { |c| c > 0 }
    # Find button that best reduces the maximum counter
    best_button = nil
    best_score = -1
    
    button_sets.each_with_index do |buttons, idx|
      # Score: how many of the affected counters still need increments
      score = buttons.count { |c| counters[c] > 0 }
      if score > best_score
        best_score = score
        best_button = idx
      end
    end
    
    return nil if best_button.nil? || best_score == 0
    
    # Press this button
    button_sets[best_button].each { |c| counters[c] -= 1 }
    total_presses += 1
    
    # Safety check
    return nil if total_presses > 10000
  end
  
  counters.all? { |c| c == 0 } ? total_presses : nil
end

def solve_part2(filename)
  lines = File.readlines(filename).map(&:strip).reject(&:empty?)
  total_presses = 0

  lines.each_with_index do |line, idx|
    button_sets = []
    line.scan(/\(([\d,]+)\)/).each do |match|
      button_sets << match[0].split(',').map(&:to_i)
    end
    requirements = line.match(/\{([\d,]+)\}/)[1].split(',').map(&:to_i)

    presses = solve_machine_joltage(requirements, button_sets)
    if presses
      total_presses += presses
      puts "Machine #{idx + 1}: #{presses}" if idx < 3 || !File.exist?("input.txt")
    else
      puts "No solution for machine #{idx + 1}"
      return nil
    end
  end

  puts "Total Joltage presses: #{total_presses}"
  total_presses
end

if __FILE__ == $0
  puts "--- Example Part 2 ---"
  solve_part2("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 2 ---"
    solve_part2("input.txt")
  end
end
