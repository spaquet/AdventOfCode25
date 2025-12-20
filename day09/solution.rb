def solve(filename)
  unless File.exist?(filename)
    puts "File #{filename} not found."
    return
  end

  lines = File.readlines(filename).map(&:strip).reject(&:empty?)
  points = lines.map { |line| line.split(',').map(&:to_i) }

  max_area = 0
  best_pair = []

  (0...points.size).each do |i|
    ((i + 1)...points.size).each do |j|
      p1 = points[i]
      p2 = points[j]
      
      width = (p1[0] - p2[0]).abs + 1
      height = (p1[1] - p2[1]).abs + 1
      area = width * height
      
      if area > max_area
        max_area = area
        best_pair = [p1, p2]
      end
    end
  end

  puts "Points: #{points.size}"
  puts "Max Area: #{max_area}"
  puts "Between: #{best_pair.inspect}" if best_pair.any?
  max_area
end

if __FILE__ == $0
  puts "--- Example ---"
  solve("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 1 ---"
    solve("input.txt")
  end
end
