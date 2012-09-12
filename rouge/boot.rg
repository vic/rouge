;; -*- mode: clojure; -*-

(ns rouge.core)

(def concat (fn [& lists]
              ; This should return a lazy seq.
              (apply .[] ruby/Rouge.Cons (.inject (.map lists | .to_a) | .+))))

(defmacro defn [name args & body]
  (list 'def name (concat (list 'fn args) body)))

(defn map [f coll]
  ; This should return a lazy seq.
  (.map coll | f))

(defn str [& args]
  (let [args (map .to_s args)]
    (.join args "")))

(defn print [& args]
  (let [args (map .to_s args)
        out  (.join args " ")]
    (.print ruby/Kernel out)))

; vim: set ft=clojure: