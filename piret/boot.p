;; piret

(ns piret.core)

; This should return a lazy seq.
(def concat (fn [& lists]
              (apply .[] ruby/Piret.Cons (.inject (.map lists | .to_a) | .+))))

(defmacro defn [name args & body]
  (list 'def name (concat (list 'fn args) body)))

; This should return a lazy seq.
(defn map [f coll]
  (.map coll | f))

;(defn str [& args]
  ;(let [args (map .to_s args)]
    ;(.join args "")))

;(defn print [& args]
  ;(.print Kernel (join (map .to_s args) " ")))

; vim: set ft=clojure:
