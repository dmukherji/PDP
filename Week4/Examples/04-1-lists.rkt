;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 04-1-lists) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; lists.rkt

(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

;; A List of Numbers (LON) is one of:
;; -- empty
;; -- (cons Number LON)

;; Template:
;; ;; list-fn : LOX -> ??
;; (define (list-fn lst)
;;   (cond
;;     [(empty? lst) ...]
;;     [else (... (first lst)
;;                (list-fn (rest lst)))]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; examples of list calculations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-equal? (empty? empty) true)
(check-equal? (empty? (cons 11 empty)) false)
(check-equal? (empty? (cons 22 (cons 11 empty))) false)

(check-equal? (first (cons 11 empty)) 11)
(check-equal? (rest  (cons 11 empty)) empty)

(check-equal? (first (cons 22 (cons 11 empty))) 22)
(check-equal? (rest  (cons 22 (cons 11 empty))) (cons 11 empty))

(check-error (first empty)
  "first: expected argument of type <non-empty list>; given empty")
(check-error (rest  empty)
  "rest: expected argument of type <non-empty list>; given empty")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lon-length : LON -> Integer
;; GIVEN: a LON
;; RETURNS: its length

;; If the tests are simple, you can use them as examples.
;; But they'd better be very very simple.
(define-test-suite lon-length-tests
  (check-equal? (lon-length empty) 0)
  (check-equal? (lon-length (cons 11 empty)) 1)
  (check-equal? (lon-length (cons 33 (cons 11 empty))) 2))

; STRATEGY: structural decomposition on lst : LON
(define (lon-length lst)
  (cond
    [(empty? lst) 0]
    [else (+ 1 
            (lon-length (rest lst)))]))

"lon-length tests"
(run-tests lon-length-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lon-sum : LON -> Number
;; GIVEN: a LON
;; RETURNS: its sum

;; EXAMPLES/TESTS:
(define-test-suite lon-sum-tests
  (check-equal? (lon-sum empty) 0)
  (check-equal? (lon-sum (cons 11 empty)) 11)
  (check-equal? (lon-sum (cons 33 (cons 11 empty))) 44)
  (check-equal? (lon-sum (cons 10 (cons 20 (cons 3 empty)))) 33))

; STRATEGY: structural decomposition on lst : LON
(define (lon-sum lst)
  (cond
    [(empty? lst) 0]
    [else (+ (first lst)
             (lon-sum (rest lst)))]))

"lon-sum tests"
(run-tests lon-sum-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lon-avg : LON -> Number
;; GIVEN: a non-empty LON
;; RETURNS: its average

(define-test-suite lon-avg-tests
  (check-equal? (lon-avg (cons 11 empty)) 11)
  (check-equal? (lon-avg (cons 33 (cons 11 empty))) 22)
  (check-equal? (lon-avg (cons 10 (cons 20 (cons 3 empty)))) 11))

; STRATEGY: functional composition
(define (lon-avg lst)
  (/ (lon-sum lst) (lon-length lst)))

"lon-avg tests"
(run-tests lon-avg-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; double-all : LON -> LON
;; GIVEN: a LON
;; RETURNS: a list just like the original, but with each
;; number doubled 

(define-test-suite double-all-tests
  (check-equal? (double-all empty) empty)
  (check-equal? (double-all (cons 11 empty)) (cons 22 empty))
  (check-equal? 
   (double-all (cons 33 (cons 11 empty)))
   (cons 66 (cons 22 empty))))

; strategy: structural decomposition on lst : LON
(define (double-all lst)
  (cond
    [(empty? lst) empty]
    [else (cons (* 2 (first lst))
                (double-all (rest lst)))]))

"double-all tests"
(run-tests double-all-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; remove-evens : LON -> LON
;; GIVEN: a LON
;; RETURNS: a list just like the original, but with all
;; the even numbers removed 

(define list-22-11-13-46-7 
    (cons 22 
          (cons 11 (cons 13 (cons 46 (cons 7 empty))))))
;; a list whose first even is not in the first position (not on the slides!)
(define list-17-22-11-13-46-7
  (cons 17 list-22-11-13-46-7))

(define-test-suite remove-evens-tests
  (check-equal? (remove-evens empty) empty)
  (check-equal? (remove-evens (cons 11 empty)) (cons 11 empty))
  (check-equal?
   (remove-evens list-22-11-13-46-7)
   (cons 11 (cons 13 (cons 7 empty))))
  (check-equal?
    (remove-evens list-17-22-11-13-46-7)
    (cons 17 (cons 11 (cons 13 (cons 7 empty))))))

;; STRATEGY: structural decomposition on lst : LON
(define (remove-evens lst)
  (cond
    [(empty? lst) empty]
    [else (if (even? (first lst))
              (remove-evens (rest lst))
              (cons (first lst)
                    (remove-evens (rest lst))))]))

"remove-evens tests"
(run-tests remove-evens-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; remove-first-even : LON -> LON
;; GIVEN: a LON
;; RETURNS: a list just like the original, but with the first even
;; number, if any, removed.

(define-test-suite remove-first-even-tests
  (check-equal? (remove-first-even empty) empty)
  (check-equal? (remove-first-even (cons 11 empty)) (cons 11 empty))
  (check-equal? (remove-first-even list-22-11-13-46-7)
                (cons 11 (cons 13 (cons 46 (cons 7 empty)))))
  (check-equal?
    (remove-first-even list-17-22-11-13-46-7)
    (cons 17 (cons 11 (cons 13 (cons 46 (cons 7 empty)))))))

; STRATEGY: structural decomposition on lst : LON
(define (remove-first-even lst)
  (cond
    [(empty? lst) empty]
    [else (if (even? (first lst))
              (rest lst)
              (cons (first lst)
                    (remove-first-even
                             (rest lst))))]))

"remove-first-even tests"
(run-tests remove-first-even-tests)
