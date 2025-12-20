def solve_part2(filename)
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
  
  # Ensure all necessary nodes exist
  nodes = ['svr', 'out', 'dac', 'fft']
  missing = nodes.select { |n| !adj.key?(n) && !adj.values.flatten.include?(n) }
  # Note: 'out' usually doesn't have outgoing edges, so it might not be a key in adj.
  # But it should be in values.
  
  # Define helper to get count with memoization reset each time or shared?
  # Since the graph is static, memoization depends only on (start, end).
  # We can just run count_paths for specific pairs.
  
  # Helper to calculate paths between two nodes
  def get_paths(start_node, end_node, adj)
    memo = {}
    count_paths(start_node, end_node, adj, memo)
  end

  # Logic:
  # Path 1: svr -> ... -> dac -> ... -> fft -> ... -> out
  # Path 2: svr -> ... -> fft -> ... -> dac -> ... -> out
  
  # Calculate segments
  svr_to_dac = get_paths('svr', 'dac', adj)
  dac_to_fft = get_paths('dac', 'fft', adj)
  fft_to_out = get_paths('fft', 'out', adj)
  
  path1_count = svr_to_dac * dac_to_fft * fft_to_out
  
  svr_to_fft = get_paths('svr', 'fft', adj)
  fft_to_dac = get_paths('fft', 'dac', adj)
  dac_to_out = get_paths('dac', 'out', adj)
  
  path2_count = svr_to_fft * fft_to_dac * dac_to_out
  
  total = path1_count + path2_count
  
  puts "Input: #{filename}"
  puts "svr -> dac: #{svr_to_dac}"
  puts "dac -> fft: #{dac_to_fft}"
  puts "fft -> out: #{fft_to_out}"
  puts "Path1 (svr->dac->fft->out): #{path1_count}"
  puts "---"
  puts "svr -> fft: #{svr_to_fft}"
  puts "fft -> dac: #{fft_to_dac}"
  puts "dac -> out: #{dac_to_out}"
  puts "Path2 (svr->fft->dac->out): #{path2_count}"
  puts "---"
  puts "Total paths visiting both: #{total}"
  total
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
  # Create a specific example file for Part 2 since the logic involves dac and fft
  # parsing the example from the prompt
  example_content = <<~EOT
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
  EOT
  File.write("example_part2.txt", example_content)
  
  puts "--- Example Part 2 ---"
  solve_part2("example_part2.txt")
  
  if File.exist?("input.txt")
    puts "\n--- Part 2 ---"
    solve_part2("input.txt")
  end
end
