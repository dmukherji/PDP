;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname balls-in-box) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Problem Set 03, Question 2, Programming Design Principles S14
;; Northeastern University Boston Campus
;; Author: Dev Mukherji

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/image)
(require 2htdp/universe)
(require "extras.rkt")

;; =============================== CONSTANTS ===================================
;; Canvas constants:
(define CANVAS-HEIGHT 300)
(define CANVAS-WIDTH 400)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define CANVAS-CENTER (make-posn (/ CANVAS-WIDTH 2) (/ CANVAS-HEIGHT 2)))
;; Circle constants:
(define CIRCLE-RADIUS 20)
(define CIRCLE-COLOR "red")
(define CIRCLE-SELECTED "solid")
(define CIRCLE-DESELECTED "outline")
;; =============================================================================

;; ========================== DATA DEFINITIONS =================================
;; A Ball is a (make-struct Integer Integer)
(define-struct ball (xco yco selected?))
;; INTERPRETATION:
;; xco is the x-coordinate of the center of the ball in pixels
;; yco is the y-coordinate of the center of the ball in pixels
;; selected? indicates whether the ball is selected or not
;; TEMPLATE:
;; (define (ball-fn bouncer)
;;   (...
;;    (ball-xco bouncer)
;;    (ball-yco bouncer)))

;; A ListOf<Balls> is one of:
;; -- empty
;; -- (cons ball ListOf<Balls>)
;; INTERPRETATION:
;; empty means that there are no balls in the list
;; otherwise, it's a sequence made by a ball and another sequence of balls
;; TEMPLATE:
;; lob-fn : ListOf<Balls> -> ?
;; (define (lob-fn lob)
;;    (cond
;;        [(empty? lob) ...]
;;        [else ... (first lob)
;;              (lob-fn (rest lob))]))

;; A World is (make-world ListOf<Balls> Number)
(define-struct world (list count))
;; INTERPRETATION:
;; list is a ListOf<Balls> which appears in the world
;; count is the total number of balls present in the world
;; TEMPLATE:
;; world-fn : World -> ?
;; (define (world-fn w)
;;    (...
;;    (world-list w)
;;    (world-count w)))

;; A BallMouseEvent is a MouseEvent that is one of:
;; -- "button-down"   (interp: select the ball)
;; -- "drag"          (interp: maybe drag the ball)
;; -- "button-up"     (interp: deselect the rectangle)
;; -- any other mouse event (interp: ignored)
;; TEMPLATE:
;; mev-fn: BallMouseEvent -> ?
;; (define (mev-fn mev)
;;   (cond
;;     [(mouse=? mev "button-down") ...]
;;     [(mouse=? mev "drag") ...]
;;     [(mouse=? mev "button-up") ...]
;;     [else ...]))

;; A BallKeyEvent is a KeyEvent, which is one of
;; -- "n"                (interp: create a new ball at the center of the canvas)
;; -- "d"                (interp: delete a selected ball from the canvas)
;; -- any other KeyEvent (interp: ignore)
;; TEMPLATE:
;; kev-fn: BallKeyEvent -> ?
;; (define (falling-cat-kev-fn kev)
;;   (cond 
;;     [(key=? kev "n") ...]
;;     [(key=? kev "d") ...]
;;     [else ...]))
;; =============================================================================

;; ================================ FUNCTIONS ==================================
;; run : Any -> World
;; GIVEN: An argument, which is ignored.
;; RETURNS: the final state of the world.
(define (run n)
  (big-bang (initial-world n)
  (on-mouse world-after-mouse-event)
  (on-key world-after-key-event)
  (on-draw world-to-scene)))

;; initial-world : Any -> World
;; GIVEN: An argument, which is ignored.
;; RETURNS: a world with no balls.
(define (initial-world n)
   (make-world empty 0))

;; world-after-key-event: World BallKeyEvent -> World
;; GIVEN: a World and a BallKeyEvent
;; RETURNS: the world that follows the given world after the given key event.
(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n") 