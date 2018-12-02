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
    (check-equal? (frequency '(-1 -2 -3)) -6))

   (test-case
    "Should find first frequency reached twice"

    (check-equal? (first-frequency-reached-twice '(1 -1)) 0)
    (check-equal? (first-frequency-reached-twice '(1 -2 3 1 1 -2)) 2)
    (check-equal? (first-frequency-reached-twice '(3 3 4 -2 -4)) 10)
    (check-equal? (first-frequency-reached-twice '(-6 3 8 5 -6)) 5)
    (check-equal? (first-frequency-reached-twice '(7 7 -2 -7 -4)) 14))))

(require rackunit/text-ui)
(run-tests exercise-tests)
