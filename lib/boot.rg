;; -*- mode: clojure; -*-

(ns rouge.core)

(def seq (fn [coll]
           ; XXX right now this just coerces to a Cons
           (let [s (apply .[] ruby/Rouge.Cons (.to_a coll))]
             (if (.== s ruby/Rouge.Cons.Empty)
               nil
               s))))

(def concat (fn [& lists]
              ; XXX lazy seq
              (seq (.inject (.map lists | .to_a) | .+))))

(def list (fn [& elements]
            elements))

(defmacro defn [name args & body]
  `(def ~name (fn ~args ~@body)))

(defn vector [& args]
  (.to_a args))

(defn reduce [f coll]
  (.inject coll | f))

(defn map [f coll]
  ; XXX lazy seq
  (.map coll | f))

(defn str [& args]
  (let [args (map .to_s args)]
    (.join args "")))

(defn pr-str [& args]
  (let [args (map #(.print ruby/Rouge %) args)]
    (.join args " ")))

(defn print [& args]
  (.print ruby/Kernel (apply pr-str args)))

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

(defn sequential? [coll]
  (and
    (or (.== (class coll) ruby/Array)
        (.== (class coll) ruby/Rouge.Cons)
        (.== coll ruby/Rouge.Cons.Empty))
    true))

(defn = [a b]
  (let [pre (if (and (sequential? a)
                     (sequential? b))
              seq
              #(do %))]
    (.== (pre a) (pre b))))

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

(defn class [object]
  (.class object))

(defn seq? [object]
  (or (= (class object) ruby/Rouge.Cons)
      (= object ruby/Rouge.Cons.Empty)))

(def *ns* 'user)

(defn ns-publics [ns]
  )

(defn nth [coll index]
  (.[] (seq coll) index))

(defn first [coll]
  (.head (seq coll)))

(defn rest [coll]
  (.tail (seq coll)))

(defn next [coll]
  (seq (rest coll)))

(defn second [coll]
  (first (next coll)))

(defn macroexpand [form]
  (if (and (seq? form)
           (= (first form) :wah))
    :blah
    :hoo))

(ns rouge.test
  (:use rouge.core ruby))

(defmacro test [& body]
  ; Non-standard; while we're missing dynamic vars ...
  `(let [test-level 0]
     ~@body))

(defmacro testing [what & tests]
  `(do
     (puts (* " " test-level 2) "testing: " ~what)
     (let [test-level (+ 1 test-level)]
       ~@tests)))

(defmacro is [check]
  `(if (not ~check)
     (do
       (puts "FAIL in ???")
       (puts "expected: " ~(pr-str check))
       (let [actual (if (and (seq? '~check)
                             (= 'not (first '~check)))
                      (second '~check)
                      `(not ~'~check))]
         (puts "  actual: " (pr-str actual))))
     true))

; vim: set ft=clojure:
