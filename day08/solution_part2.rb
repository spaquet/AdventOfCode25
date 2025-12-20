class UnionFind
  attr_reader :num_components

  def initialize(n)
    @parent = (0...n).to_a
    @size = Array.new(n, 1)
    @num_components = n
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
      @num_components -= 1
      true
    else
      false
    end
  end
end

def solve_part2(filename)
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

  # Sort pairs by distance squared. 
  # Important: The problem says "closest together but aren't already directly connected".
  # Actually, it says "Continue connecting the closest unconnected pairs...".
  # Wait, the example says: "the two junction boxes which are closest together are 162,817,812 and 425,690,689."
  # Then "the next two junction boxes which are closest together but aren't already directly connected are..."
  # This sounds like Kruskal's algorithm (Minimum Spanning Tree).
  # We iterate through all pairs sorted by distance. 
  # If a pair is not already in the same circuit, we connect them.
  # We stop when there is only one circuit.

  pairs.sort_by! { |p| [p[:d2], p[:i], p[:j]] }

  uf = UnionFind.new(points.size)
  
  last_pair = nil

  pairs.each do |pair|
    if uf.union(pair[:i], pair[:j])
      last_pair = pair
      break if uf.num_components == 1
    end
  end

  if last_pair
    p1 = points[last_pair[:i]]
    p2 = points[last_pair[:j]]
    puts "Last connection: #{p1.inspect} and #{p2.inspect}"
    result = p1[0] * p2[0]
    puts "Result: #{result}"
    result
  else
    puts "Could not connect all points."
    nil
  end
end

if __FILE__ == $0
  puts "--- Example Part 2 ---"
  solve_part2("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 2 ---"
    solve_part2("input.txt")
  end
end
