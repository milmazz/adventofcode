#lang racket/base

(require rackunit
         "exercise.rkt")

(define exercise-tests
  (test-suite
   "Tests for exercise day 1"

   (test-case
    "Should calculate frequency"
    
    (check-equal? (frequency '(1 -2 3 1)) 3)
    (check-equal? (frequency '(1 1 1)) 3)
    (check-equal? (frequency '(1 1 -2)) 0)
    (check-equal? (frequency '(-1 -2 -3)) -6))))

(require rackunit/text-ui)
(run-tests exercise-tests)