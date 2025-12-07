# Day 7: Laboratories

## Part 1

You find yourself in a teleporter lab with a malfunctioning teleporter. The diagnostic tool shows error code 0H-N0, indicating an issue with one of the tachyon manifolds.

### The Problem

A tachyon beam enters the manifold at location `S` and always moves downward. The beam behaves as follows:
- Passes freely through empty space (`.`)
- When it encounters a splitter (`^`), the beam stops and two new beams are emitted from the immediate left and right of the splitter

### Example

```
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
```

In this example, the tachyon beam is split a total of **21 times**.

### Goal

Analyze your manifold diagram and determine **how many times the beam will be split**.

## Part 2

[Part 2 description will go here]

## Solution

- **Language**: Ruby
- **Files**: 
  - `solution.rb` - Part 1 solution
  - `solution_part2.rb` - Part 2 solution
  - `input.txt` - Personal puzzle input
  - `example.txt` - Example input

## Running

```bash
cd day07
ruby solution.rb        # Part 1
ruby solution_part2.rb  # Part 2
```
