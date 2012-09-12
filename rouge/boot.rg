;; -*- mode: clojure; -*-

(ns rouge.core)

(def concat (fn [& lists]
              ; This should return a lazy seq.
              (apply .[] ruby/Rouge.Cons (.inject (.map lists | .to_a) | .+))))

(defmacro defn [name args & body]
  (list 'def name (concat (list 'fn args) body)))

(defn reduce [f coll]
  (.inject coll | f))

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

(defn puts [& args]
  (apply print args)
  (print "\n"))

(defn count [coll]
  (.length coll))

(defn = [a b]
  (.== a b))

(defn empty? [coll]
  (= 0 (count coll)))

(defn + [& args]
  (if (empty? args)
    0
    (reduce .+ args)))

(defn - [a & args]
  (reduce .- (concat (list a) args)))

(defn * [& args]
  (if (empty? args)
    1
    (reduce .* args)))

(defn / [a & args]
  (reduce ./ (concat (list a) args)))

(defn require [lib]
  (.require ruby/Kernel lib))

; vim: set ft=clojure:
