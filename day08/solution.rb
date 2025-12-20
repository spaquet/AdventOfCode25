class UnionFind
  def initialize(n)
    @parent = (0...n).to_a
    @size = Array.new(n, 1)
  end

  def find(i)
    if @parent[i] == i
      i
    else
      @parent[i] = find(@parent[i])
    end
  end

  def union(i, j)
    root_i = find(i)
    root_j = find(j)
    if root_i != root_j
      if @size[root_i] < @size[root_j]
        @parent[root_i] = root_j
        @size[root_j] += @size[root_i]
      else
        @parent[root_j] = root_i
        @size[root_i] += @size[root_j]
      end
      true
    else
      false
    end
  end

  def sizes
    @parent.each_with_index.map { |_, i| find(i) }.group_by { |i| i }.values.map(&:size)
  end
end

def solve(filename, num_connections)
  lines = File.readlines(filename).map(&:strip).reject(&:empty?)
  points = lines.map { |line| line.split(',').map(&:to_i) }

  pairs = []
  (0...points.size).each do |i|
    ((i + 1)...points.size).each do |j|
      p1 = points[i]
      p2 = points[j]
      dist_sq = (p1[0] - p2[0])**2 + (p1[1] - p2[1])**2 + (p1[2] - p2[2])**2
      pairs << { i: i, j: j, d2: dist_sq }
    end
  end

  # Sort pairs by distance squared. Tie-breaker by indices to be deterministic.
  pairs.sort_by! { |p| [p[:d2], p[:i], p[:j]] }

  uf = UnionFind.new(points.size)
  
  actual_num = [num_connections, pairs.size].min
  (0...actual_num).each do |idx|
    pair = pairs[idx]
    uf.union(pair[:i], pair[:j])
  end

  all_sizes = uf.sizes.sort.reverse
  puts "Sizes: #{all_sizes.inspect}"
  
  top_3 = all_sizes.first(3)
  puts "Top 3 sizes: #{top_3.inspect}"
  result = top_3.reduce(:*)
  puts "Result: #{result}"
  result
end

if __FILE__ == $0
  puts "--- Example ---"
  solve("example.txt", 10)
  
  if File.exist?("input.txt")
    puts "\n--- Part 1 ---"
    solve("input.txt", 1000)
  end
end
