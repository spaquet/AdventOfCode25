def is_inside(px, py, v_segments, h_segments)
  # On boundary check
  v_segments.each do |s|
    sx = s[0][0]
    sy_min, sy_max = [s[0][1], s[1][1]].minmax
    return true if px == sx && py >= sy_min && py <= sy_max
  end
  h_segments.each do |s|
    sy = s[0][1]
    sx_min, sx_max = [s[0][0], s[1][0]].minmax
    return true if py == sy && px >= sx_min && px <= sx_max
  end

  # Ray casting
  inside = false
  v_segments.each do |s|
    sx = s[0][0]
    sy_min, sy_max = [s[0][1], s[1][1]].minmax
    if sx > px && py >= sy_min && py < sy_max
      inside = !inside
    end
  end
  inside
end

def solve_part2(filename)
  unless File.exist?(filename)
    puts "File #{filename} not found."
    return
  end

  lines = File.readlines(filename).map(&:strip).reject(&:empty?)
  points = lines.map { |line| line.split(',').map(&:to_i) }

  segments = []
  points.each_with_index do |p, i|
    p1 = p
    p2 = points[(i + 1) % points.size]
    segments << [p1, p2]
  end

  v_segments = segments.select { |s| s[0][0] == s[1][0] }
  h_segments = segments.select { |s| s[0][1] == s[1][1] }

  max_area = 0

  (0...points.size).each do |i|
    ((i + 1)...points.size).each do |j|
      p1 = points[i]
      p2 = points[j]
      
      x1, x2 = [p1[0], p2[0]].minmax
      y1, y2 = [p1[1], p2[1]].minmax
      
      # Optimization: skip if possible area is already smaller than current max
      area = (x2 - x1 + 1) * (y2 - y1 + 1)
      next if area <= max_area

      possible = true
      
      # Check if any boundary segment crosses the interior of the rectangle
      v_segments.each do |s|
        sx = s[0][0]
        if sx > x1 && sx < x2
          sy_min, sy_max = [s[0][1], s[1][1]].minmax
          # Non-empty overlap of (y1, y2) and [sy_min, sy_max]
          if [y1, sy_min].max < [y2, sy_max].min
            possible = false
            break
          end
        end
      end
      next unless possible

      h_segments.each do |s|
        sy = s[0][1]
        if sy > y1 && sy < y2
          sx_min, sx_max = [s[0][0], s[1][0]].minmax
          # Non-empty overlap of (x1, x2) and [sx_min, sx_max]
          if [x1, sx_min].max < [x2, sx_max].min
            possible = false
            break
          end
        end
      end
      next unless possible

      # Check if the midpoint of the rectangle is inside the polygon
      # For integer grid, midpoint of (x1..x2) is (x1+x2)/2.0
      if is_inside((x1 + x2) / 2.0, (y1 + y2) / 2.0, v_segments, h_segments)
        max_area = area
      end
    end
  end

  puts "Points: #{points.size}"
  puts "Max Area: #{max_area}"
  max_area
end

if __FILE__ == $0
  puts "--- Example Part 2 ---"
  solve_part2("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 2 ---"
    solve_part2("input.txt")
  end
end
