(ns main
  (:require [clojure.string :as str])
  (:require [part1 :as p1])
  (:require [part2 :as p2]))

(defn parse-hand [hand-str]
  (let [parts (str/split hand-str #" ")
        cards (seq (first parts))
        bid (Integer/parseInt (last parts))]
    {:cards cards
     :bid bid}))

(defn main []
  (let
   [lines (str/split (slurp "input.txt") #"\n")
    hands (map parse-hand lines)]
    (println "part1" (p1/run hands))
    (println "part2" (p2/run hands))))

(main)
