require 'set'

class Piece
  attr_reader :variants, :area, :id

  def initialize(id, grid)
    @id = id
    @area = grid.flatten.count('#')
    @variants = generate_variants(grid)
  end

  def generate_variants(grid)
    variants = Set.new
    current = grid
    
    4.times do
      variants << normalize(current)
      variants << normalize(flip(current))
      current = rotate(current)
    end
    
    variants.map { |v| to_coords(v) }.to_a
  end

  def rotate(grid)
    return [] if grid.empty? || grid[0].nil?
    rows = grid.size
    cols = grid[0].size
    Array.new(cols) { |c| Array.new(rows) { |r| grid[rows - 1 - r][c] } }
  end

  def flip(grid)
    grid.reverse
  end

  def normalize(grid)
    return [] if grid.empty? || grid[0].nil?
    
    # Trim to bounding box
    rows = grid.size
    cols = grid[0].size
    min_r = max_r = min_c = max_c = nil
    
    grid.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        if cell == '#'
          min_r = r if min_r.nil? || r < min_r
          max_r = r if max_r.nil? || r > max_r
          min_c = c if min_c.nil? || c < min_c
          max_c = c if max_c.nil? || c > max_c
        end
      end
    end
    
    return [] if min_r.nil?
    
    (min_r..max_r).map { |r| grid[r][min_c..max_c] }
  end

  def to_coords(grid)
    coords = []
    grid.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        coords << [r, c] if cell == '#'
      end
    end
    coords
  end
end

def solve_query(pieces, query, timeout_ms = 1000)
  pieces_to_place = []
  total_area = 0
  
  query[:counts].each_with_index do |count, id|
    count.times do 
      pieces_to_place << pieces[id]
      total_area += pieces[id].area
    end
  end
  
  width = query[:width]
  height = query[:height]
  return false if total_area > width * height
  
  pieces_to_place.sort_by! { |p| -p.area }
  
  grid = Array.new(height) { Array.new(width, false) }
  start_time = Time.now
  
  result = backtrack(grid, pieces_to_place, 0, width, height, start_time, timeout_ms / 1000.0)
  result
end

def backtrack(grid, pieces, idx, width, height, start_time, timeout)
  return false if Time.now - start_time > timeout
  return true if idx == pieces.size
  
  piece = pieces[idx]
  
  piece.variants.each do |variant|
    max_r = variant.map(&:first).max
    max_c = variant.map(&:last).max
    
    (0...(height - max_r)).each do |r|
      (0...(width - max_c)).each do |c|
        if can_place?(grid, variant, r, c)
          place(grid, variant, r, c, true)
          return true if backtrack(grid, pieces, idx + 1, width, height, start_time, timeout)
          place(grid, variant, r, c, false)
        end
      end
    end
  end
  
  false
end

def can_place?(grid, variant, r, c)
  variant.all? { |dr, dc| !grid[r + dr][c + dc] }
end

def place(grid, variant, r, c, value)
  variant.each { |dr, dc| grid[r + dr][c + dc] = value }
end

def parse_input(filename)
  pieces = []
  queries = []
  current_shape = []
  current_id = nil

  File.readlines(filename).each do |line|
    line = line.strip
    next if line.empty?

    if line.include?('x') && line.include?(':')
      pieces << Piece.new(current_id, current_shape) if current_id
      current_shape = []
      
      parts = line.split(':')
      dims = parts[0].split('x').map(&:to_i)
      counts = parts[1].split.map(&:to_i)
      queries << { width: dims[0], height: dims[1], counts: counts }
    elsif line =~ /^(\d+):$/
      pieces << Piece.new(current_id, current_shape) if current_id
      current_shape = []
      current_id = line.to_i
    else
      current_shape << line.chars
    end
  end
  
  pieces << Piece.new(current_id, current_shape) if current_id
  [pieces, queries]
end

if __FILE__ == $0
  puts "--- Example ---"
  pieces, queries = parse_input('example.txt')
  success = 0
  queries.each_with_index do |q, i|
    if solve_query(pieces, q, 5000)
      success += 1
      puts "Query #{i}: FITS"
    else
      puts "Query #{i}: NO FIT"
    end
  end
  puts "Result: #{success}/#{queries.size}"
  
  if File.exist?('input.txt')
    puts "\n--- Part 1 ---"
    pieces, queries = parse_input('input.txt')
    success = 0
    queries.each_with_index do |q, i|
      if solve_query(pieces, q, 100)  # 100ms timeout per query
        success += 1
      end
      puts "Progress: #{i + 1}/#{queries.size}, Solvable: #{success}" if (i + 1) % 100 == 0
    end
    puts "Total solvable: #{success}"
  end
end
