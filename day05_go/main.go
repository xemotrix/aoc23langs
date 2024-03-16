package main

import "fmt"

func main() {
	al := parse()
	p1 := part1(al)
	p2 := part2(al)
	fmt.Printf("Part 1: %d\nPart 2: %d\n", p1, p2)
}
