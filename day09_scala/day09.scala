import scala.io.Source._

@main def run(): Unit =
    val lines = fromFile("input.txt").getLines
    val input = parse(lines.toList)
    println("part1: " + part1(input).toString)
    println("part2: " + part2(input).toString)

def part2(input: List[List[Int]]): Int = {
    input.map(solve_line2).sum
}

def solve_line2(line: List[Int]): Int = {
    if line.forall(_ == 0) then return 0
    line.head - solve_line2(diffs(line))
}

def part1(input: List[List[Int]]): Int = {
    input.map(solve_line1).sum
}

def solve_line1(line: List[Int]): Int = {
    if line.forall(_ == 0) then return 0
    line.last+solve_line1(diffs(line))
}

def diffs(line: List[Int]): List[Int] =
    line.sliding(2).collect {
        case Seq(a, b) => b - a
    }.toList

def parse(lines: List[String]): List[List[Int]] =
    lines.map(_.split(" ").map(_.toInt).toList)
