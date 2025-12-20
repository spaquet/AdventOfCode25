def solve(filename)
  unless File.exist?(filename)
    puts "File #{filename} not found."
    return
  end
  
  adj = {}
  File.readlines(filename).each do |line|
    line.strip!
    next if line.empty?
    
    parts = line.split(':')
    source = parts[0].strip
    destinations = parts[1].strip.split
    
    adj[source] = destinations
  end
  
  memo = {}
  
  # Ensure 'out' is in memo as base case
  # Actually, the recursion handles it: if node == 'out', return 1.
  
  result = count_paths('you', 'out', adj, memo)
  
  puts "Input: #{filename}"
  puts "Paths from 'you' to 'out': #{result}"
  result
end

def count_paths(current, target, adj, memo)
  return 1 if current == target
  return memo[current] if memo.key?(current)
  
  count = 0
  if adj.key?(current)
    adj[current].each do |neighbor|
      count += count_paths(neighbor, target, adj, memo)
    end
  end
  
  memo[current] = count
  count
end

if __FILE__ == $0
  puts "--- Example ---"
  solve("example.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 1 ---"
    solve("input.txt")
  end
end
