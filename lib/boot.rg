;; -*- mode: clojure; -*-

(ns rouge.core)

(def concat (fn [& lists]
              ; XXX lazy seq
              (apply .[] ruby/Rouge.Cons (.inject (.map lists | .to_a) | .+))))

(def list (fn [& elements]
            elements))

(defmacro defn [name args & body]
  (list 'def name (concat (list 'fn args) body)))

(defn reduce [f coll]
  (.inject coll | f))

(defn map [f coll]
  ; XXX lazy seq
  (.map coll | f))

(defn str [& args]
  (let [args (map .to_s args)]
    (.join args "")))

(defn print [& args]
  (let [args (map (fn [e] (.print ruby/Rouge e)) args)
        out  (.join args " ")]
    (.print ruby/Kernel out)))

(defn puts [& args]
  (.print ruby/Kernel (apply str args) "\n"))

(defn count [coll]
  (.length coll))

(defn not [bool]
  (or (= bool nil)
      (= bool false)))

(defn or [& exprs]
  ; XXX NOT SHORT CIRCUITING!
  (.find exprs | [e] e))

(defn and [& exprs]
  ; XXX NOT SHORT CIRCUITING!  Also not Clojurish: doesn't return falsey value find.
  (if (.all? exprs | [e] e)
    (.last (.to_a exprs))))

(defn = [a b]
  (if (and (.respond_to? a :to_a)
           (.respond_to? b :to_a))
    (.== (.to_a a) (.to_a b))
    (.== a b)))

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

(defn cons [head tail]
  ; XXX lazy seq
  (ruby/Rouge.Cons. head tail))

(defn range [from til]
  ; XXX this will blow so many stacks
  (if (= from til)
    ruby/Rouge.Cons.Empty
    (cons from (range (+ 1 from) til))))

(ns rouge.test
  (:use rouge.core ruby))

(defmacro test [& body]
  ; Non-standard; while we're missing dynamic vars ...
  (concat '(let [test-level 0]) body))

(defmacro testing [what & tests]
  (concat
    (list 'do
      (list 'puts '(* " " test-level 2) "testing: " what))
    (list
      (concat '(let [test-level (+ 1 test-level)]) tests))))

; (defmacro testing [what & tests]
;   `(do
;      (puts (* " " test-level 2) "testing: " ~what)
;      (let [test-level (+ 1 test-level)]
;        ~@tests)))

(defmacro is [check]
  (list
    'if (list 'not check)
      (list 'do
        (list 'puts "FAIL in ???")
        (list 'puts "expected: " (.print ruby/Rouge check))
        (list 'puts "  actual: (not " (.print ruby/Rouge check) ")"))
      'true))

; (defmacro is [check]
;   `(if (not ~check)
;      (do
;        (puts "FAIL in ???")
;        (puts "expected: " ~(print check))
;        (puts "  actual: (not " ~(print check) ")"))))


; vim: set ft=clojure:
