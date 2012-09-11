;; piret

(ns piret.core)

(def map (fn [f coll]
           (.map coll | f)))

(def str (fn [& args]
           (let [args (map .to_s args)]
             (.join args ""))))

; vim: set ft=clojure:
