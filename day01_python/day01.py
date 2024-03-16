def part1(data):
    res = 0
    for line in data:
        digits = [c for c in line if c >= '0' and c <= '9']
        res += int(digits[0]+digits[-1])
    return res

def part2(data):
    repl = {
        'one': 'o1e', 'two': 't2o', 'three': 't3e', 'four': 'f4r',
        'five': 'f5e', 'six': 's6x', 'seven': 's7n', 'eight': 'e8t',
        'nine': 'n9e', 'zero': 'z0o' 
    }
    res = 0
    for line in data:
        for k, v in repl.items():
            line = line.replace(k, v)
        digits = [c for c in line if c >= '0' and c <= '9']
        res += int(digits[0]+digits[-1])
    return res

def main():
    with open("input.txt", "r") as file:
        data = file.read().splitlines()
    print(part1(data), part2(data))

if __name__ == "__main__":
    main()
