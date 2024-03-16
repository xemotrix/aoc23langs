package main

import (
	"os"
	"strconv"
	"strings"
)

type Almanac struct {
	seeds    []int
	mappings [7][]Mapping
}

func parse() Almanac {
	input, _ := os.ReadFile("input.txt")
	lines := strings.Split(string(input), "\n")

	seeds := []int{}
	for _, s := range strings.Split(lines[0], " ")[1:] {
		n, _ := strconv.Atoi(s)
		seeds = append(seeds, n)
	}

	maps := [7][]Mapping{}
	mapCounter := -1

	for i := 1; i < len(lines); i++ {
		if lines[i] == "" {
			mapCounter++
			i++
			continue
		}
		parts := strings.Split(lines[i], " ")
		nums := [3]int{}
		for i, part := range parts {
			nums[i], _ = strconv.Atoi(part)
		}
		maps[mapCounter] = append(maps[mapCounter], Mapping{nums[0], nums[1], nums[2]})
	}
	return Almanac{
		seeds:    seeds,
		mappings: maps,
	}
}
