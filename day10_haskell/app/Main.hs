module Main where

import Data.List (find, nub)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Set (Set)
import qualified Data.Set as Set

data Cell = Cell {x_coord :: Int, y_coord :: Int}
  deriving (Show, Eq, Ord)

type Graph = Map Cell [Cell]

enumerate :: [a] -> [(Int, a)]
enumerate = zip [0 ..]

main :: IO ()
main = do
  str <- readFile "input.txt"
  (start, graph) <- parse str
  let (res1, visited) = part1 start graph
  let res2 = part2 str visited
  putStrLn ("result part1: " ++ show res1)
  putStrLn ("result part2: " ++ show res2)

part1 :: Cell -> Graph -> (Int, Set Cell)
part1 = traverseLoop

part2 :: String -> Set Cell -> Int
part2 input visited = sum $ map (findEnclosed visited) $ enumerate (lines input)

findEnclosed :: Set Cell -> (Int, String) -> Int
findEnclosed visited (y, str) =
  countGaps $ simplify str
  where
    simplify = reduceElbows [] . filter (/= '-') . maskLoop y visited

reduceElbows :: String -> String -> String
reduceElbows acc [] = reverse acc
reduceElbows acc ('|' : cs) = reduceElbows ('|' : acc) cs
reduceElbows acc ('F' : 'J' : cs) = reduceElbows ('|' : acc) cs
reduceElbows acc ('L' : '7' : cs) = reduceElbows ('|' : acc) cs
reduceElbows acc ('F' : '7' : cs) = reduceElbows acc cs
reduceElbows acc ('L' : 'J' : cs) = reduceElbows acc cs
reduceElbows acc ('.' : cs) = reduceElbows ('.' : acc) cs
reduceElbows acc (_ : cs) = reduceElbows acc cs

countGaps :: String -> Int
countGaps = countGaps' 0 0

countGaps' :: Int -> Int -> String -> Int
countGaps' acc crosses input =
  case input of
    [] -> acc
    ('|' : cs) -> countGaps' acc (crosses + 1) cs
    (_ : cs) -> countGaps' newAcc crosses cs
  where
    newAcc = if odd crosses then acc + 1 else acc

maskLoop :: Int -> Set Cell -> String -> String
maskLoop y visited line = do
  (x, c) <- enumerate line
  return $ if Set.member (Cell x y) visited then c else '.'

traverseLoop :: Cell -> Graph -> (Int, Set Cell)
traverseLoop start graph =
  traverseLoop' graph start start start (Set.fromList [start]) 0

traverseLoop' :: Graph -> Cell -> Cell -> Cell -> Set Cell -> Int -> (Int, Set Cell)
traverseLoop' graph start prev curr visited acc =
  case next of
    _ | next == start -> ((1 + acc) `div` 2, visited)
    _ -> traverseLoop' graph start curr next newVisited (acc + 1)
  where
    next = head $ filter (/= prev) (neigs curr graph)
    newVisited = Set.insert next visited

neigs :: Cell -> Graph -> [Cell]
neigs cell graph =
  nub $ filter isValid ns
  where
    ns = Map.findWithDefault [] cell graph
    isValid c = Map.member c graph

parse :: String -> IO (Cell, Graph)
parse input = do
  case findStart indexed of
    Nothing -> error "unable to parse input"
    Just cell -> return (cell, graph)
  where
    indexed = indexChars input
    mergeGraphs = foldl (Map.unionWith (++)) Map.empty
    graph = mergeGraphs $ map (uncurry parseNode) indexed
    findStart = fmap fst . find ((== 'S') . snd)

indexChars :: String -> [(Cell, Char)]
indexChars input = do
  (y, s) <- enumerate $ lines input
  (x, c) <- enumerate s
  return (Cell x y, c)

parseNode :: Cell -> Char -> Graph
parseNode self@(Cell x y) c =
  case c of
    'S' -> edgeTo [n, e, s, w]
    '|' -> edgeTo [n, s]
    '-' -> edgeTo [e, w]
    'L' -> edgeTo [n, e]
    'J' -> edgeTo [n, w]
    '7' -> edgeTo [s, w]
    'F' -> edgeTo [s, e]
    _ -> Map.empty
  where
    edgeTo cells = Map.fromList [(self, cells)]
    n = Cell x (y - 1)
    s = Cell x (y + 1)
    e = Cell (x + 1) y
    w = Cell (x - 1) y
