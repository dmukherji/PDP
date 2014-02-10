;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname inventory) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Problem Set 03, Question 1, Programming Design Principles S14
;; Northeastern University Boston Campus
;; Author: Dev Mukherji

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/image)
(require "extras.rkt")

(provide
 inventory-potential-profit
 inventory-total-volume
 price-for-line-item
 fillable-now?
 days-til-fillable
 price-for-order
 inventory-after-order
 increase-prices
 make-book
 make-line-item
 reorder-present?
 make-empty-reorder
 make-reorder)

;; ============================= DATA DEFINITIONS ==============================
;; A Reorder is a (make-reorder Boolean NonnegInt NonnegInt)
(define-struct reorder (expectedarrival quantity))
;; INTERPRETATION:
;; expectedarrival shows the number of days until the next shipment of the given
;; book is expected to arrive
;; quantity means the number of books ordered in the reorder
;; TEMPLATE:
;; reorder-fn : ReOrder -> ??
;; (define (reorder-fn reorder)
;;    (...
;;     (reorder-expectedarrival reorder)
;;     (reorder-quantity reorder)))

;; A ReorderStatus is one of:
;; ---Reorder
;; ---false
;; INTERPRETATION:
;; If there is actually a reorder, the status of reorder is set to a Reorder,
;; which describe the days left before shipment of the order and the number of
;; copies ordered 
;; else if there is no reorder yet, a Boolean value "false" is placed
;; TEMPLATE:
;; reorder-status-fn : ReorderStatus -> ??
;; (define (reorder-status-fn reorderstat)
;;    (cond
;;        [(reorder? reorderstat) ...]
;;        [(false? reorderstat) ...]))

;; A Book is a (make-book Number String String String Number Number 
;; Number String Number)
(define-struct book (isbn title author publisher unitprice unitcost 
                               numcopies reorder-stat volume))
;; INTERPRETATION:
;; isbn is a unique identifier for the book's International Standard Book Number
;; title represents the name of the book
;; author represents the person who wrote the book
;; publisher is the company that published the book
;; unitprice represents the price at which the book is sold 
;; unitcost is the amount of money the bookstore spent in purchasing the book
;; numcopies represents the number of books that the bookstore has in stock
;; reorder-stat is a ReorderDtatus which represents whether there is a 
;; outstanding reorder:
;; -- if there is a reorder, the status will show the number of days until the 
;; -- next shipment of the given book and the number of copies of books ordered
;; -- if there is no reorder, the status will show false
;; volume is the occupied space of the book in cubic feet
;; TEMPLATE:
;; book-fn : Book -> ??
;; (define (book-fn book)
;;   (...
;;    (book-isbn book)
;;    (book-title book)
;;    (book-author book)
;;    (book-publisher book)
;;    (book-unitprice book)
;;    (book-unitcost book)
;;    (book-numcompies book)
;;    (book-reorder-stat book)
;;    (book-volume book)))

;; A MaybeInteger is one of:
;; -- Integer (interpretation: the returned value is an Integer)
;; -- false (interpretation: the returned value is false)
;; TEMPLATE:
;; maybeinteger-fn : MaybeInteger -> ?
;; (define (maybeinteger-fn m)
;;    (cond 
;;        [(integer? m) ...]
;;        [(false? m) ...]))

;; A MaybeNumber is one of:
;; -- Number (interpretation: the returned value is a Number)
;; -- false (interpretation: the returned value is false)
;; TEMPLATE:
;; maybenumber-fn : MaybeNumber -> ?
;; (define (maybenumber-fn m)
;;    (cond 
;;        [(number? m) ...]
;;        [(false? m) ...]))

;; A Inventory is a ListOf<Book> which is one of 
;; -- empty
;; -- (cons book ListOf<Book>)
;; INTERPRETATION:
;; empty means that there are no books in the list
;; it's a sequence made by a book and another sequence of books
;; TEMPLATE:
;; lob-fn : ListOf<Book> -> ?
;; (define (lob-fn lob)
;;     (cond 
;;         [(empty? lob) ...]
;;         [else (... (first lob)
;;                    (lob-fn (rest lob)))]))

;; An LineItem is (make-line-item Number Number)
(define-struct line-item (isbn quantity))
;; INTERPRETATION:
;; isbn is a unique identifier for the book's International Standard Book Number
;; quantity represents the number of given book in ordered
;; TEMPLATE:
;; line-item-fn : LineItem -> ?
;; (define (line-item-fn line-item)
;;     (...
;;      (line-item-isbn line-item)
;;      (line-item-quantity line-item)))

;; An Order is a ListOf<LineItem> which is either 
;; -- empty
;; -- (cons LineItem ListOf<LineItem>)
;; INTERPRETATION:
;; empty means there are no LineItem in the list
;; a sequence made by a LineItem and another sequence of LineItems
;; TEMPLATE:
;; order-fn : ListOf<LineItem> -> ?
;; (define (order-fn lob)
;;     (cond 
;;         [(empty? lob) ...]
;;         [else (... (first lob)
;;                    (loli-fn (rest lob)))]))
;; =============================================================================

;; =========================== TEST CONSTANTS ==================================
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
;; =============================================================================

;; ============================= FUNCTIONS =====================================
;; inventory-potential-profit : Inventory ->  Number
;; GIVEN: an inventory
;; RETURNS: the total profit for all the items in stock (i.e., how much
;; the bookstore would profit if it sold every book in the inventory)
(define (inventory-potential-profit inventory)
  (cond
    [(empty? inventory) 0]
    [(cons? inventory) (+ (book-profit (first inventory))
                          (inventory-potential-profit (rest inventory)))]))

(define (book-profit book)
  (* (book-numcopies book) (- (book-unitprice book) (book-unitcost book))))
;; TESTS:
(define-test-suite inventory-potential-profit-tests
    (check-equal? (inventory-potential-profit INVENTORY) 18550
                  "The potential profit 1 is wrong")
    (check-equal? (inventory-potential-profit EMPTY-INVENTORY) 0
                  "The potential profit 2 is wrong"))

;; ======================
;; inventory-total-volume: Inventory -> Number
;; GIVEN: an inventory
;; RETURNS: the total volume needed to store all the books in stock.
(define (inventory-total-volume inventory)
  (cond
    [(empty? inventory) 0]
    [(cons? inventory) (+ (book-vol (first inventory))
                          (inventory-total-volume (rest inventory)))]))
;; TESTS:
(define-test-suite inventory-total-volume-tests
  (check-equal? (inventory-total-volume INVENTORY) 4790
                "Inventory total volume 1 is wrong")
  (check-equal? (inventory-total-volume EMPTY-INVENTORY) 0
                "Inventory total volume 2 is wrong"))

(define (book-vol singlebook)
  (* (book-numcopies singlebook) (book-volume singlebook)))

;; ======================
;; price-for-line-item : Inventory LineItem -> MaybeNumber
;; GIVEN: an inventory and a line item
;; RETURNS: the price for that line item (the quantity times the unit
;; price for that item).  Returns false if that isbn does not exist in
;; the inventory. 
(define (price-for-line-item inventory lineitem)
  (cond
    [(empty? inventory) false]
    [(cons? inventory) (if (isbn-is-same? (first inventory) lineitem)
                           (itemprice (first inventory) lineitem)
                       (price-for-line-item (rest inventory) lineitem))]))
;; TESTS:
(define-test-suite price-for-line-item-tests
  (check-equal? (price-for-line-item INVENTORY LINE-ITEM1) 500
                "Price for line item 1 is wrong")
  (check-equal? (price-for-line-item INVENTORY LINE-ITEM8) false
                "Price for line item 2 is wrong")
  (check-equal? (price-for-line-item EMPTY-INVENTORY LINE-ITEM1) false
                "Price for line item 3 is wrong")
  (check-equal? (price-for-line-item EMPTY-INVENTORY LINE-ITEM8) false
                "Price for line item 4 is wrong"))

(define (isbn-is-same? book lineitem)
  (= (book-isbn book) (lineitem-isbn lineitem)))

(define (lineitem-isbn lineitem)
  (line-item-isbn lineitem))

(define (itemprice singlebook lineitem)
  (* (line-item-quantity lineitem) (bookprice singlebook)))

(define (bookprice singlebook)
  (book-unitprice singlebook))

;; fillable-now? : Order Inventory -> Boolean.
;; GIVEN: an order and an inventory
;; RETURNS: true iff there are enough copies of each book on hand to fill
;; the order.  If the order contains a book that is not in the inventory,
;; then the order is not fillable.
(define (fillable-now? order inventory)
  (cond
    [(empty? order) true]
    [(cons? order) (and (lineitem-fillable-now? (first order) inventory)
                            (fillable-now? (rest order) inventory))]))
;; TESTS:
(define-test-suite fillable-now?-tests
  (check-equal? (fillable-now? ORDER-FILLABLE-NOW INVENTORY) true
                               "Fillable-now? 1")
  (check-equal? (fillable-now? ORDER-FILLABLE-LATER INVENTORY) false
                               "Fillable-now? 2")
  (check-equal? 
   (fillable-now? ORDER-NOT-FILLABLE-BOOK-NOT-EXIST INVENTORY) false
                               "Fillable-now? 3")
  (check-equal? (fillable-now? ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH INVENTORY) 
                false "Fillable-now? 4")
  (check-equal? 
   (fillable-now? ORDER-NOT-FILLABLE-NO-COPIES-AND-REORDER  INVENTORY) false
                               "Fillable-now? 5")
  (check-equal? (fillable-now? empty EMPTY-INVENTORY) true
                               "Fillable-now? 6")
  (check-equal? (fillable-now? ORDER-FILLABLE-NOW EMPTY-INVENTORY) false
                               "Fillable-now? 7")
  (check-equal? (fillable-now? empty EMPTY-INVENTORY) true
                               "Fillable-now? 8"))

(define (lineitem-fillable-now? lineitem inventory)
  (cond
    [(empty? inventory) false]
    [(cons? inventory) (or (order-can-happen? (first inventory) lineitem)
                   (lineitem-fillable-now? lineitem (rest inventory)))]))

(define (order-can-happen? singlebook lineitem)
  (and (isbn-is-same? singlebook lineitem)
       (>= (book-numcopies singlebook) (lineitem-count lineitem))))

(define (lineitem-count lineitem)
  (line-item-quantity lineitem))

;; days-til-fillable : Order Inventory -> MaybeInteger
;; GIVEN: an order and an inventory
;; RETURNS: the number of days until the order is fillable, assuming all
;; the shipments come in on time.  Returns false if there won't be enough
;; copies of some book, even after the next shipment of that book comes in.
(define (days-til-fillable order inventory)
  (if (order-fillable? order inventory)
      (days-til-fillable-helper order inventory)
      false))
;; TESTS:
(define-test-suite days-til-fillable-tests
  (check-equal? (days-til-fillable ORDER-FILLABLE-NOW INVENTORY) 0
                "Days till fillable 1")
  (check-equal? (days-til-fillable ORDER-FILLABLE-LATER INVENTORY) 22
                "Days till fillable 2")
  (check-equal? (days-til-fillable ORDER-FILLABLE-LATER-0 INVENTORY) 0
                "Days till fillable 3")
  (check-equal? (days-til-fillable ORDER-NOT-FILLABLE-BOOK-NOT-EXIST INVENTORY)
                false "Days till fillable 4")
  (check-equal? (days-til-fillable ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH 
                             INVENTORY) false "Days till fillable 5")
  (check-equal? (days-til-fillable ORDER-NOT-FILLABLE-NO-COPIES-AND-REORDER 
                             INVENTORY) false "Days till fillable 6")
  (check-equal? (days-til-fillable empty EMPTY-INVENTORY) 0 
                "Days till fillable 7")
  (check-equal? (days-til-fillable ORDER-FILLABLE-NOW EMPTY-INVENTORY) false
                "Days till fillable 8")
  (check-equal? (days-til-fillable empty INVENTORY) 0 "Days till fillable 9"))


(define (order-fillable? order inventory)
  (cond 
    [(empty? order) true]
    [else (and (line-item-fillable? (first order) inventory)
               (order-fillable? (rest order) inventory))]))

(define (line-item-fillable? lineitem inventory)
  (cond
    [(empty? inventory) false]
    [else (or (enough-copies-now-or-after-reorder?  lineitem (first inventory))
              (line-item-fillable? lineitem (rest inventory)))]))

(define (enough-copies-now-or-after-reorder? lineitem singlebook)
     (or (order-can-happen? singlebook lineitem)
             (enough-copies-after-reorder? lineitem singlebook)))

(define (enough-copies-after-reorder? lineitem singlebook)
    (cond
        [(reorder-present-helper? singlebook) 
         (enough-copies-after-reorder?-helper lineitem singlebook)]
        [(false? (book-reorder-stat singlebook)) false]))

(define (reorder-present-helper? singlebook)
  (reorder-present? (book-reorder-stat singlebook)))

(define (reorder-present? stat)
  (reorder? stat))

(define (enough-copies-after-reorder?-helper lineitem singlebook)
     (>= (+ (book-numcopies singlebook) 
            (reorder-count (book-reorder-stat singlebook))) 
         (lineitem-count lineitem)))

(define (reorder-count bookreorder)
  (reorder-quantity bookreorder))

(define (days-til-fillable-helper order inventory)
  (cond
    [(empty? order) 0]
    [else (max (days-til-line-item-fillable inventory (first order))
               (days-til-fillable-helper (rest order) inventory))]))

(define (days-til-line-item-fillable inventory li)
  (cond 
    [(empty? inventory) 0] 
    [else (+ (days-til-line-item-fillable-helper (first inventory) li)
             (days-til-line-item-fillable (rest inventory) li))]))

(define (days-til-line-item-fillable-helper book li)
    (if (isbn-is-same? book li)    
       (get-days-left book li)
       0))

(define (get-days-left book li)
    (if (order-can-happen? book li)
        0
        (days-after-reorder (book-reorder-stat book))))

(define (days-after-reorder status)
    (reorder-expectedarrival status))

;; price-for-order : Inventory Order -> Number
;; GIVEN: An inventory and an Order
;; RETURNS: the total price for the given order. The price does not
;; depend on whether any particular line item is in stock. Line items
;; for an ISBN that is not in the inventory count as 0.
(define (price-for-order inventory order)
  (cond
    [(empty? order) 0]
    [(cons? order) (+ (price-for-item inventory (first order)) 
                      (price-for-order inventory (rest order)))]))
;; TESTS:
(define-test-suite price-for-order-tests
  (check-equal? (price-for-order INVENTORY ORDER-FILLABLE-NOW) 2900
                "Price for order 1")
  (check-equal? (price-for-order INVENTORY ORDER-NOT-FILLABLE-BOOK-NOT-EXIST) 
                49500 "Price for order 2")
  (check-equal? (price-for-order INVENTORY 
                                 ORDER-NOT-FILLABLE-REORDER-NOT-ENOUGH) 
                53400 "Price for order 3")
  (check-equal? (price-for-order EMPTY-INVENTORY empty) 0 "Price for order 4")
  (check-equal? (price-for-order EMPTY-INVENTORY ORDER-FILLABLE-NOW) 0
                "Price for order 5")
  (check-equal? (price-for-order INVENTORY empty) 0 "Price for order 6"))

(define (price-for-item inventory lineitem)
  (cond
    [(empty? inventory) 0]
    [(cons? inventory) (if (isbn-is-same? (first inventory) lineitem)
                           (itemprice (first inventory) lineitem)
                       (price-for-item (rest inventory) lineitem))]))

;; inventory-after-order : Inventory Order -> Inventory.
;; GIVEN: an inventory and an order
;; WHERE: the order is fillable now
;; RETURNS: the inventory after the order has been filled.
(define (inventory-after-order inventory order)
  (if (fillable-now? order inventory)
      (inventory-after-order-helper inventory order)
      inventory))
;; TEST:
(define-test-suite inventory-after-order-tests
  (check-equal? (inventory-after-order INVENTORY ORDER-FILLABLE-NOW)
                                 INVENTORY-AFTER-ORDER "Inventory after order 1")
  (check-equal? (inventory-after-order INVENTORY ORDER-NOT-FILLABLE-BOOK-NOT-EXIST)
                                 INVENTORY "Inventory after order 2")
  (check-equal? (inventory-after-order EMPTY-INVENTORY empty) EMPTY-INVENTORY
                "Inventory after order 3")
  (check-equal? (inventory-after-order EMPTY-INVENTORY ORDER-FILLABLE-NOW)
                                 EMPTY-INVENTORY "Inventory after order 4")
  (check-equal? (inventory-after-order INVENTORY empty) INVENTORY
                "Inventory after order 5"))


(define (inventory-after-order-helper inventory order)
  (cond
    [(empty? order) inventory]
    [(cons? order) (update-inventory (first order) (inventory-after-order-helper
                                     inventory (rest order)))]))

(define (update-inventory lineitem inventory)
    (cond 
        [(empty? inventory) empty]
        [else (cons
                  (update-book-after-order-helper lineitem (first inventory))
                  (update-inventory lineitem (rest inventory)))]))

(define (update-book-after-order-helper lineitem singlebook)
  (if (isbn-is-same? singlebook lineitem) 
     (make-book 
           (book-isbn singlebook)
           (book-title singlebook)
           (book-author singlebook)
           (book-publisher singlebook)
           (book-unitprice singlebook)
           (book-unitcost singlebook)
           (- (book-numcopies singlebook) (lineitem-count lineitem))
           (book-reorder-stat singlebook)
           (book-volume singlebook))
     singlebook))

;; increase-prices : Inventory String Number -> Inventory
;; GIVEN: an inventory, a publisher, and a percentage,
;; RETURNS: an inventory like the original, except that all items by that
;; publisher have their unit prices increased by the specified percentage.
(define (increase-prices inventory publisher percentage)
  (cond
    [(empty? inventory) empty]
    [(cons? inventory) (cons (updateprice 
                              (first inventory) publisher percentage)
                             (increase-prices (rest inventory) publisher 
                                              percentage))]))
;; TESTS:
(define-test-suite increase-prices-tests
  (check-equal? (increase-prices INVENTORY "Addison-Wesley" 10) 
                           INVENTORY-PRICE-INCREASED)
  (check-equal? (increase-prices INVENTORY "Addison-Wesley" -10) 
                           INVENTORY-PRICE-DECREASED)
  (check-equal? (increase-prices INVENTORY "Addison-Wesley" 0) INVENTORY)
  (check-equal? (increase-prices INVENTORY "MIT press" 10) INVENTORY)
  (check-equal? (increase-prices EMPTY-INVENTORY "Addison-Wesley" 0) EMPTY-INVENTORY)
  (check-equal? (increase-prices EMPTY-INVENTORY "MIT press" 10) EMPTY-INVENTORY))


(define (updateprice book publisher percentage)
    (if (publisher-is-same? book publisher)
        (update-book-price-helper book percentage)
        book))

(define (publisher-is-same? book publisher)
    (string=? (book-publisher book) publisher))

(define (update-book-price-helper book percentage)
     (make-book 
           (book-isbn book)
           (book-title book)
           (book-author book)
           (book-publisher book)
           (* (book-unitprice book) (+ 1 (/ percentage 100)))
           (book-unitcost book)
           (book-numcopies book)
           (book-reorder-stat book)
           (book-volume book)))

;; make-empty-reorder : Any -> ReorderStatus
;; GIVEN: An argument
;; RETURNS: a ReorderStatus showing no pending re-order. Ignores the argument.
(define (make-empty-reorder any)
  false)
;; TESTS:
(check-equal? (make-empty-reorder 5) false)

(run-tests inventory-potential-profit-tests)
(run-tests inventory-total-volume-tests)
(run-tests price-for-line-item-tests)
(run-tests fillable-now?-tests)
(run-tests days-til-fillable-tests)
(run-tests price-for-order-tests)
(run-tests inventory-after-order-tests)
(run-tests increase-prices-tests)
