;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname class-example2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)

;; Put your solutions here: http://bit.ly/cs5010sp12lect02
;; upload your solution as yourname.rkt
;; best plan is to go to this url, say "create document", and paste in
;; your solution.

;; Lists of books

(define-struct book (author title on-hand price))

;; A Book is a 
;;  (make-book String String Number Number)
;; Interpretation:
;; author is the author’s name
;; title is the title
;; on-hand is the number of copies on hand
;; price is the price in USD

;; book-fn : Book -> ??
;; (define (book-fn b)
;;   (... (book-author b) (book-title b) (book-on-hand b) (book-price b)))

;; A ListOfBooks (LOB) is either
;; -- empty
;; -- (cons Book LOB)

;; lob-fn : LOB -> ??
;; (define (lob-fn lob)
;;   (cond
;;     [(empty? lob) ...]
;;     [(cons? lob )
;;            (...
;;             (book-fn (first lob))
;;             (lob-fn (rest lob)))]))

;; An Inventory is a ListOfBooks.
;; Interp: the list of books that the bookstore carries, in any order.

(define lob1
  (list
    (make-book "Felleisen" "HtDP/1" 20 7)
    (make-book "Wand" "EOPL" 5 50)
    (make-book "Shakespeare" "Hamlet" 0 2)
    (make-book "Shakespeare" "Macbeth" 0 10)))

;; books-out-of-stock : LOB -> LOB
;; GIVEN: a list of books
;; RETURNS: a list of the books that are out of stock in the given LOB
;; Example:
;; (books-out-of-stock lob1) =

;;  (list
;;    (make-book "Shakespeare" "Hamlet" 0 2)
;;    (make-book "Shakespeare" "Macbeth" 0 10))
;; STRATEGY: structural decomposition on lob : LOB
(define (books-out-of-stock lob)
  (cond
    [(empty? lob) empty]
    [else
     (if (book-out-of-stock? (first lob)) 
         (cons (first lob) (books-out-of-stock (rest lob))) (books-out-of-stock (rest lob)))]))


(define (book-out-of-stock? b)
  (if (= (book-on-hand b) 0)
      true
      false))

;; book-inventory-value : Book -> Number
;; GIVEN: the inventory record for a book
;; RETURNS: the value of the copies on hand of the given book
;; (book-inventory-value (make-book "Felleisen" "HtDP/1" 20 7)) = 140
;; STRATEGY: struct decomp on b : Book
(define (book-inventory-value b)
  (* (book-on-hand b) (book-price b)))

(check-equal?
  (book-inventory-value (make-book "Felleisen" "HtDP/1" 20 7))
  140
  "simple test")

;; inventory-total-value : LOB -> Number
;; GIVEN: a LOB
;; RETURNS: the value of all the copies on hand of all the books in the
;; given LOB
;; (inventory-total-value lob1) = 390

(define (inventory-total-value lob)
  (cond
    [(empty? lob) 0]
    [(cons? lob)
     (+ (book-inventory-value (first lob))
        (inventory-total-value (rest lob)))]))

(check-equal?
  (inventory-total-value lob1)
  390
  "simple test")

;; classic-books : LOB -> LOB
;; RETURNS: the books written by Shakespeare
(define (classic-books lob)
   (cond
     [(empty? lob) empty]
     [(cons? lob)
      (if(book-is-classic? (first lob)) (cons (first lob) (classic-books (rest lob))) (classic-books (rest lob)))]))


(define (book-is-classic? book)
  (string=? (book-author book) "Shakespeare"))


;; expensive-books : LOB -> LOB
;; RETURNS: The books costing at least $6
(define (expensive-books lob)
   (cond
     [(empty? lob) empty]
     [(cons? lob)
      (if(book-is-expensive? (first lob)) (cons (first lob) (expensive-books (rest lob))) (expensive-books (rest lob)))]))


(define (book-is-expensive? book)
  (>= (book-price book) 6))