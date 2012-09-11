;; piret

(ns piret.core)

(def concat (fn [& lists]
              (.inject (.map lists | .to_a) | .+)))

(defmacro defn [name args & body]
  (list 'def name (concat (list fn args) body)))

;(defn map [f coll]
  ;(.map coll | f))

;(defn str [& args]
  ;(let [args (map .to_s args)]
    ;(.join args "")))

;(defn print [& args]
  ;(.print Kernel (join (map .to_s args) " ")))

; vim: set ft=clojure:
