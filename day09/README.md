# Day 9: Movie Theater

You slide down the firepole in the corner of the playground and land in the North Pole base movie theater!

The movie theater has a big tile floor with an interesting pattern. Elves here are redecorating the theater by switching out some of the square tiles in the big grid they form. Some of the tiles are red; the Elves would like to find the largest rectangle that uses red tiles for two of its opposite corners. They even have a list of where the red tiles are located in the grid (your puzzle input).

For example:

```
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
```

Showing red tiles as `#` and other tiles as `.`, the above arrangement of red tiles would look like this:

```
..............
.......#...#..
..............
..#....#......
..............
..#......#....
..............
.........#.#..
..............
```

You can choose any two red tiles as the opposite corners of your rectangle; your goal is to find the largest rectangle possible.

Ultimately, the largest area is `(|x1 - x2| + 1) * (|y1 - y2| + 1)`.

In the example:

- Between 2,5 and 9,7: Area 24
- Between 7,1 and 11,7: Area 35
- Between 7,3 and 2,3: Area 6
- Between 2,5 and 11,1: Area 50 (Largest)

Using two red tiles as opposite corners, what is the largest area of any rectangle you can make?
