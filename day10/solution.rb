def solve_machine(target_mask, buttons, num_lights)
  # Brute force if buttons is small enough
  if buttons.size <= 20
    min_presses = Float::INFINITY
    (0...(1 << buttons.size)).each do |i|
      current_mask = 0
      presses = 0
      (0...buttons.size).each do |j|
        if (i >> j) & 1 == 1
          current_mask ^= buttons[j]
          presses += 1
        end
      end
      if current_mask == target_mask
        min_presses = [min_presses, presses].min
      end
    end
    return min_presses == Float::INFINITY ? nil : min_presses
  end

  # Otherwise, use Gaussian elimination to find a basis
  matrix = []
  buttons.each_with_index do |b, i|
    row = (0...num_lights).map { |j| (b >> j) & 1 }
    row << 0 # For identification of button pressed if we needed it
    matrix << row
  end
  # This is actually better solved as Ax = target
  # A is num_lights x num_buttons
  
  # Let's try BFS for the minimum Hamming weight solution
  # This is equivalent to finding the shortest path in a graph where states are bitmasks
  queue = [[0, 0]] # [mask, presses]
  visited = { 0 => 0 }
  
  while !queue.empty?
    curr_mask, curr_presses = queue.shift
    
    return curr_presses if curr_mask == target_mask
    
    buttons.each do |b|
      next_mask = curr_mask ^ b
      unless visited.key?(next_mask)
        visited[next_mask] = curr_presses + 1
        queue << [next_mask, curr_presses + 1]
      end
    end
  end
  
  nil
end

def solve_part1(filename)
  lines = File.readlines(filename).map(&:strip).reject(&:empty?)
  total_presses = 0

  lines.each do |line|
    # Parse [.##.]
    diagram = line.match(/\[([.#]+)\]/)[1]
    num_lights = diagram.length
    target_mask = 0
    diagram.chars.each_with_index do |c, i|
      target_mask |= (1 << i) if c == '#'
    end

    # Parse (0,3,4)
    buttons = []
    line.scan(/\(([\d,]+)\)/).each do |match|
      indices = match[0].split(',').map(&:to_i)
      mask = 0
      indices.each { |idx| mask |= (1 << idx) }
      buttons << mask
    end

    presses = solve_machine(target_mask, buttons, num_lights)
    if presses
      total_presses += presses
    else
      puts "No solution for machine: #{line}"
    end
  end

  puts "Total minimum presses: #{total_presses}"
  total_presses
end

if __FILE__ == $0
  puts "--- Example ---"
  solve_part1("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 1 ---"
    solve_part1("input.txt")
  end
end
