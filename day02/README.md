# Day 2: Gift Shop - Invalid Product IDs

## Challenge Description

A young Elf accidentally added invalid product IDs to the gift shop database. We need to identify and sum all invalid IDs within given ranges.

### Invalid ID Pattern

An ID is **invalid** if it consists of some sequence of digits repeated exactly twice:
- `11` = "1" repeated twice ✓ Invalid
- `6464` = "64" repeated twice ✓ Invalid  
- `123123` = "123" repeated twice ✓ Invalid
- `101` = Not a repeated pattern ✗ Valid
- `0101` = Has leading zero, not a valid ID at all

### Input Format

Comma-separated ranges: `start-end,start-end,...`

Example: `11-22,95-115,998-1012`

## Example Walkthrough

```
11-22      → Invalid IDs: 11, 22
95-115     → Invalid IDs: 99
998-1012   → Invalid IDs: 1010
1188511880-1188511890 → Invalid IDs: 1188511885
222220-222224 → Invalid IDs: 222222
```

**Sum**: 1227775554

## Solution Approach

1. Parse ranges from input
2. For each range, check each ID:
   - Convert to string
   - Check if length is even
   - Split in half and compare
   - If both halves match → invalid ID
3. Sum all invalid IDs

## Running the Solution

```bash
ruby solution.rb
```
