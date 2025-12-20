# Day 10: Factory

The manual describes one machine per line. Each line contains a single indicator light diagram in [square brackets], one or more button wiring schematics in (parentheses), and joltage requirements in {curly braces}.

To start a machine, its indicator lights must match those shown in the diagram, where . means off and # means on. The machine has the number of indicator lights shown, but its indicator lights are all initially off.

You can toggle the state of indicator lights by pushing any of the listed buttons. Each button lists which indicator lights it toggles (0-indexed). Pushing a button toggles each listed indicator light.

We need to determine the fewest total presses required to correctly configure all indicator lights for all machines in the list.

## Strategy

- Represent light states and buttons as bit vectors (XOR sum).
- Solve the system of linear equations over GF(2).
- Find the solution with the minimum Hamming weight (fewest buttons pressed).
- Since button presses are Boolean (pressing twice is like pressing zero), we search for the best combination.

Example total: 7.
