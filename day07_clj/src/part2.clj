(ns part2)

(defn square [x] (* x x))

(defn joker? [ch] (= ch \J))

(defn count-js [hand]
  (count (filter joker? (:cards hand))))

(defn adjust-entry [entry, top, js]
  (cond
    (joker? top) 5
    (joker? (key entry)) 0
    (= (key entry) top) (+ (val entry) js)
    :else (val entry)))

(defn calc-scores [hand]
  (let [ranked-cards (->> (:cards hand)
                          (map #(hash-map % 1))
                          (reduce #(merge-with + %1 %2))
                          (apply list)
                          (sort-by (comp - val)))
        js (count-js hand)
        top (first ranked-cards)
        top-card (cond
                   (and (joker? (key top)) (= (val top) 5)) \J
                   (joker? (key top)) (key (first (rest ranked-cards)))
                   :else (key top))
        scores (map #(adjust-entry % top-card js) ranked-cards)]

    (assoc hand
           :score (reduce + (map square scores)))))

(defn compare-high-card [cards1 cards2 value-map]
  (if (empty? cards1)
    (throw (Exception. "two hands tied"))
    (let [c1 (first cards1)
          c2 (first cards2)]
      (if (not= c1 c2)
        (compare (value-map c1) (value-map c2))
        (compare-high-card (rest cards1) (rest cards2) value-map)))))

(defn compare-hands [h1 h2 value-map]
  (let [s1 (:score h1)
        s2 (:score h2)]
    (if (= s1 s2)
      (compare-high-card (:cards h1) (:cards h2) value-map)
      (compare s1 s2))))

(defn sort-hands [value-map hands]
  (sort #(compare-hands %1 %2 value-map) hands))

(def face-value
  {\A 14 \K 13 \Q 12 \J 1 \T 10 \9 9
   \8 8 \7 7 \6 6 \5 5 \4 4 \3 3 \2 2})

(defn run [hands]
  (->> hands
       (map calc-scores)
       (sort-hands face-value)
       (map #(* (:bid %2) (+ 1 %1)) (range))
       (reduce +)))
