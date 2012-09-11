;; piret

(ns piret.core)

(defmacro defn [name args & body]
  (list 'def name args & body))

(defn map [f coll]
  (.map coll | f))

(defn str [& args]
  (let [args (map .to_s args)]
    (.join args "")))

(defn print [& args]
  (.print Kernel (join (map .to_s args) " ")))

; vim: set ft=clojure:
