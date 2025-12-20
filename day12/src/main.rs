use rayon::prelude::*;
use std::collections::HashSet;
use std::fs::File;
use std::io::{self, BufRead};
use std::time::{Duration, Instant};

#[derive(Clone, Debug)]
struct Piece {
    id: usize,
    area: usize,
    variants: Vec<Vec<(i32, i32)>>,
}

#[derive(Clone, Debug)]
struct Query {
    width: usize,
    height: usize,
    counts: Vec<usize>,
}

fn rotate(grid: &[Vec<char>]) -> Vec<Vec<char>> {
    if grid.is_empty() {
        return vec![];
    }
    let rows = grid.len();
    let cols = grid[0].len();
    let mut new_grid = vec![vec!['.'; rows]; cols];
    for r in 0..rows {
        for c in 0..cols {
            new_grid[c][rows - 1 - r] = grid[r][c];
        }
    }
    new_grid
}

fn flip_grid(grid: &[Vec<char>]) -> Vec<Vec<char>> {
    let mut new_grid = grid.to_vec();
    new_grid.reverse();
    new_grid
}

fn normalize(grid: &[Vec<char>]) -> Option<Vec<(i32, i32)>> {
    if grid.is_empty() {
        return None;
    }
    let rows = grid.len();
    let cols = grid[0].len();
    let mut min_r = rows;
    let mut max_r = 0;
    let mut min_c = cols;
    let mut max_c = 0;
    let mut has_cell = false;

    for r in 0..rows {
        for c in 0..cols {
            if grid[r][c] == '#' {
                has_cell = true;
                if r < min_r { min_r = r; }
                if r > max_r { max_r = r; }
                if c < min_c { min_c = c; }
                if c > max_c { max_c = c; }
            }
        }
    }

    if !has_cell {
        return None;
    }

    let mut coords = Vec::new();
    for r in min_r..=max_r {
        for c in min_c..=max_c {
            if grid[r][c] == '#' {
                coords.push(((r - min_r) as i32, (c - min_c) as i32));
            }
        }
    }
    coords.sort(); // Sort to make canonical for deduplication
    Some(coords)
}

impl Piece {
    fn new(id: usize, grid: Vec<Vec<char>>) -> Self {
        let mut area = 0;
        for row in &grid {
            for &c in row {
                if c == '#' {
                    area += 1;
                }
            }
        }

        let mut unique_variants = HashSet::new();
        let mut current = grid;

        for _ in 0..4 {
            if let Some(norm) = normalize(&current) {
                unique_variants.insert(norm);
            }
            let flipped = flip_grid(&current);
            if let Some(norm) = normalize(&flipped) {
                unique_variants.insert(norm);
            }
            current = rotate(&current);
        }

        let variants: Vec<Vec<(i32, i32)>> = unique_variants.into_iter().collect();
        Piece { id, area, variants }
    }
}

fn parse_input(filename: &str) -> (Vec<Piece>, Vec<Query>) {
    let file = File::open(filename);
    if file.is_err() {
        return (vec![], vec![]);
    }
    let reader = io::BufReader::new(file.unwrap());
    
    let mut pieces = Vec::new();
    let mut queries = Vec::new();
    
    let mut current_shape: Vec<Vec<char>> = Vec::new();
    let mut current_id: Option<usize> = None;

    for line_res in reader.lines() {
        let line = line_res.unwrap();
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }

        if trimmed.contains('x') && trimmed.contains(':') {
            // Flush current piece
            if let Some(id) = current_id {
                 pieces.push(Piece::new(id, current_shape.clone()));
                 current_shape.clear();
            }
            // Parse query
            let parts: Vec<&str> = trimmed.split(':').collect();
            let dims: Vec<usize> = parts[0].split('x').map(|s| s.parse().unwrap()).collect();
            let counts: Vec<usize> = parts[1].split_whitespace().map(|s| s.parse().unwrap()).collect();
            
            queries.push(Query {
                width: dims[0],
                height: dims[1],
                counts,
            });
        } else if trimmed.ends_with(':') && trimmed[..trimmed.len()-1].chars().all(char::is_numeric) {
             // New piece ID
             if let Some(id) = current_id {
                 pieces.push(Piece::new(id, current_shape.clone()));
                 current_shape.clear();
             }
             let id_str = &trimmed[..trimmed.len()-1];
             current_id = Some(id_str.parse().unwrap());
        } else {
            // Shape line
            current_shape.push(trimmed.chars().collect());
        }
    }
    
    if let Some(id) = current_id {
        pieces.push(Piece::new(id, current_shape));
    }

    // Sort pieces by ID (though not strictly necessary, good for consistency)
    pieces.sort_by_key(|p| p.id);
    
    (pieces, queries)
}

fn solve_query(pieces: &[Piece], query: &Query, timeout: Duration) -> bool {
    // Total area check
    let mut total_area = 0;
    let mut pieces_to_place = Vec::new();
    
    for (id, &count) in query.counts.iter().enumerate() {
        if id >= pieces.len() { continue; } // Should not happen with valid input
        for _ in 0..count {
            pieces_to_place.push(&pieces[id]);
            total_area += pieces[id].area;
        }
    }

    if total_area > query.width * query.height {
        return false;
    }

    // Optimization: Sort pieces largest to smallest
    pieces_to_place.sort_by_key(|p| std::cmp::Reverse(p.area));

    let mut grid = vec![false; query.width * query.height];
    let start_time = Instant::now();
    
    backtrack(&mut grid, &pieces_to_place, 0, query.width, query.height, start_time, timeout)
}

fn backtrack(
    grid: &mut [bool],
    pieces: &[&Piece],
    idx: usize,
    width: usize,
    height: usize,
    start_time: Instant,
    timeout: Duration,
) -> bool {
    if idx == pieces.len() {
        return true;
    }
    
    // Check timeout periodically
    if idx % 5 == 0 && start_time.elapsed() > timeout {
        return false;
    }

    // Optimization: Find first empty cell?
    // For packing, we technically don't HAVE to fill the first empty cell, 
    // BUT if we leave an isolated empty cell smaller than any remaining piece, we fail.
    // The Ruby code just iterates all positions. That's safer for general packing but slower.
    // Let's stick to the Ruby logic: Iterate all positions for the current piece.
    // However, the Ruby code was: iterate r in 0..H, c in 0..W.
    
    let piece = pieces[idx];
    
    for variant in &piece.variants {
        let max_r = variant.iter().map(|(r, _)| *r).max().unwrap_or(0);
        let max_c = variant.iter().map(|(_, c)| *c).max().unwrap_or(0);
        
        if max_r >= height as i32 || max_c >= width as i32 {
            continue;
        }
        
        let limit_r = (height as i32 - max_r) as usize;
        let limit_c = (width as i32 - max_c) as usize;

        // Try every valid top-left position for this variant
        for r in 0..limit_r {
            for c in 0..limit_c {

                if can_place(grid, variant, r, c, width) {
                    place(grid, variant, r, c, width, true);
                    if backtrack(grid, pieces, idx + 1, width, height, start_time, timeout) {
                        return true;
                    }
                    place(grid, variant, r, c, width, false);
                }
            }
        }
    }

    false
}

#[inline(always)]
fn can_place(grid: &[bool], variant: &[(i32, i32)], r: usize, c: usize, width: usize) -> bool {
    for &(dr, dc) in variant {
        let nr = r + dr as usize;
        let nc = c + dc as usize;
        if grid[nr * width + nc] {
            return false;
        }
    }
    true
}

#[inline(always)]
fn place(grid: &mut [bool], variant: &[(i32, i32)], r: usize, c: usize, width: usize, val: bool) {
    for &(dr, dc) in variant {
        let nr = r + dr as usize;
        let nc = c + dc as usize;
        grid[nr * width + nc] = val;
    }
}

fn main() {
    println!("--- Example ---");
    let (pieces, queries) = parse_input("example.txt");
    if pieces.is_empty() {
        println!("No pieces found in example.txt");
    } else {
        let mut success = 0;
        for (i, q) in queries.iter().enumerate() {
            if solve_query(&pieces, q, Duration::from_secs(5)) {
                success += 1;
                println!("Query {}: FITS", i);
            } else {
                println!("Query {}: NO FIT", i);
            }
        }
        println!("Result: {}/{}", success, queries.len());
    }

    println!("\n--- Part 1 ---");
    let (pieces, queries) = parse_input("input.txt");
    if pieces.is_empty() {
        println!("No pieces found in input.txt or file missing.");
    } else {
        let solved_count = std::sync::atomic::AtomicUsize::new(0);
        
        queries.par_iter().enumerate().for_each(|(_i, q)| {
            // Using a slightly confusing timeout of 100ms per query as per Ruby?
            // Actually, Ruby had 100ms. Rust is faster, let's give it 200ms to be generous but fast.
            // Or since we are parallelizing, we can afford more wall time per thread if needed, 
            // but we want the total run to be fast.
            // Let's try 200ms.
            if solve_query(&pieces, q, Duration::from_millis(200)) {
                solved_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
            }
            
            // Just printing progress occasionally might be tricky in parallel.
            // We'll skip detailed progress and just print checking.
        });
        
        println!("Total solvable: {}", solved_count.load(std::sync::atomic::Ordering::Relaxed));
    }
}
