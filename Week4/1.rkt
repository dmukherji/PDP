;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |1|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |2|) (read-case-sensitive #t) (teachpacks ((lib "image.ss" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.ss" "teachpack" "2htdp")))))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(require 2htdp/universe)
(require 2htdp/image)

(provide stock-total-value)
(provide stock-total-volume)
(provide price-for-line-item)
(provide fillable-now?)
(provide days-til-fillable)
(provide price-for-order)
(provide inventory-after-order)
(provide increase-prices)
(provide daily-update)
(provide make-book)
(provide make-line-item)
(provide reorder-present?)
(provide empty-reorder)
(provide make-reorder)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA DEFINATION

;; A ReOrder is a (make-reorder Number Number)
(define-struct reorder (days-left copies))
;; interp: 
;; days-left shows the number of days until the next shipment of the given book 
;; copies means the number of books ordered in the reorder
;; template :
;; reorder-fn : ReOrder -> ??
;(define (reorder-fn reorder)
;    (...
;     (reorder-days-left reorder)
;     (reorder-copies reorder)))

;; A ReorderStatus is one of:
;; ---ReOrder
;; ---false
;; Interp:
;; If there is acturally a reorder, the status of reorder is set to a ReOrder
;; , which describe the days left before shipment of the order
;; and the number of copies ordered
;; else if there is no reorder yet, a Boolean value "false" is placed
;; template:
;; reorder-status-fn : ReOrderDtatus -> ?
;(define (reorder-status-fn ros)
;    (cond
;        [(reorder? ros) ...]
;        [(false? ros) ...]))


;; A Book is a (make-book Number String String String Number Number 
;; Number String Number)
(define-struct book (isbn title author publisher unit-price unit-cost on-hand 
                          reorder-status cuft))
;; Interp:
;; isbn is a Number stands for "international standard book number"
;;which acts as the unique identifier of the book
;; titile is a String represents the name of the book
;; author is a String represents the people who wrote the book
;; publisher is a String represents the company that published the book
;; unit-price is a Number which represents the price when the book is sold 
;; unit-cost is a Number which means the amount of money the bookstore spent 
;; on the book
;; on-hand is Number represents the number of books that on hands
;; reorder-status is a ReOrderDtatus which represents whether there is a 
;; outstanding reorder:
;; --if there is a reorder, the status will show the number of days until the 
;; ---next shipment of the given book and the number of copies of books ordered
;; ---we assume that there will be no delay
;; --if there is no reorder, the status will simply show a false
;; cuft is Number shows the occupied space of the book. And this value is 
;; calculated in cubic feet
;; tmplate:
;; book-fn : Book -> ?
;(define (book-fn book)
;  (...
;   (book-isbn book)
;   (book-title book)
;   (book-author book)
;   (book-publisher book)
;   (book-unit-price book)
;   (book-unit-cost book)
;   (book-on-hand book)
;   (book-reorder-status book)
;   (book-cuft book)))

;; A MaybeNumber is one of:
;; -- Number (interp: returned value is a Number)
;; -- false (interp: returned balue is a false)
;; template:
;; may-be-number-fn : MaybeNumber- >?
;(define (may-be-number-fn m)
;    (cond 
;        [(number? m) ...]
;        [(false? m) ...]))

;; An LineItem is (make-line-item Number Number)
(define-struct line-item (isbn quantity))
;; Interp:
;; An line item consists of two parts, 
;; the first one the isbn, which is a Number, to identify the book
;; the second one is the quantity, which is also a Numebr, to represent the 
;; number of given book in this line item.
;; template :
;; line-item-fn : LineItem -> ?
;(define (line-item-fn line-item)
;    (...
;     (oline-item-isbn line-item)
;     (line-item-quantity line-item)))

;; An Order is a ListOf<LineItem> which is either 
;; -- empty  or
;; -- (cons LineItem ListOf<LineItem>)
;; Interp:
;; empty means no LineItem in the list
;; or it's a sequence made by a LineItem and another sequence of LineItems
;; template 
;; loli-fn : ListOf<LineItem> -> ?
;(define (loli-fn lob)
;    (cond 
;        [(empty? loli) ...]
;        [else (... (first loli)
;                   (loli-fn (rest loli)))]))


;; A Inventory is a ListOf<Book> which is one of 
;; ---empty
;; ---(cons book ListOf<Book>)
;; Interp:
;; empty means no books in the list
;; or it's a sequence made by a book and another sequence of books
;; template 
;; lob-fn : ListOf<Book> -> ?
;(define (lob-fn lob)
;    (cond 
;        [(empty? lob) ...]
;        [else (... (first lob)
;                   (lob-fn (rest lob)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constant variables
;; book with or without copies
;; book has re-order (today/later) or no re-order
;; total 2*3 books
;; plus book
;; BOOK1 is a book with reorder
(define BOOK1 (make-book 1111 "C Programming Language " "Brian W. Kernighan" 
                         "Prentice Hall" 50 30 100  (make-reorder 12 100) 5))
;; BOOK2 is a book with reorder which should be shipped today
(define BOOK2 (make-book 2222 "Computer Systems: A Programmer's Perspective" 
                         "Randal E. Bryant" "Addison-Wesley" 20 15 10
                         (make-reorder 0 50) 4))
;; BOOK3 is a book without reorder
(define BOOK3 (make-book 3333 "ALGEBRA 1" "Stanley A Smith" "Prentice Hall" 
                         80 50 500 false 8))
;; BOOK4 is a book with no copies left 
;; and request a reorder which should be shipped today
(define BOOK4 (make-book 4444 "MATH 2005 STUDENT EDITION" 
                         "Scott Foresman" "Addison-Wesley" 60 30 0
                         (make-reorder 22 500) 6))
;; BOOK5 is a book with no copies left and request a reorder
(define BOOK5 (make-book 5555 "A Practical Guide to Agile Process"
                         "Kenneth S. Rubin" "Addison-Wesley" 60 30 0
                         (make-reorder 0 20) 6))
;; BOOK6 is a book with no copies left and did not request a reorder
(define BOOK6 (make-book 6666 "The Nature of Computation" "Cristopher Moore"
                         "Oxford University Press" 80 60 0 false 6))
;; BOOK7 is a book with reorder
(define BOOK7 (make-book 7777 "Java " "Brian W. Kernighan" 
                         "Prentice Hall" 60 30 50  (make-reorder 0 100) 5))


;; BOOK1-AFTER-ORDER is a BOOK1 after order
(define BOOK1-AFTER-ORDER (make-book 1111 "C Programming Language "
                                     "Brian W. Kernighan" 
                         "Prentice Hall" 50 30 90 (make-reorder 12 100) 5))
;; BOOK7-AFTER-ORDER is a BOOK7 after order
(define BOOK7-AFTER-ORDER (make-book 7777 "Java " "Brian W. Kernighan" 
                         "Prentice Hall" 60 30 10  (make-reorder 0 100) 5))

;; BOOK2-PRICE-INCREASED is a book after price increased for "Addison-Wesley"
(define BOOK2-PRICE-INCREASED 
  (make-book 2222 "Computer Systems: A Programmer's Perspective" 
             "Randal E. Bryant" "Addison-Wesley" 22 15 10
             (make-reorder 0 50) 4))
;; BOOK4-PRICE-INCREASED is a book after price increased for "Addison-Wesley"
;; and request a reorder which should be shipped today
(define BOOK4-PRICE-INCREASED 
  (make-book 4444 "MATH 2005 STUDENT EDITION" 
             "Scott Foresman" "Addison-Wesley" 66 30 0
             (make-reorder 22 500) 6))
;; BOOK5-PRICE-INCREASED is a book after price increased for "Addison-Wesley"
(define BOOK5-PRICE-INCREASED 
  (make-book 5555 "A Practical Guide to Agile Process"
             "Kenneth S. Rubin" "Addison-Wesley" 66 30 0
             (make-reorder 0 20) 6))

;; BOOK2-PRICE-DECREASED is a book after price increased for "Addison-Wesley"
(define BOOK2-PRICE-DECREASED 
  (make-book 2222 "Computer Systems: A Programmer's Perspective" 
             "Randal E. Bryant" "Addison-Wesley" 18 15 10
             (make-reorder 0 50) 4))
;; BOOK4-PRICE-DECREASED is a book after price increased for "Addison-Wesley"
;; and request a reorder which should be shipped today
(define BOOK4-PRICE-DECREASED (make-book 4444 "MATH 2005 STUDENT EDITION" 
                         "Scott Foresman" "Addison-Wesley" 54 30 0
                         (make-reorder 22 500) 6))
;; BOOK5-PRICE-DECREASED is a book after price increased for "Addison-Wesley"
(define BOOK5-PRICE-DECREASED 
  (make-book 5555 "A Practical Guide to Agile Process"
             "Kenneth S. Rubin" "Addison-Wesley" 54 30 0
             (make-reorder 0 20) 6))
;; BOOK2-UPDATED-TODAY is a book after BOOK2's on-hand copies updated
(define BOOK2-UPDATED-TODAY 
  (make-book 2222 "Computer Systems: A Programmer's Perspective" 
             "Randal E. Bryant" "Addison-Wesley" 20 15 60
             false 4))
;; BOOK5 is a book with no copies left and request a reorder
(define BOOK5-UPDATED-TODAY
  (make-book 5555 "A Practical Guide to Agile Process"
             "Kenneth S. Rubin" "Addison-Wesley" 60 30 20
             false 6))
;; BOOK7-UPDATED-TODAY is a book after BOOK7's on-hand copies updated
(define BOOK7-UPDATED-TODAY (make-book 7777 "Java " "Brian W. Kernighan" 
                         "Prentice Hall" 60 30 150 false 5))
;; BOOK1-UPDATED-TODAY is a book after BOOK1's re-order copies updated
(define BOOK1-UPDATED-TODAY 
  (make-book 1111 "C Programming Language " "Brian W. Kernighan" 
                         "Prentice Hall" 50 30 100  (make-reorder 11 100) 5))
;; BOOK4-UPDATED-TODAY is a book after BOOK4's re-order copies updated
(define BOOK4-UPDATED-TODAY (make-book 4444 "MATH 2005 STUDENT EDITION" 
                         "Scott Foresman" "Addison-Wesley" 60 30 0
                         (make-reorder 21 500) 6))
(define INVENTORY (list BOOK1 BOOK2 BOOK3 BOOK4 BOOK5 BOOK6 BOOK7))
(define INVENTORY-AFTER-ORDER (list BOOK1-AFTER-ORDER BOOK2 BOOK3 BOOK4 
                                    BOOK5 BOOK6 BOOK7-AFTER-ORDER))
(define INVENTORY-PRICE-INCREASED 
  (list BOOK1 BOOK2-PRICE-INCREASED BOOK3 
        BOOK4-PRICE-INCREASED BOOK5-PRICE-INCREASED BOOK6 BOOK7))
(define INVENTORY-PRICE-DECREASED 
  (list BOOK1 BOOK2-PRICE-DECREASED BOOK3 
        BOOK4-PRICE-DECREASED BOOK5-PRICE-DECREASED BOOK6 BOOK7))
(define INVENTORY-UPDATED-TODAY
  (list BOOK1-UPDATED-TODAY BOOK2-UPDATED-TODAY BOOK3
        BOOK4-UPDATED-TODAY BOOK5-UPDATED-TODAY BOOK6 BOOK7-UPDATED-TODAY))



(define EMPTY-INVENTORY empty)
;; this line item orders BOOK1(has enough copies left)
(define LINE-ITEM1 (make-line-item 1111 10))
;; this line item orders BOOK2(doesn't have enough copies left; has reorder)
(define LINE-ITEM2 (make-line-item 2222 50))
;; this line item orders BOOK3(doesn't have enough copies left; no reorder)
(define LINE-ITEM3 (make-line-item 3333 600))
;; this line item orders BOOK4(doesn't have enough copies left 
;; and can be filled after reorder)
(define LINE-ITEM4 (make-line-item 4444 15))
;; this line item orders BOOK5(doesn't have enough copies left and
;; cannot be filled after reorder)
(define LINE-ITEM5 (make-line-item 5555 50))
;; this line item orders BOOK6(will never be filled)
(define LINE-ITEM6 (make-line-item 6666 15))
;; this line item orders BOOK7
(define LINE-ITEM7 (make-line-item 7777 40))
;; this line item orders BOOK8 which doesn't exist
(define LINE-ITEM8 (make-line-item 8888 15))

;; order that contains line-items can be filled now
(define ORDER-FILLABLE-NOW (list LINE-ITEM1 LINE-ITEM7))

;; order that contains line-items cannot be filled now 
;; but can be filled after reorder
;; LINE-ITEM2 and LINE-ITEM4 not enough copies now, can be filled after reorder
;; in more than 0 days
(define ORDER-FILLABLE-LATER (list LINE-ITEM1 LINE-ITEM2 LINE-ITEM4))
;; can be filled now (0 days)
(define ORDER-FILLABLE-LATER-0 (list LINE-ITEM1 LINE-ITEM2))
;; order that contains line-items cannot be filled forever
;; because book doesn't exist for LINE-ITEM8
(define ORDER-NOT-FILLABLE-BOOK-NOT-EXIST (list LINE-ITEM1 LINE-ITEM2
                                        LINE-ITEM3 LINE-ITEM8))
;; LINE-ITEM5 : reorder is not enough
(define ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH 
  (list LINE-ITEM1 LINE-ITEM2 LINE-ITEM3 LINE-ITEM4 LINE-ITEM5))
;; LINE-ITEM6 : no copies now and no more reorder
(define ORDER-NOT-FILLABLE-NO-COPIES-AND-REORDER 
  (list LINE-ITEM1 LINE-ITEM2 LINE-ITEM3 LINE-ITEM4 LINE-ITEM6))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; empty-reorder : Any -> ReorderStatus
;; Ignores its argument and produces a ReorderStatus showing no pending
;; reorder.
;; example: (empty-reorder a)=false
;; strategy: function composition
(define (empty-reorder a)
    false)

(define (empty-reorder-check in1 out)
  (check-equal? (empty-reorder in1) out
                (format "(empty-reorder ~a) should be ~a" in1 out)))
(define-test-suite empty-reorder-tests
    (empty-reorder-check 1 false))
(run-tests empty-reorder-tests)


;; stock-total-value : Inventory -> Number
;; the function takes in an Inverntory of books, and try to calculate the total 
;; profit for all items in stock. 
;; For each book, there is  aunit-price and a unit-cost, so the profit for each
;; book would be (unit-price - unit-cost). And the total profit of a book is 
;; profit times the number of book in stock. Therefore the output of the 
;; function would be the sum of profit of each book in stock.
;; example: (stock-total-value INVENTORY) = 170500
;; strategy :  structural decomposition on inventory [Inventory]
;(define (stock-total-value inventory)
;    (cond 
;        [(empty? inventory) 0]
;        [else (+
;                 (book-profit (first inventory))
;                 (stock-total-value (rest inventory)))]))

;; strategy: higher order function composition
(define (stock-total-value inventory)
    (foldr + 0 (map book-profit inventory)))
;; book-profit : Book - > Number
;; the function returns a Number represents the total profit of the given book
;; to get the result, the profit for each book is (unit-price - unit-cost)
;; so the return value is profit times the number of books on hand
;; example:
;; strategy: structural decomposition on book [Book]
(define (book-profit book)
  (* (book-on-hand book)
      (- (book-unit-price book) (book-unit-cost book))))

;; Tests for normal inventory and empty one
(define (stock-total-value-check in out)
  (check-equal? (stock-total-value in) out
                (format "(stock-total-value ~a) should be ~a" in out)))
(define-test-suite stock-total-value-tests
    (stock-total-value-check INVENTORY 18550)
    (stock-total-value-check EMPTY-INVENTORY 0))

(run-tests stock-total-value-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stock-total-volume : Inventory -> Number
;; this function return the total volumn needed to store all book;
;; to get the value simply add the required volumn of each book
;; example: (stock-total-volume INVENTORY) = 4540
;; strategy: structural decomposition on inventory [Inventory]
;(define (stock-total-volume inventory)
;    (cond 
;        [(empty? inventory) 0]
;        [else (+
;                 (book-total-volumn (first inventory))
;                 (stock-total-volume (rest inventory)))]))
;; strategy: higher order function composition
(define (stock-total-volume inventory)
    (foldr + 0 (map book-total-volumn inventory)))
;; book-total-volumn : Book - > Number
;; the function returns a Number represents the total profit of the given book
;; for each book there is a cuft value represents the the volume taken up by
;; one unit of this item, in cubic feet. The result will be cuft times the 
;; number of books on hand
;; example: (book-total-volumn BOOK1) = 500
;; strategy: structural decomposition on book [Book]
(define (book-total-volumn book)
  (* (book-on-hand book) (book-cuft book)))

;; Tests for normal inventory and empty one
(define (stock-total-volume-check in out)
  (check-equal? (stock-total-volume in) out
                (format "(stock-total-volume ~a) should be ~a" in out)))
(define-test-suite stock-total-volume-tests
  ;; for normal inventory
    (stock-total-volume-check INVENTORY 4790)
  ;; for empty inventory
    (stock-total-volume-check EMPTY-INVENTORY 0))
(run-tests stock-total-volume-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; price-for-line-item : Inventory LineItem -> MaybeNumber
;; Takes an inventory and a line item and returns the price for that line
;; item (the quantity times the unit price for that item).  Returns false
;; if that isbn does not exist in the inventory.
;; example: (price-for-line-item INVENTORY LINE-ITEM1) = 500
;; strategy: structural decomposition on inventory [Inventory]
;(define (price-for-line-item inventory li)
;    (cond 
;        [(empty? inventory) false]
;        [else (select-num-from-maybenumber 
;                  (get-items-price (first inventory) li)
;                  (price-for-line-item (rest inventory) li))]))

;; strategy: higher order function composition
(define (price-for-line-item inventory li)
  (local (;; get-price : Book -> MaybeNumber
          ;; given a book, compare it with the line-item
          ;; if they match  return the price
          ;; else return a false represent the book doesn;t exist
          (define (get-price book)
              (get-items-price book li)))
      (foldr select-num-from-maybenumber false (map get-price inventory))))
;; get-line-item-price : MaybeNumber MaybeNumber -> MaybeNumber
;; given two MaybeNumber,if there is a number else return false
;; always return the number among the inputs;
;; this is used to help price-for-line-item keep the number in the recursion
; example:
; (get-line-item-price 5 false) =5
;; strategy: structural decomposition on maybenumber1 [MaybeNumber]
(define (select-num-from-maybenumber maybenumber1 maybenumber2)
    (cond 
       [(false? maybenumber1) maybenumber2]
       [(number? maybenumber1) maybenumber1]))

;; get-items-price : Book LineItem -> Number
;; this function is used to calculate the price of the given line-item after
;; we make sure the line-item existing in the inventory
;; example: (get-items-price BOOK1 LINE-ITEM1) = 500
;; strategy: structural decomposition on book [Book]
(define (get-items-price book li)
    (if (line-item-match? book li)
        (get-items-price-helper (book-unit-price book) li)
        false))

;; line-item-match? : Book LineItem -> Boolean
;; this function is used to decide whether the given book and line-item is 
;; matched by comparing their isbn number
;; example: (line-item-match? BOOK1 LINE-ITEM1) = true
;; strategy: structural decomposition on book [Book]
(define (line-item-match? book li)
    (line-item-match-helper? (book-isbn book) li))

;; line-item-match-helper? : Number LineItem -> Boolean
;; this function is used to decide whether the given isbn and line-item is 
;; matched by comparing their isbn number
;; example:(line-item-match? 1111 LINE-ITEM1) = true
;; strategy: structural decomposition on li [LineItem]
(define (line-item-match-helper? isbn li)
    (= isbn (line-item-isbn li)))


;; get-items-price-helper : Number LineItem -> Boolean
;; the result of the calcualtion is: unit-price times quantity required by 
;; the line-item
;; example: (get-items-price-helper 50 LINE-ITEM1) = 500
;; strategy: structural decomposition on li [LineItem]
(define (get-items-price-helper unit-price li)
    (* unit-price (line-item-quantity li)))

;;(price-for-line-item INVENTORY (make-line-item 1111 10))
;;(price-for-line-item INVENTORY (make-line-item 0000 10))
;; Tests for normal inventory and empty one
(define (price-for-line-item-check in1 in2 out)
  (check-equal? (price-for-line-item in1 in2) out
                (format "(stock-total-volume ~a ~a) should be ~a" in1 in2 out)))
(define-test-suite price-for-line-item-tests
  ;; for line-item that exist (LINE-ITEM1)
    (price-for-line-item-check INVENTORY LINE-ITEM1 500)
  ;; for line-item that doesn't exist (LINE-ITEM8)
    (price-for-line-item-check INVENTORY LINE-ITEM8 false)
  ;; for empty inventory
    (price-for-line-item-check EMPTY-INVENTORY LINE-ITEM1 false)
    (price-for-line-item-check EMPTY-INVENTORY LINE-ITEM8 false))
(run-tests price-for-line-item-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fillable-now? : Order Inventory -> Boolean.
;; Given an order and an inventory, returns true iff there are enough
;; copies of each book on hand to fill the order.  If the order contains
;; a book that is not in the inventory, then the order is not fillable.
;; example: (fillable-now? ORDER-FILLABLE-NOW INVENTORY )=true
;; strategy: structural decomposition on order [Order]
;(define (fillable-now? order inventory)
;    (cond 
;        [(empty? order) true]
;        [else (and
;               (line-item-fillable-now? (first order) inventory)
;               (fillable-now? (rest order) inventory))]))

;; strategy: higher order function composition
(define (fillable-now? order inventory)
    (local(
           ;; check-fillability lineItem-> Boolean
           ;; it checks whether the given line-item is available 
           ;; based on the inventory from the upper function
           (define (check-fillability li)
             (line-item-fillable-now? li inventory)))
    (andmap check-fillability order)))
;; line-item-fillable-now? : LineItem Inventory  -> Boolean
;; Takes an inventory and a line item and returns a Boolean value to decide
;; whether the given line-item can be filled by the inventory
;; example: (line-item-fillable-now? LINE-ITEM1 INVENTORY )=true
;; strategy: structural decomposition on inventory [Inventory]
;(define (line-item-fillable-now? li inventory )
;    (cond 
;        [(empty? inventory) false]
;        [else (or
;                 (enough-copies-on-hand? (first inventory) li)
;                 (line-item-fillable-now?  li (rest inventory)))]))

;; strategy: higher order function composition
(define (line-item-fillable-now? li inventory)
    (local(;; check-enough-copies? Book -> Boolean
           ;; this function checks whether there are enough coppies 
           ;; of the given line-item
           (define (check-enough-copies-on-hand? book)
             (enough-copies-on-hand? (book-isbn book)(book-on-hand book) li)))
    (ormap check-enough-copies-on-hand? inventory)))

;; enough-copies-on-hand?-helper : Number LineItem -> Boolean
;; this function is used to decide whether there are enough copies left to
;; fill the need in the given LineItem
;; example: (enough-copies-on-hand?-helper 1111 100 LINE-ITEM1)= true
;; strategy: structural decomposition on li [LineItem]
(define (enough-copies-on-hand? isbn on-hand li)
    (if (= isbn (line-item-isbn li))
        (>= on-hand (line-item-quantity li))
        false))


;; Tests for normal inventory and empty one
(define (fillable-now?-check in1 in2 out)
  (check-equal? (fillable-now? in1 in2) out
               (format "(fillable-now?-check ~a ~a) should be ~a" in1 in2 out)))
(define-test-suite fillable-now?-tests

  ;; order can be filled now
    (fillable-now?-check ORDER-FILLABLE-NOW INVENTORY true)
  ;; order cannot be filled now, but after re-order
    (fillable-now?-check ORDER-FILLABLE-LATER INVENTORY false)
  ;; order cannot be filled now
  ;; because book doesn't exist for LINE-ITEM8
    (fillable-now?-check ORDER-NOT-FILLABLE-BOOK-NOT-EXIST INVENTORY false)
  ;order cannot be fillednow,even after reorder
    (fillable-now?-check ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH INVENTORY false)
  ;; order cannot be filled now because no copies left now
    (fillable-now?-check ORDER-NOT-FILLABLE-NO-COPIES-AND-REORDER 
                         INVENTORY false)
  ;; when both order and inventory are empty
    (fillable-now?-check empty EMPTY-INVENTORY true)
  ;; when inventory is empty
    (fillable-now?-check ORDER-FILLABLE-NOW EMPTY-INVENTORY false)
  ;; when order is empty
  (fillable-now?-check empty EMPTY-INVENTORY true))
  
    
(run-tests fillable-now?-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; days-til-fillable : Order Inventory -> MaybeNumber
;; Given an order and an inventory, the function decide how many days
;; are there beofre the order can be filled. If the function return false, 
;; the order cannot be filled even after the reorder
;; example:  (days-til-fillable ORDER-FILLABLE-LATER INVENTORY)= 22
;; strategy: function composition
(define (days-til-fillable order inventory)
    (if (order-fillable? order inventory)
        (days-til-fillable-helper order inventory)
        false))

;; order-fillable? : Order Inventory -> Boolean.
;; Given an order and an inventory, returns true iff there are enough
;; copies of each book on hand to fill the order.  If the order cannot be 
;; filled now, it will check whether it can be filled after reorder
;; If the order contains book that is not in the inventory, then the 
;; order is not fillable.
;; example:  (order-fillable? ORDER-FILLABLE-LATER INVENTORY)= false
;; strategy: structural decomposition on order [Order]
;(define (order-fillable? order inventory)
;    (cond 
;        [(empty? order) true]
;        [else (and
;               (line-item-fillable? (first order) inventory)
;               (order-fillable? (rest order) inventory))]))

;; strategy: higher order function composition
(define (order-fillable? order inventory)
    (local(;; check-fillability : LineItem -> Boolean
           ;; check whethe rorder can be filled now or later
           (define (check-fillability li)
             (line-item-fillable? li inventory)))
    (andmap check-fillability order)))

;; line-item-fillable? : LineItem Inventory  -> Boolean
;; Takes an inventory and a line item and returns a Boolean value to decide
;; whether the given line-item can be filled by the inventory
;; example:  (line-item-fillable? INVENTORY LINE-ITEM2)= false
;; strategy: structural decomposition on inventory [Inventory]
;(define (line-item-fillable? li inventory )
;    (cond 
;        [(empty? inventory) false]
;        [else (or
;                 (enough-copies-now-or-after-reorder?  li (first inventory))
;                 (line-item-fillable? li (rest inventory) ))]))

;; strategy: higher order function composition and
;;           structural decomposition on book [Book]
(define (line-item-fillable? li inventory)
    (local(;; check-line-item-fillable : Book -> Boolean
           ;; check whether the book has enough copies now or later 
           ;; for the lineIitem in upper function
           (define (check-line-item-fillable book)
              (enough-copies-now-or-after-reorder? 
                                   (book-isbn book)
                                   (book-on-hand book)
                                   (book-reorder-status book) li)))
            (ormap check-line-item-fillable inventory)))

;; enough-copies-now-or-after-reorder? : Number Number ReorderStatus
;;                                               LineItem-> Boolean
;; this function is used to decide whether there are enough copies left to
;; fill the need in the given LineItem now. If there is not, check whether the
;; order can be filled after reorder.
;; example:
;;(enough-copies-now-or-after-reorder? 3333 500 false LINE-ITEM3)
;; strategy: function composition
(define (enough-copies-now-or-after-reorder? isbn on-hand status li)
     (if (line-item-match-helper? isbn li)
         (or (enough-copies-on-hand? isbn on-hand li)
             (enough-copies-after-reorder? on-hand status li))
         false))

;; enough-copies-after-reorder? : Number ReorderStatus LineItem-> Boolean
;; check whether the order can be filled after reorder.
;; example: 
;; (enough-copies-after-reorder? 100 (make-reorder 12 100) LINE-ITEM1)= true
;; strategy: structural decomposition on status [ReorderStatus]
(define (enough-copies-after-reorder? on-hand status li)
    (cond
        [(reorder? status) (enough-copies-after-reorder?-helper 
                                             on-hand 
                                             (reorder-copies status) 
                                             li)]
        [(false? status) false]))

;; enough-copies-after-reorder?-helper : Number Number LineItem-> Boolean       
;; result is calculated to check whehte the sum of on-hand number and 
;; reorder copies for the given line-item
;; example:
;; (enough-copies-after-reorder?-helper 100 100 LINE-ITEM1)= true
;; strategy: structural decomposition on li [LineItem]
(define (enough-copies-after-reorder?-helper on-hand copies li)
     (>= (+ on-hand copies) (line-item-quantity li)))

;; days-til-fillable : Order Inventory -> Number
;; Given an order and an inventory, the function decide how many days
;; are there beofre the order can be filled. 
;; example: (days-til-fillable-helper ORDER-FILLABLE-LATER INVENTORY )=22
;; strategy: structural decomposition on order [Order]
;(define (days-til-fillable-helper order inventory)
;    (cond 
;        [(empty? order) 0]
;        [else (max
;               (days-til-line-item-fillable inventory (first order))
;               (days-til-fillable-helper (rest order) inventory))]))
;; strategy: higher order function composition
(define (days-til-fillable-helper order inventory)
     (local (;; get-days-for-line-item : LineItem->Number
             ;; for a given LineItem, get the number of days left
             ;; until it is fillable for the Inventory from upper function
             (define (get-days-for-line-item li)
                  (days-til-line-item-fillable inventory li)))
       (foldr max 0 (map get-days-for-line-item order))))

;; days-til-line-item-fillable : Inventory LineItem -> Number
;; Takes an inventory and a line item and returns a Number to indicate 
;; how many days left until the order can be filled
;; example:(days-til-line-item-fillable INVENTORY LINE-ITEM4)=22
;; strategy: structural decomposition on inventory [Inventory]
;(define (days-til-line-item-fillable inventory li)
;    (cond 
;        [(empty? inventory) 0]
;        [else (+
;                 (days-til-line-item-fillable-helper (first inventory) li)
;                 (days-til-line-item-fillable (rest inventory) li))]))
;; strategy: higher order function composition
(define (days-til-line-item-fillable inventory li)
     (local (;; get-days-for-book : Book->Number
             ;; for a given Book, get the number of days left
             ;; if it matches the line-item
             (define (get-days-for-book book)
                  (days-til-line-item-fillable-helper book li)))
       (foldr + 0 (map get-days-for-book inventory))))

;; days-til-line-item-fillable-helper : Book LineItem -> Boolean
;; this function is used to decide whether the order can be filled now or later
;; example: (days-til-line-item-fillable-helper book4 LINE-ITEM4)=22
;; strategy: function composition
(define (days-til-line-item-fillable-helper book li)
    (if (line-item-match? book li)    
       (get-days-left book li)
       0))

;; get-days-left: Book LineItem -> Boolean
;; if there are enough copies of books on hand returns 0
;; if not, and if the order can be filled later, return the reorder-days-left.
;; example,(get-days-left book4 LINE-ITEM4)=22
;; strategy: structural decomposition on book [Book]
(define (get-days-left book li)
    (if (enough-copies-on-hand? (book-isbn book)(book-on-hand book) li)
        0
        (days-after-reorder (book-reorder-status book))))

;; days-after-reorder : ReorderStatus -> Number
;; return the days left until the reorder is delivered
;; example: (days-after-reorder (make-reorder 0 500)) 0
;; strategy: structural decomposition on status [ReorderStatus]
(define (days-after-reorder status)
    (reorder-days-left status))

;; Tests for normal inventory and empty one
(define (days-til-fillable-check in1 in2 out)
  (check-equal? 
   (days-til-fillable in1 in2) out
   (format "(days-til-fillable-check ~a ~a) should be ~a" in1 in2 out)))
(define-test-suite days-til-fillable-tests
  ;;for order can be filled now, return a 0. means can be filled today
    (days-til-fillable-check ORDER-FILLABLE-NOW INVENTORY 0)
  ;;for order cannot be filled now, 
  ;; if can be filled later after re-order, return the max days
    (days-til-fillable-check ORDER-FILLABLE-LATER INVENTORY 22)
  ;;for order cannot be filled now, 
  ;; if can be filled later today, return 0
    (days-til-fillable-check ORDER-FILLABLE-LATER-0 INVENTORY 0)
    ;;for order cannot be filled now, if any book doesn't exist, return false
    (days-til-fillable-check ORDER-NOT-FILLABLE-BOOK-NOT-EXIST INVENTORY false)
  ;;for order cannot be filled now, 
  ;; after re-order, still no enough copies
    (days-til-fillable-check ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH 
                             INVENTORY false)
   ;;for order cannot be filled now, 
  ;; there is no enough copies left and no re-order possible
    (days-til-fillable-check ORDER-NOT-FILLABLE-NO-COPIES-AND-REORDER 
                             INVENTORY false)
  ;; for empty order and empty inventory
    (days-til-fillable-check empty EMPTY-INVENTORY 0)
  ;; for empty inventory
    (days-til-fillable-check ORDER-FILLABLE-NOW EMPTY-INVENTORY false)
  ;; for empty order
  (days-til-fillable-check empty INVENTORY 0))
(run-tests days-til-fillable-tests)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; price-for-order : Inventory Order -> Number
;; return the total price for a given order. 
;; Even if the order cannot be filled now, the total price should still be 
;; calculated. For those are not in inventory, price is 0;
;; example:(price-for-order INVENTORY ORDER-FILLABLE-NOW)=500
;; strategy: structural decomposition on order [Order]
;(define (price-for-order inventory order)
;    (cond 
;        [(empty? order) 0]
;        [else (+
;               (get-price-for-line-item-helper (price-for-line-item inventory 
;                                               (first order)))
;               (price-for-order inventory (rest order)))]))

;; strategy: higher order function composition
(define (price-for-order inventory order)
    (local(;; price-for-li : LineItem -> Number
           ;; get price for the given line-item
           (define (price-for-li li)
             (get-price-for-line-item 
                  (price-for-line-item inventory li))))
    (foldr +  0 (map price-for-li order))))

;; get-price-for-line-item-helper : MaybeNumber- > Number
;; return a number based on the input, if input  a false return 0
;; else return the input
;; example:(get-price-for-line-item-helper 12) =12
;; strategy: structural decomposition on maybe-number [MaybeNumber]
(define (get-price-for-line-item maybe-number)
    (cond 
        [(number? maybe-number) maybe-number]
        [(false? maybe-number) 0]))

;; Tests for normal inventory and empty one
(define (price-for-order-check in1 in2 out)
  (check-equal? 
   (price-for-order in1 in2) out
   (format "(price-for-order-check ~a ~a) should be ~a" in1 in2 out)))
(define-test-suite price-for-order-tests
    ;; normal order
    (price-for-order-check INVENTORY ORDER-FILLABLE-NOW 2900)
    ;; order with item not in the inventory
    (price-for-order-check INVENTORY ORDER-NOT-FILLABLE-BOOK-NOT-EXIST 49500)
    ;; order with everything in inventory
    (price-for-order-check INVENTORY ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH 
                           53400)
    ;; empty inventory and order
    (price-for-order-check EMPTY-INVENTORY empty 0)
     ;; empty inventory
    (price-for-order-check EMPTY-INVENTORY ORDER-FILLABLE-NOW 0)
     ;; empty order
    (price-for-order-check INVENTORY empty 0))
(run-tests price-for-order-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; inventory-after-order : Inventory Order -> Inventory.
;; Given a Inventory that can be filled without reorder, return a new Inventory
;; after the order is filled
;; example: 
;; (inventory-after-order INVENTORY ORDER-FILLABLE-NOW) =INVENTORY-AFTER-ORDER
;; strategy: function composition
(define (inventory-after-order inventory order)
    (if (fillable-now? order inventory)
        (inventory-after-order-helper inventory order)
        inventory))
;; inventory-after-order-helper : Inventory Order -> Inventory
;; for each item in the order, if the item exist. Then, update the book
;; to lastest version and add it to the result inventory; Else if the item is
;; not ordered, return the original book directly
;; example:
;; (inventory-after-order-helper INVENTORY ORDER-FILLABLE-NOW)
;;  =INVENTORY-AFTER-ORDER
;; strategy: structural decomposition on order [Order]
;(define (inventory-after-order-helper inventory order)
;    (cond 
;        [(empty? order) inventory]
;        [else (update-inevntory
;                  (first order)
;                  (inventory-after-order-helper inventory (rest order)))]))
;; strategy: higher order function composition
(define (inventory-after-order-helper inventory order)
    (foldr update-inevntory inventory order))
;; update-inevntory : LineItem Inventory -> Inventory
;; for each item in the inventory, if the LineItem is ordered. Then, 
;; update the item to lastest version and add it to the result inventory;
;; example:
;; (update-inevntory LINE-ITWM1 INVENTORY)
;;  =BOOK1-UPDATED
;; strategy: structural decomposition on inventory [Inventory]
;(define (update-inevntory  li inventory)
;    (cond 
;        [(empty? inventory) empty]
;        [else (cons
;                  (update-book-after-order-helper li (first inventory))
;                  (update-inevntory li (rest inventory)))]))

;; strategy: higher order function composition
(define (update-inevntory  li inventory)
     (map;; lambda : Book -> Book
             ;; help map using update-book
             ;; which means using another helper function (update-book) to 
             ;; compare line-item and book and update book
             (lambda (book) (update-book li book))
            inventory))

;; update-book-after-order-helper Book LineItem : Book
;; update the book info after order (on-hand value)
;; example: (update-book-after-order-helper BOOK7 LINE-ITEM7)=BOOK7-AFTER-ORDER
;; strategy : structural decomposition on book [Book]
(define (update-book  li book)
  (if (line-item-match? book li) 
     (make-book 
           (book-isbn book)
           (book-title book)
           (book-author book)
           (book-publisher book)
           (book-unit-price book)
           (book-unit-cost book)
           (update-book-on-hand (book-on-hand book) li)
           (book-reorder-status book)
           (book-cuft book))
     book))

;; update-book-on-hand Number LineItem -> Number
;; simply update the on hand value of book
;; exmaple: (update-book-on-hand 50 LINE-ITEM7) 10
;; stategy : structural decomposition on li [LineItem]
(define (update-book-on-hand on-hand li)
    (- on-hand (line-item-quantity li)))

;; Tests for normal inventory and empty one
(define (inventory-after-order-check in1 in2 out)
  (check-equal? 
   (inventory-after-order in1 in2) out
   (format "(inventory-after-order-check ~a ~a) should be ~a" in1 in2 out)))
(define-test-suite inventory-after-order-tests
  ;; for order that can be filled now
    (inventory-after-order-check INVENTORY ORDER-FILLABLE-NOW 
                                 INVENTORY-AFTER-ORDER)
  ;; for order that cannot be filled now
    (inventory-after-order-check INVENTORY ORDER-NOT-FILLABLE-BOOK-NOT-EXIST 
                                 INVENTORY)
  ;; for empty order and inventory
    (inventory-after-order-check EMPTY-INVENTORY empty EMPTY-INVENTORY)
   ;; for empty inventory
    (inventory-after-order-check EMPTY-INVENTORY ORDER-FILLABLE-NOW 
                                 EMPTY-INVENTORY)
   ;; for empty order
    (inventory-after-order-check INVENTORY empty 
                                 INVENTORY))
(run-tests inventory-after-order-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; increase-prices : Inventory String Number -> Inventory
;; Given a Inventory, a String represents pushlisher's name and a Number
;; represents the percentage which indicate the unit-price increased by the 
;; number. The result is a new Inventory, where all book made by the given
;; publishers are updated
;; example:
;; (increase-prices INVENTORY 10 "Addison-Wesley")=INVENTORY-PRICE-INCREASED
;; strategy: structural decomposition on inventory [Inventory]
(define (increase-prices inventory percentage publisher)
    (cond 
        [(empty? inventory) empty]
        [else (cons
               (update-book-price (first inventory) percentage publisher)
               (increase-prices (rest inventory) percentage publisher))]))

;; update-book-price : Book String Number -> Inventory
;; check whether the given book is published by the publisher. if so
;; return a new Book with the new price, else retrun the given book
;; example:(update-book-price BOOK2 10 "Addison-Wesley")=BOOK2-PRICE-INCREASED
;; strategy : function composition
(define (update-book-price book percentage publisher)
    (if (same-publisher? book publisher)
        (update-book-price-helper book percentage)
        book))

;; same-publisher?: Book String -> Boolean
;; this is a helper function which checks whether the given book is
;; published by the given publisher. If so return true,
;; else return false;
;; exmaple:(same-publisher? BOOK2 "Addison-Wesley")=true
;; strategy; structural decomposition on book [Book]
(define (same-publisher? book publisher)
    (string=? (book-publisher book) publisher))

;; update-book-price-helper Book Number : Book
;; update the book price after order
;; example: (update-book-price-helper BOOK2 10)=BOOK2-PRICE-INCREASED
;; strategy : structural decomposition on book [Book]
(define (update-book-price-helper book percentage)
     (make-book 
           (book-isbn book)
           (book-title book)
           (book-author book)
           (book-publisher book)
           (* (book-unit-price book) (+ 1 (/ percentage 100)))
           (book-unit-cost book)
           (book-on-hand book)
           (book-reorder-status book)
           (book-cuft book)))

;; Tests for normal inventory and empty one
(define (increase-prices-check in1 in2 in3 out)
  (check-equal? (increase-prices in1 in2 in3) out
                (format "(increase-prices-check ~a ~a ~a) should be ~a" 
                        in1 in2 in3 out)))
(define-test-suite increase-prices-tests
    (increase-prices-check INVENTORY 10 "Addison-Wesley" 
                           INVENTORY-PRICE-INCREASED)
    (increase-prices-check INVENTORY -10 "Addison-Wesley" 
                           INVENTORY-PRICE-DECREASED)
    (increase-prices-check INVENTORY 0 "Addison-Wesley" INVENTORY)
    (increase-prices-check INVENTORY 10 "MIT press" INVENTORY)
    (increase-prices-check EMPTY-INVENTORY 0 "Addison-Wesley" EMPTY-INVENTORY)
    (increase-prices-check EMPTY-INVENTORY 10 "MIT press" EMPTY-INVENTORY))
(run-tests increase-prices-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; daily-update : Inventory -> Inventory
;; update current inventory for next day which means finish all reorders
;; that supposed to delivered today. After the order received, the outstanding
;; order is no longer exists;
;; examples: (daily-update INVENTORY )= INVENTORY-UPDATED-TODAY
;; strateyg: structural decomposition on inventory [Inventory]
;(define (daily-update inventory)
;    (cond 
;        [(empty? inventory) empty]
;        [else (cons
;               (daily-update-book (first inventory))
;               (daily-update (rest inventory)))]))
(define (daily-update inventory)
     (map daily-update-book inventory))
;; daily-update-book: Book -> Book
;; update the book information if the there is a reorder finish today
;; else return the same Book
;; examples: (daily-update-book BOOK2 )= BOOK2-UPDATED-TODAY
;; STRATEGY :structural decomposition on book [Book]
(define (daily-update-book book)
    (if (book-update-today? book)
        (daily-update-book-helper book)
        (if (book-update-later? book)
            (book-update-later-helper book)
            book)))

;; book-update-today? Book -> Boolean
;; return whether the book can be updated today by checking whther ther are 
;; 0 days left fot reorder
;; example:(daily-update-book BOOK2 )= true
;; strategy: structural decomposition on book [Book]
(define (book-update-today? book)
    (reorder-now? (book-reorder-status book)))

;; book-update-later? Book -> Boolean
;; return whether the book can be updated later by checking whther ther are 
;; more than 0 days left fot reorder
;; example:(book-update-later? BOOK2 )= false
;; strategy: structural decomposition on book [Book]
(define (book-update-later? book)
    (reorder-later? (book-reorder-status book)))

;; reorder-later? ReOrderState -> Boolean
;; checking whther ther are more than 0 days left fot reorder
;; if so, return true;
;; if not, return false
;; example: 
;; (reorder-later? (make-reorder 1 23)) = true
;; (reorder-later? false) = false
;; strategy:structural decomposition on status [ReorderStatus]
(define (reorder-later? status)
     (cond 
        [(reorder? status) (< 0 (reorder-days-left status))]
        [(false? status) false]))
;; reorder-now? ReOrderState -> Boolean
;; checking whther ther are 0 days left fot reorder
;; if so, return true;
;; if not, return false
;; example: 
;; (reorder-now? (make-reorder 0 23)) = true
;; (reorder-now? false) = false
;; strategy: structural decomposition on status [ReorderStatus]
(define (reorder-now? status)
     (cond 
        [(reorder? status) (= 0 (reorder-days-left status))]
        [(false? status) false]))


;; daily-update-book-helper: Book -> Book
;; update the book. Two things involved:
;; 1 update the current on-hand copies number
;; 2 change ReorderStatus to false
;; example:(daily-update-book-helper BOOK2 )= BOOK2-UPDATED-TODAY
;; strategy : structural decomposition on book [Book]
(define (daily-update-book-helper book)
     (make-book 
           (book-isbn book)
           (book-title book)
           (book-author book)
           (book-publisher book)
           (book-unit-price book)
           (book-unit-cost book)
           (update-on-hand (book-on-hand book) (book-reorder-status book))
           (empty-reorder 1)
           (book-cuft book)))

;; update-on-hand : Number ReorderStatus -> Number
;; with the given on-hand copies, add the expected delivered copies
;; example:(update-on-hand 10 (make-reorder 0 50)) 60
;; strategy: function composition
(define (update-on-hand on-hand status)
     (+ on-hand (reorder-copies status)))

;; book-update-later-helper Book -> Book
;; iff there is a re-order for the book, for several days later
;; minus the days-left in the status by 1
;; example:(daily-update-book-helper BOOK1 )= BOOK1-UPDATED-TODAY
;; strategy : structural decomposition on book [Book]
(define (book-update-later-helper book)
     (make-book 
           (book-isbn book)
           (book-title book)
           (book-author book)
           (book-publisher book)
           (book-unit-price book)
           (book-unit-cost book)
           (book-on-hand book)
           (minus-reorder-days (book-reorder-status book))
           (book-cuft book)))
;; minus-reorder-days ReorderStatus -> ReorderStatus
;;minus the days-left in the status by 1
;; example:(minus-reorder-days (make-reorder 10 10))
;; =(make-reorder 9 10)
;; strategy: structural decomposition on status [ReorderStatus]
(define (minus-reorder-days status)
   (make-reorder (- (reorder-days-left status) 1) 
                 (reorder-copies status)))

;; Tests for normal inventory and empty one
(define (daily-update-check in1 out)
  (check-equal? (daily-update in1) out
                (format "(daily-update-check ~a) should be ~a" in1 out)))
(define-test-suite daily-update-tests
  ;;;;;;;;;;;;;;;order tofsy+later+no oerder
  ;; this case include:
  ;; 1: update all line-item which have re-order due today (book 2 5 7)
  ;; 2: update line-item which have re-order due later (book 1 3 4)
  ;; 3: ignore all other line-item which do not have a re-order(6)
    (daily-update-check INVENTORY INVENTORY-UPDATED-TODAY)
  ;; check empty inventory and empty order
    (daily-update-check EMPTY-INVENTORY EMPTY-INVENTORY))
(run-tests daily-update-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reorder-present? : ReorderStatus -> Boolean
;; Returns true iff the given ReorderStatus shows a pending re-order.
;; example: (reorder-present? false)=false
;; strategy: structural decomposition on status [ReorderStatus]
(define (reorder-present? status)
     (cond 
        [(reorder? status) true]
        [(false? status) false]))
(define (reorder-present?-check in1 out)
  (check-equal? (reorder-present? in1) out
                (format "(reorder-present? ~a) should be ~a" in1 out)))
(define-test-suite reorder-present?-tests
  ;;;;;;;;;;;;;;;order tofsy+later+no oerder
  ;; this case include:
  ;; 1: update all line-item which have re-order due today (book 2 5 7)
  ;; 2: update line-item which have re-order due later (book 1 3 4)
  ;; 3: ignore all other line-item which do not have a re-order(6)
    (reorder-present?-check false false)
  ;; check empty inventory and empty order
    (reorder-present?-check (make-reorder 1 5) true))
(run-tests reorder-present?-tests)
