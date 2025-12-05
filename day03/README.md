# Day 3: Lobby - Battery Joltage

## Challenge Description

Power the escalator using batteries! Each battery bank (line of digits) needs exactly 2 batteries turned on. The joltage produced equals the number formed by those two digits.

### Rules

- Each line = one battery bank
- Turn on exactly 2 batteries per bank
- Joltage = number formed by the two selected digits (in order)
- Cannot rearrange batteries
- Find maximum possible joltage per bank

### Example

```
987654321111111 → Max: 98 (first two batteries)
811111111111119 → Max: 89 (batteries 8 and 9)
234234234234278 → Max: 78 (last two batteries)
818181911112111 → Max: 92 (batteries at positions with 9 and 2)
```

**Total**: 98 + 89 + 78 + 92 = **357**

## Solution Approach

For each bank:
1. Try all pairs of positions (i, j) where i < j
2. Form the number: `digits[i] + digits[j]`
3. Track the maximum
4. Sum all maximums

## Running the Solution

```bash
ruby solution.rb
```
