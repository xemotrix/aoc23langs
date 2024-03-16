use anyhow::Result;
use std::fs;

enum EnoughBalls {
    Yes,
    No,
}

fn check_color(r: i32, g: i32, b: i32) -> EnoughBalls {
    if r > 12 || g > 13 || b > 14 {
        return EnoughBalls::No;
    }
    EnoughBalls::Yes
}

fn calc_line(x: &str) -> Result<EnoughBalls> {
    let (mut r, mut g, mut b) = (0, 0, 0);
    for (i, c) in x.chars().enumerate() {
        match c {
            c if c.is_ascii_digit() => {
                let nstr = x[i..]
                    .chars()
                    .take_while(|c| !c.is_whitespace())
                    .collect::<String>();

                let len = nstr.len();
                let n = nstr.parse::<i32>()?;
                match (x.chars().nth(i + len + 1), (r, g, b)) {
                    (Some('r'), (0, _, _)) => r = n,
                    (Some('g'), (_, 0, _)) => g = n,
                    (Some('b'), (_, _, 0)) => b = n,
                    (Some('r'), _) | (Some('g'), _) | (Some('b'), _) => continue,
                    _ => anyhow::bail!("Invalid color"),
                }
            }
            ';' => match check_color(r, g, b) {
                EnoughBalls::No => return Ok(EnoughBalls::No),
                EnoughBalls::Yes => {
                    (r, g, b) = (0, 0, 0);
                }
            },
            _ => continue,
        }
    }
    Ok(check_color(r, g, b))
}

fn part1(contents: &str) -> Result<i32> {
    let mut total: i32 = 0;
    for (i, l) in contents.lines().enumerate() {
        let x = l
            .split(':')
            .nth(1)
            .ok_or_else(|| anyhow::anyhow!("No value"))?;
        match calc_line(x)? {
            EnoughBalls::Yes => total += (i + 1) as i32,
            EnoughBalls::No => continue,
        }
    }
    Ok(total)
}

fn calc_line2(x: &str) -> Result<(i32, i32, i32)> {
    let (mut max_r, mut max_g, mut max_b) = (0, 0, 0);
    let (mut set_r, mut set_g, mut set_b) = (false, false, false);
    for (i, c) in x.chars().enumerate() {
        match c {
            c if c.is_ascii_digit() => {
                let nstr = x[i..]
                    .chars()
                    .take_while(|c| !c.is_whitespace())
                    .collect::<String>();

                let len = nstr.len();
                let n = nstr.parse::<i32>()?;
                match (x.chars().nth(i + len + 1), (set_r, set_g, set_b)) {
                    (Some('r'), (false, _, _)) => {
                        if n > max_r {
                            max_r = n;
                        }
                    }
                    (Some('g'), (_, false, _)) => {
                        if n > max_g {
                            max_g = n;
                        }
                    }
                    (Some('b'), (_, _, false)) => {
                        if n > max_b {
                            max_b = n;
                        }
                    }
                    (Some('r'), _) | (Some('g'), _) | (Some('b'), _) => continue,
                    _ => anyhow::bail!("Invalid color"),
                }
            }
            ';' => (set_r, set_g, set_b) = (false, false, false),
            _ => continue,
        }
    }
    Ok((max_r, max_g, max_b))
}

fn part2(contents: &str) -> Result<i32> {
    let mut total: i32 = 0;
    for l in contents.lines() {
        let x = l
            .split(':')
            .nth(1)
            .ok_or_else(|| anyhow::anyhow!("No value"))?;
        let (r, g, b) = calc_line2(x)?;
        total += r * g * b;
    }
    Ok(total)
}

fn main() -> Result<()> {
    let file_path = "input.txt";
    let contents = fs::read_to_string(file_path)?;
    println!("Part 1: {}", part1(&contents)?);
    println!("Part 2: {}", part2(&contents)?);
    Ok(())
}
