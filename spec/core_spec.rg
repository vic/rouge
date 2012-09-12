;; -*- mode: clojure; -*-

(ns spec.rouge.core
  (:use rouge.test))

(test
  (testing "list"
    (testing "empty list creation"
      (is (= (list) '())))
    (testing "unary list creation"
      (is (= (list "trent") '("trent")))
      (is (= (list 42) '(42))))
    (testing "n-ary list creation"
      (is (= (apply list (range 1 51)) (.to_a (ruby/Range. 1 50))))))
  (testing "this will surely fail"
    (is (= 5 "quux"))))

; vim: set ft=clojure:
