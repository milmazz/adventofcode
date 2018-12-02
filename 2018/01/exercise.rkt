#lang racket/base

#|
Reference: https://adventofcode.com/2018/day/1

If you want to test the results:

λ racket
> (require (file "exercise.rkt"))
> (frequency (file->list "input"))
520
> (first-frequency-reached-twice (file->list "input"))
394
|#

(require racket/set)
(require racket/match)

(provide frequency first-frequency-reached-twice)

(define (frequency changes)
  (foldl + 0 changes))

(define (first-frequency-reached-twice changes)
  (find-frequency (cons 0 (set 0)) changes))

(define (find-frequency acc changes)
  (match acc
    [result
     #:when (integer? result)
     result]
    [(cons current previous-frequencies)
     (find-frequency (reduce-while changes previous-frequencies current) changes)]))

(define (reduce-while changes previous-frequencies current)
  (match changes
    [changes
     #:when (eq? '() changes)
     (cons current previous-frequencies)]
    [(cons head tail)
     (define next (+ current head))
     (if (set-member? previous-frequencies next)
         next
         (reduce-while tail (set-add previous-frequencies next) next))]))
