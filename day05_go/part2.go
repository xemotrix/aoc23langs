package main

import (
	"fmt"
	"unsafe"
)

type Mapping struct {
	DestStart   int
	SourceStart int
	Length      int
}

func (m Mapping) ToRange() Range {
	return Range{
		From:   m.SourceStart,
		To:     m.SourceStart + m.Length - 1,
		Offset: m.DestStart - m.SourceStart,
	}
}

type Range struct {
	From   int
	To     int
	Offset int
}

func (r *Range) ApplyOffset() {
	r.From += r.Offset
	r.To += r.Offset
	r.Offset = 0
}

func (r Range) Merge(other Range) ([]Range, bool) {
	if other.From >= r.From && other.To <= r.To {
		//     r: -----[======]----
		// other: -------[==]------
		return []Range{
			{
				From:   r.From,
				To:     other.From - 1,
				Offset: r.Offset,
			},
			{
				From:   other.From,
				To:     other.To,
				Offset: r.Offset + other.Offset,
			},
			{
				From:   other.To + 1,
				To:     r.To,
				Offset: r.Offset,
			},
		}, true
	} else if other.From <= r.From && other.To >= r.To {
		//     r: -----[======]----
		// other: ---[==========]--
		return []Range{{
			From:   r.From,
			To:     r.To,
			Offset: r.Offset + other.Offset,
		}}, true
	} else if other.From > r.From && other.From < r.To {
		//     r: -----[======]----
		// other: --------[=====]--
		return []Range{
			{
				From:   r.From,
				To:     other.From - 1,
				Offset: r.Offset,
			},
			{
				From:   other.From,
				To:     r.To,
				Offset: r.Offset + other.Offset,
			},
		}, true
	} else if other.To > r.From && other.To < r.To {
		//     r: -----[======]----
		// other: --[=====]--------
		return []Range{
			{
				From:   r.From,
				To:     other.To,
				Offset: r.Offset + other.Offset,
			},
			{
				From:   other.To + 1,
				To:     r.To,
				Offset: r.Offset,
			},
		}, true
	}
	return nil, false
}

func runSeed(seed Range, steps [7][]Mapping) int {
	seedRanges := []Range{seed}
	for _, step := range steps {
		seedRanges = runStep(seedRanges, step)
		for i := range seedRanges {
			seedRanges[i].ApplyOffset()
		}
	}

	min := int(^uint(0) >> 1)
	for _, sr := range seedRanges {
		n := sr.From + sr.Offset
		if n < min {
			min = n
		}
	}
	return min
}

func runStep(seeds []Range, mappings []Mapping) []Range {
	newSeeds := []Range{}
	for _, sr := range seeds {
		newSeeds = append(newSeeds, matchSeedWithRanges(sr, mappings)...)
	}
	return newSeeds
}

func matchSeedWithRanges(seed Range, ranges []Mapping) []Range {
	for ir, m := range ranges {
		mr := m.ToRange()
		res, overlap := seed.Merge(mr)
		if overlap {
			newSeeds := []Range{}
			for _, newSeed := range res {
				newSeeds = append(newSeeds, matchSeedWithRanges(newSeed, ranges[ir+1:])...)
			}
			return newSeeds
		}
	}
	return []Range{seed}
}

func part2(al Almanac) int {
	min := int(^uint(0) >> 1)
	seeds := (*(*[][2]int)(unsafe.Pointer(&al.seeds)))[:len(al.seeds)/2]
	fmt.Println(seeds)
	fmt.Println(al)
	for _, s := range seeds {
		seed := Range{
			From: s[0],
			To:   s[0] + s[1] - 1,
		}
		n := runSeed(seed, al.mappings)
		fmt.Println(n)
		if n < min {
			min = n
		}
	}
	return min
}
