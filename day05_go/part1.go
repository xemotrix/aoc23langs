package main

func part1(al Almanac) int {
	min := int(^uint64(0) >> 1)
	for _, s := range al.seeds {
		n := followMapping(s, &al)
		if n < min {
			min = n
		}
	}
	return min
}

func followMapping(seed int, al *Almanac) int {
outer:
	for _, m := range al.mappings {
		for _, mapp := range m {
			if seed >= mapp.SourceStart && seed < mapp.SourceStart+mapp.Length {
				seed = mapp.DestStart + (seed - mapp.SourceStart)
				continue outer
			}
		}
	}
	return seed
}
