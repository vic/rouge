;; piret

(ns piret.core)

(def map (fn [f coll]
           (.map coll | f)))

(def str (fn [& args]
           (let [args (map .to_s args)]
             (.join args ""))))

(def print (fn [& args]
             (.print Kernel (join (map .to_s args) " "))))

; vim: set ft=clojure:
