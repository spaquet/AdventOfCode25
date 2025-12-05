# Day 1: Safe Dial Password

## Challenge Description

The Elves need help opening a safe to get the password for the North Pole base entrance. The safe has a dial with numbers 0-99 that can be rotated left (L) or right (R).

### Key Rules

- **Dial Range**: 0 to 99 (circular)
- **Starting Position**: 50
- **Rotation Format**: `L<distance>` or `R<distance>`
  - `L` = rotate left (toward lower numbers)
  - `R` = rotate right (toward higher numbers)
- **Circular Behavior**: 
  - Going left from 0 wraps to 99
  - Going right from 99 wraps to 0

### The Puzzle

The actual password is **the number of times the dial points at 0** after any rotation in the sequence.

## Example

```
L68  → 50 to 82
L30  → 82 to 52
R48  → 52 to 0   ✓ (count: 1)
L5   → 0 to 95
R60  → 95 to 55
L55  → 55 to 0   ✓ (count: 2)
L1   → 0 to 99
L99  → 99 to 0   ✓ (count: 3)
R14  → 0 to 14
L82  → 14 to 32
```

**Answer**: 3 (the dial pointed at 0 three times)

## Solution Approach

1. Start at position 50
2. For each rotation instruction:
   - Parse direction (L/R) and distance
   - Calculate new position using modulo arithmetic
   - Check if new position is 0
   - Increment counter if it is
3. Return the total count

## Running the Solution

```bash
ruby solution.rb
```

---

## Part Two: Click Method (0x434C49434B)

### The Twist

Part 2 changes the counting method! Instead of counting only when the dial **ends** on 0, you must count **every time the dial passes through 0** during any rotation.

### Key Differences

- **Part 1**: Count final positions only
- **Part 2**: Count all zero crossings, including:
  - When rotation ends on 0
  - When rotation passes through 0 during movement
  - Multiple crossings if rotation wraps around the dial

### Example

Using the same rotations as Part 1:
- L68 from 50 → 82: **crosses 0 once** during rotation
- R48 from 52 → 0: ends on 0 (1 crossing)
- R60 from 95 → 55: **crosses 0 once** during rotation
- L55 from 55 → 0: ends on 0 (1 crossing)
- L99 from 99 → 0: ends on 0 (1 crossing)
- L82 from 14 → 32: **crosses 0 once** during rotation

**Part 1 Answer**: 3 (only final positions)  
**Part 2 Answer**: 6 (all crossings)

### Important Note

A large rotation like R1000 from position 50 would cross 0 **ten times** (10 complete wraps) before returning to 50!
