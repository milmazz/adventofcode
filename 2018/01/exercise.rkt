#lang racket/base

(define (frequency changes)
  (foldl + 0  changes))

(provide frequency)
