;; rouge

(ns rouge.core)

; This should return a lazy seq.
(def concat (fn [& lists]
              (apply .[] ruby/Rouge.Cons (.inject (.map lists | .to_a) | .+))))

(defmacro defn [name args & body]
  (list 'def name (concat (list 'fn args) body)))

; This should return a lazy seq.
(defn map [f coll]
  (.map coll | f))

(defn str [& args]
  (let [args (map .to_s args)]
    (.join args "")))

(defn print [& args]
  (let [args (map .to_s args)
        out  (.join args " ")]
    (.print ruby/Kernel out)))

; vim: set ft=clojure:
