# Day 12: Christmas Tree Farm

The problem asks us to determine, for several regions and sets of presents, whether the presents can fit into the regions without overlapping. This is a **2D packing problem** (specifically, tiling with polyomions).

## Input Format

1. **Shapes**: Definitions of polyominoes (presents).
   - Can be rotated (90, 180, 270 degrees) and flipped.
   - Represented by `#` and `.`.
2. **Queries**:
   - Region size: `WxH`
   - Quantities of each shape index needed.

## Constraints

- Grid based placement.
- No overlap of `#` cells.
- Must fit entirely within bounds.

## Approach

This is an exact cover / tiling problem which is generally NP-hard. However, grid sizes and number of pieces are likely small enough for **Backtracking / DLX (Dancing Links)**.

Since the shapes can be placed anywhere, rotated, and flipped, the search space is large.
We will use a backtracking solver with optimizations:

1. **Normalization**: Generate all 8 symmetries (rotations/flips) for each shape.
2. **Heuristic**: Place larger / more complex shapes first? Or fill board cell by cell?
   - Usually, filling the board cell-by-cell (top-left first) works well for tiling.
   - At the first empty cell, try to place any available piece that covers it.

## Algorithm

1. Parse shapes. Generate all unique variants for each.
2. For each query:
   - Create a grid of `WxH`.
   - Maintain a count of available pieces.
   - Run recursive backtracking:
     - Find the first empty cell $(r, c)$.
     - If no empty cells and no pieces left -> Success.
     - If no empty cells but pieces left -> False (area check should catch this early).
     - Try to place any available piece type at $(r, c)$ covering it.
       - Iterate through all variants of the piece.
       - Check bounds and collision.
       - Recurse.
       - Backtrack.

## Optimization

- **Pruning**: Total area of pieces must equal total area of grid? No, the problem doesn't say we must fill the grid perfectly, just that presents fit.
  - Actually, "The Elves need to know how many of the regions can fit the presents listed."
  - It effectively implies packing.
  - _Crucial_: Pre-check if Total Area of Presents > Region Area. If so, fail immediately.

## Example

Region 4x4, two "index 4" shapes.
Shape 4 Area: 7. Total Area: 14. Region Area: 16. Fits with 2 empty spaces.
So we are NOT exact-covering the grid, just packing.
This makes cell-by-cell filling slightly harder because we don't _have_ to fill the first empty cell.
HOWEVER, we can transform this into an exact cover problem by adding 1x1 "monominoes" (empty space fillers) equal to `(Region Area - Presents Area)`.

Wait, adding separate 1x1 blocks increases the search depth enormously.
Better approach for packing:

- Backtracking on **pieces**.
- Sort pieces by size (largest first).
- Try to place piece 1 at any valid position.
- Then piece 2 at any valid position...
- This typically works better for packing than cell-based if we don't have to fill the grid.

But if the packing density is high (like the example 12x5=60 area, pieces might take up ~50-60), cell-based filling is still good if we consider "empty 1x1" as a piece?
Actually, finding the _first empty cell_ and placing a piece there is a strategy for _tiling_. If we just want to pack, we might leave the first cell empty.

Let's stick to **Backtracking on Pieces** first.

- Order pieces: Largest to smallest.
- State: Grid (bitmask or array), list of pieces to place.
- Function `solve(index, grid)`:
  - If index == num_pieces, return True.
  - Current piece $P$.
  - Try all positions $(r, c)$ and all symmetries $S$ of $P$.
    - If valid, place and `solve(index + 1, new_grid)`.
    - If efficient enough, this works.

Optimization:

- If we can't place the current piece anywhere, fail.
- Flood fill check? If valid board space is partitioned into regions smaller than smallest remaining piece, prune.
