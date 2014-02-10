;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |2|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(require 2htdp/universe)
(require 2htdp/image)

(provide initial-world)
(provide run)
(provide ball-to-center)
(provide world-to-balls)
(provide world-after-tick)
(provide world-after-key-event)
(provide world-after-mouse-event)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANT VARIABLES
(define SPEED 3)
(define RADIUS 20)
(define DIAMETER (* 2 RADIUS))
(define BALL (circle RADIUS "outline" "red"))
(define BALL-SELECTED (circle RADIUS "outline" "green"))
(define CANVAS-WIDTH 300)
(define CANVAS-HEIGHT 400)
(define BACKGROUND (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA DEFINITIONS

;; A Posn is (make-posn Number Number)
;; Interp:
;; x is the x-cood number for the position
;; y is the y-cood number for this position
;; template
;; posn-fn : Posn -> ?
;(define (posn-fn p)
;    ...
;    (posn-x p)
;    (posn-y p))

;; A Direction is either:
;; "left"  (intepr: ball goes left)
;; "right"  (intepr: ball goes right)
;; template 
;; dir-fn : Direction -> ?
;(define (dir-fn fir)
;    (cond
;        [(string=? dir "left") ...]
;        [(string=? dir "right") ...]))


;;A Ball is (make-ball Posn Posn Direction Boolean)
(define-struct ball (center cursor dir selected?))
;; Interp:
;; center is the central Position of the ball
;; cursor is the Posn of the mouse when the ball is selected
;; dir represents the moving Direction of the ball
;; selected? is a boolean value shows whether the ball is selected
;; template
;; ball-fn : Posn -> ?
;(define (ball-fn ball)
;    ...
;    (ball-center ball)
;    (ball-cursor ball)
;    (ball-dir ball)
;    (ball-selected? ball))

;; A ListOf<Ball> is :
;; empty
;; (cons ball ListOf<Ball>)
;; Interp:
;; empty means no balls in the list
;; or it's a sequence made by a ball and another sequence of balls

;; template 
;; lob-fn : ListOf<Ball> ->?
;(define (lob-fn lob)
;   (cond
;       [(empty? lob) ...]
;       [else ... (first lob)
;             (lob-fn (rest lob))]))


;; A World is (make-world ListOf<Balls> Number)
(define-struct world (list count))
;; Interp:
;; list represents a ListOf<Balls> which appears in the world
;; count is a Number represents the total number of balls 
;;template:
;; world-fn : World -> ?
;(define (world-fn w)
;   ...
;   (world-list w)
;   (world-count w))

;; A AddEvent is a KeyEvent that is one of:
;; "n" (interp: when click n, a new ball is added)
;; other key inputs (interp: all other keys are ignored)
;; template:
;; add-fn : KeyEvent -> ?
;(define (add-fn k)
;   (cond
;       [(string=? k "n") ...]
;       [else ...]))

;; A DragEvent is a MouseEvent that is one of:
;; -- "button-down"   (interp: maybe select the RECT)
;; -- "drag"          (interp: maybe drag the RECT)
;; -- "button-up"     (interp: unselect the RECT)
;; -- any other mouse event (interp: ignored)
;; template:
;; mev-fn : MouseEvent -> ?
;(define (mev-fn mev)
;  (cond
;    [(mouse=? mev "button-down") ...]
;    [(mouse=? mev "drag") ...]
;    [(mouse=? mev "button-up") ...]
;    [else ...]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define initial-cursor (make-posn 0 0))
(define INITIAL-MOUSE (make-posn 0 0))
;; ball1 at left-up corner
(define ball1 (make-ball (make-posn RADIUS RADIUS) 
                         (make-posn 0 0) "left" false))
(define ball1-next-tick (make-ball (make-posn RADIUS (* RADIUS 1))
                                   (make-posn 0 0) "right" false))
;; ball2 at left-middle corner
(define ball2 (make-ball (make-posn RADIUS (* RADIUS 3)) 
                         (make-posn 0 0) "left" false))
(define ball2-next-tick (make-ball 
                         (make-posn RADIUS (* RADIUS 3)) 
                         (make-posn 0 0) "right" false))

;; ball3 is selected;
;; and ball3 is at middle-middle
(define ball3 (make-ball (make-posn 150 (* RADIUS 5)) (make-posn 0 0) 
                         "right" true))
(define ball3-2 (make-ball (make-posn 150 (* RADIUS 5)) (make-posn 0 0) 
                           "right" false))
(define ball3-next-tick (make-ball (make-posn 150 (* RADIUS 5)) 
                                   (make-posn 0 0) "right" true))


(define ball4 (make-ball (make-posn 150 (* RADIUS 7)) (make-posn 0 0) 
                         "right" false))
(define ball4-next-tick (make-ball (make-posn (+ 150 SPEED) (* RADIUS 7)) 
                                   (make-posn 0 0) "right" false))
;; mouse down on ball
;; position of mouse is inside the ball
(define ball4-AFTER-MOUSE-DOWN (make-ball (make-posn 150 (* RADIUS 7)) 
                                          (make-posn 160 150) "right" true))

;; mouse down on ball
;; position of mouse is on the bound of the ball
(define ball5 (make-ball (make-posn 182 (* RADIUS 9)) (make-posn 0 0) 
                         "left" false))
(define ball5-next-tick (make-ball (make-posn (- 182 SPEED) (* RADIUS 9)) 
                                   (make-posn 0 0) "left" false))
;; mouse down on ball
;; position of mouse is on the bound of the ball
(define ball5-AFTER-MOUSE-DOWN (make-ball (make-posn 182 (* RADIUS 9)) 
                                          (make-posn 202 200) "left" true))

(define ball6 (make-ball (make-posn 150 (* RADIUS 11)) (make-posn 0 0) 
                         "right" false))
(define ball6-next-tick 
  (make-ball (make-posn (+ 150 SPEED) (* RADIUS 11)) 
             (make-posn 0 0) "right" false))
(define ball7 (make-ball (make-posn 278 (* RADIUS 13)) 
                         (make-posn 0 0) "right" false))
(define ball7-next-tick 
  (make-ball (make-posn 280
                        (* RADIUS 13))(make-posn 0 0)  "left" false))
(define ball8 (make-ball 
               (make-posn (- CANVAS-WIDTH RADIUS) 
                          (* RADIUS 15)) (make-posn 0 0) "right" false))
(define ball8-next-tick 
  (make-ball
       (make-posn (- CANVAS-WIDTH RADIUS) 
                  (* RADIUS 15)) (make-posn 0 0) "left" false))
(define ball9 (make-ball (make-posn 150 (* RADIUS 17)) 
                         (make-posn 0 0) "left" false))
(define ball9-next-tick (make-ball 
                         (make-posn (- 150 SPEED)  (* RADIUS 17)) 
                         (make-posn 0 0) "left" false))
(define ball10 (make-ball (make-posn 150 (* RADIUS 19)) (make-posn 0 0)
                          "right" false))
(define ball10-next-tick (make-ball 
                          (make-posn (+ 150 SPEED)  (* RADIUS 19))
                          (make-posn 0 0) "right" false))

;; ball1 at left-up corner
(define ball-left-up (make-ball (make-posn 20 20) (make-posn 0 0)
                                "left"  false))
(define ball-left-up-mouse-down-inside 
  (make-ball (make-posn 20 20)
        (make-posn 15 10) "left" true))
(define ball-left-up-mouse-down-boundary 
  (make-ball (make-posn 20 20) (make-posn 20 20) "left" true))
(define ball-left-up-drag-to-left 
  (make-ball (make-posn 20 20) (make-posn 15 5) "left" true))
(define ball-left-up-drag-to-up 
  (make-ball (make-posn 20 20) (make-posn 8 10) "left" true))
(define ball-left-up-drag-to-left-up 
  (make-ball (make-posn 20 20) (make-posn 1 1) "left" true))
;; ball2 at left-middle corner
(define ball-left-middle  
  (make-ball (make-posn 20 60) (make-posn 0 0) "left" false))
(define ball-left-middle-mouse-down-inside 
  (make-ball (make-posn 20 60) (make-posn 10 60) "left" true))
(define ball-left-middle-mouse-down-boundary 
  (make-ball (make-posn 20 60) (make-posn 0 60) "left" true))
(define ball-left-middle-mouse-down-drag-to-left 
  (make-ball (make-posn 20 60) (make-posn 5 60) "left" true))
;; ball at left-down corner
(define ball-left-down 
  (make-ball (make-posn 20 380) (make-posn 0 0) "left" false))
(define ball-left-down-mouse-down-inside
  (make-ball (make-posn 20 380) (make-posn 10 380) "left" true))
(define ball-left-down-mouse-down-boundary 
  (make-ball (make-posn 20 380) (make-posn 20 400) "left" true))
(define ball-left-down-mouse-drag-to-left-down 
  (make-ball (make-posn 20 380) (make-posn 1 399) "left" true))

;; ball1 at middle-up corner
(define ball-middle-up 
  (make-ball (make-posn 150 20) (make-posn 0 0) "left"  false))
(define ball-middle-up-mouse-down-inside 
  (make-ball (make-posn 150 20) (make-posn 160 30) "left" true))
(define ball-middle-up-mouse-down-boundary 
  (make-ball (make-posn 150 20) (make-posn 150 0) "left" true))
(define ball-middle-up-drag-up 
  (make-ball (make-posn 150 20) (make-posn 160 0) "left" true))
;; CLICK ON rhe boundary of middle-up and middle-middle
(define ball-middle-up-mouse-down-boundary-2
  (make-ball (make-posn 150 20) (make-posn 150 40) "left" true))
;; ball2 at middle-middle corner
(define ball-middle-middle  
  (make-ball (make-posn 150 60) (make-posn 0 0) "left" false))
(define ball-middle-middle-mouse-down-inside 
  (make-ball (make-posn 150 60) (make-posn 160 70) "left" true))
;; drag to 130, 350
(define ball-middle-middle-drag1 
  (make-ball (make-posn 120 340) (make-posn 130 350) "left" true))
(define ball-middle-middle-mouse-up-inside 
  (make-ball (make-posn 120 340) (make-posn 0 0) "left" false))
;; drag to 10, 395
(define ball-middle-middle-drag2 
  (make-ball (make-posn 20 380) (make-posn 0 400) "left" true))
(define ball-middle-middle-mouse-up 
  (make-ball (make-posn 20 380) (make-posn 0 0) "left" false))

(define ball-middle-middle-mouse-down-boundary 
  (make-ball (make-posn 150 60) (make-posn 150 40) "left" true))
(define ball-middle-middle2  
  (make-ball (make-posn 160 80) (make-posn 0 0) "right" false))
(define ball-middle-middle-mouse2-down-inside  
  (make-ball (make-posn 160 80) (make-posn 160 70) "right" true))
;; drag to 130, 350
(define ball-middle-middle2-drag1 
  (make-ball (make-posn 130 360) (make-posn 130 350) "right" true))
;; drag to 10, 395
(define ball-middle-middle2-drag2 
  (make-ball (make-posn 20 380) (make-posn 0 400) "right" true))
(define ball-middle-middle2-mouse-up 
  (make-ball (make-posn 20 380) (make-posn 0 0) "right" false))
;; for the third ball inside canvas
(define ball-middle-middle3-mouse-down-inside
  (make-ball (make-posn 140 50) (make-posn 160 70) "left" true))
(define ball-middle-middle3-drag1 
  (make-ball (make-posn 110 330) (make-posn 130 350) "left" true))
(define ball-middle-middle3-drag2 
  (make-ball (make-posn 20 380) (make-posn 0 400) "left" true))
;; ball at middle-down corner
(define ball-middle-down 
  (make-ball (make-posn 150 380) (make-posn 0 0) "left" false))
(define ball-middle-down-mouse-down-inside
  (make-ball (make-posn 150 380) (make-posn 160 370) "left" true))
(define ball-middle-down-mouse-down-boundary
  (make-ball (make-posn 150 380) (make-posn 150 400) "left" true))
(define ball-middle-down-drag-down
  (make-ball (make-posn 150 380) (make-posn 160 400) "left" true))


;; ball1 at right-up corner
(define ball-right-up 
  (make-ball (make-posn 280 20) (make-posn 0 0) "left"  false))
(define ball-right-up-mouse-down-inside 
  (make-ball (make-posn 280 20) (make-posn 280 10) "left" true))
(define ball-right-up-mouse-down-boundary 
  (make-ball (make-posn 280 20) (make-posn 280 0) "left" true))
(define ball-right-up-mouse-drag-to-right-up 
  (make-ball (make-posn 280 20) (make-posn 299 1) "left" true))

;; ball2 at right-middle corner
(define ball-right-middle 
  (make-ball (make-posn 280 150) (make-posn 0 0) "right" false))
(define ball-right-middle-mouse-down-inside 
  (make-ball (make-posn 280 150) (make-posn 280 160) "right" true))
(define ball-right-middle-mouse-down-boundary 
  (make-ball (make-posn 280 150) (make-posn 300 150) "right" true))
(define ball-right-middle-drag-to-right 
  (make-ball (make-posn 280 150) (make-posn 300 160) "right" true))
;; ball at right-down corner
(define ball-right-down  
  (make-ball (make-posn 280 380) (make-posn 0 0) "right" false))
(define ball-right-down-mouse-down-inside
  (make-ball (make-posn 280 380) (make-posn 280 390) "right" true))
(define ball-right-down-mouse-down-boundary
  (make-ball (make-posn 280 380) (make-posn 280 400) "right" true))
(define ball-right-down-drag-to-right
  (make-ball (make-posn 280 380) (make-posn 280 395) "right" true))
(define ball-right-down-drag-down 
  (make-ball (make-posn 280 380) (make-posn 290 390) "right" true))
(define ball-right-down-drag-right-down
  (make-ball (make-posn 280 380) (make-posn 299 399) "right" true))
(define NINE-BALLS-LIST-WORLD (make-world 
         (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
               ball-middle-middle ball-middle-down ball-right-up 
               ball-right-middle ball-right-down) 9))

(define NINE-BALLS-LIST-WORLD2 (make-world 
                 (list ball-left-up ball-left-middle
                       ball-left-down ball-middle-middle2
                       ball-middle-middle ball-middle-down ball-right-up
                       ball-right-middle ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-TWO-BALLS-WORLD (make-world 
          (list ball-left-up ball-left-middle ball-left-down 
                ball-middle-middle-mouse2-down-inside
                ball-middle-middle-mouse-down-inside ball-middle-down 
                ball-right-up ball-right-middle ball-right-down) 9))

(define MOUSE-DOWN-INSIDE-LEFT-UP-WORLD (make-world
        (list ball-left-up-mouse-down-inside
              ball-left-middle ball-left-down ball-middle-up ball-middle-middle
              ball-middle-down ball-right-up ball-right-middle ball-right-down)
        9))                                 
(define MOUSE-DOWN-INSIDE-LEFT-MIDDLE-WORLD (make-world 
                (list ball-left-up ball-left-middle-mouse-down-inside 
                      ball-left-down ball-middle-up ball-middle-middle
                      ball-middle-down ball-right-up ball-right-middle 
                      ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-LEFT-DOWN-WORLD (make-world 
            (list ball-left-up ball-left-middle ball-left-down-mouse-down-inside
                  ball-middle-up ball-middle-middle ball-middle-down 
                  ball-right-up ball-right-middle ball-right-down) 9))

(define MOUSE-DOWN-INSIDE-MIDDLE-UP-WORLD (make-world 
            (list ball-left-up ball-left-middle ball-left-down 
                  ball-middle-up-mouse-down-inside ball-middle-middle
                  ball-middle-down ball-right-up ball-right-middle 
                  ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-MIDDLE-MIDDLE-WORLD (make-world 
          (list ball-left-up ball-left-middle ball-left-down ball-middle-up
                ball-middle-middle-mouse-down-inside ball-middle-down 
                ball-right-up ball-right-middle ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-MIDDLE-DOWN-WORLD (make-world 
         (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
               ball-middle-middle ball-middle-down-mouse-down-inside 
               ball-right-up ball-right-middle ball-right-down) 9))

(define MOUSE-DOWN-INSIDE-RIGHT-UP-WORLD (make-world 
        (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
             ball-middle-middle ball-middle-down ball-right-up-mouse-down-inside
             ball-right-middle ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-RIGHT-MIDDLE-WORLD (make-world 
      (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
            ball-middle-middle ball-middle-down ball-right-up 
            ball-right-middle-mouse-down-inside ball-right-down) 9))
(define MOUSE-DOWN-INSIDE-RIGHT-DOWN-WORLD (make-world 
   (list ball-left-up ball-left-middle ball-left-down ball-middle-up
         ball-middle-middle ball-middle-down ball-right-up 
         ball-right-middle ball-right-down-mouse-down-inside) 9))


;;;;;;;;;;;;
(define MOUSE-DOWN-BOUNDARY-LEFT-UP-WORLD (make-world
        (list ball-left-up-mouse-down-boundary
              ball-left-middle ball-left-down ball-middle-up ball-middle-middle
              ball-middle-down ball-right-up ball-right-middle ball-right-down)
        9))                                 
(define MOUSE-DOWN-BOUNDARY-LEFT-MIDDLE-WORLD (make-world 
                (list ball-left-up ball-left-middle-mouse-down-boundary 
                      ball-left-down ball-middle-up ball-middle-middle
                      ball-middle-down ball-right-up ball-right-middle 
                      ball-right-down) 9))
(define MOUSE-DOWN-BOUNDARY-LEFT-DOWN-WORLD (make-world 
       (list ball-left-up ball-left-middle ball-left-down-mouse-down-boundary
             ball-middle-up ball-middle-middle ball-middle-down 
             ball-right-up ball-right-middle ball-right-down) 9))

(define MOUSE-DOWN-BOUNDARY-MIDDLE-UP-WORLD (make-world 
            (list ball-left-up ball-left-middle ball-left-down 
                  ball-middle-up-mouse-down-boundary ball-middle-middle
                  ball-middle-down ball-right-up ball-right-middle 
                  ball-right-down) 9))
(define MOUSE-DOWN-BOUNDARY-MIDDLE-MIDDLE-WORLD (make-world 
          (list ball-left-up ball-left-middle ball-left-down 
                ball-middle-up-mouse-down-boundary-2
                ball-middle-middle-mouse-down-boundary ball-middle-down 
                ball-right-up ball-right-middle ball-right-down) 9))
(define MOUSE-DOWN-BOUNDARY-MIDDLE-DOWN-WORLD (make-world 
         (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
               ball-middle-middle ball-middle-down-mouse-down-boundary 
               ball-right-up ball-right-middle ball-right-down) 9))

(define MOUSE-DOWN-BOUNDARY-RIGHT-UP-WORLD (make-world 
     (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
           ball-middle-middle ball-middle-down ball-right-up-mouse-down-boundary
           ball-right-middle ball-right-down) 9))
(define MOUSE-DOWN-BOUNDARY-RIGHT-MIDDLE-WORLD (make-world 
      (list ball-left-up ball-left-middle ball-left-down ball-middle-up 
            ball-middle-middle ball-middle-down ball-right-up 
            ball-right-middle-mouse-down-boundary ball-right-down) 9))
(define MOUSE-DOWN-BOUNDARY-RIGHT-DOWN-WORLD (make-world 
   (list ball-left-up ball-left-middle ball-left-down ball-middle-up
         ball-middle-middle ball-middle-down ball-right-up 
         ball-right-middle ball-right-down-mouse-down-boundary) 9))
;;

(define LIST-OF-THREE-BALL (list ball3 ball2 ball1))
(define LIST-OF-FOUR-BALL (list ball4 ball3 ball2 ball1))
(define LIST-OF-THREE-BALL-WORLD (make-world LIST-OF-THREE-BALL 3))
(define LIST-OF-FOUR-BALL-WORLD (make-world LIST-OF-FOUR-BALL 4))
(define LIST-OF-THREE-BALL-IMAGE 
  (place-image 
   (text "3" 30 "green")
   50 
  50
                         (place-image 
                               BALL-SELECTED
                               (posn-x (ball-center ball3))
                               (posn-y (ball-center ball3))
                               (place-image BALL
                                     (posn-x (ball-center ball2))
                                     (posn-y (ball-center ball2))
                                     (place-image BALL
                                            (posn-x (ball-center ball1))
                                            (posn-y (ball-center ball1))
                                            BACKGROUND)))))

(define LIST-OF-THREE-BALL-NEXT-TICK (list ball3-next-tick ball2-next-tick 
                                          ball1-next-tick))
(define LIST-OF-THREE-BALL-NEXT-TICK-WORLD (make-world 
                                            LIST-OF-THREE-BALL-NEXT-TICK 3))
(define FULL-OF-BALLS (list ball10 ball9 ball8 ball7 ball6 ball5 
                            ball4 ball3 ball2 ball1))
(define FULL-OF-BALLS-WORLD (make-world FULL-OF-BALLS 10))
(define FULL-OF-BALLS-NEXT-TICK (list ball10-next-tick ball9-next-tick 
                                      ball8-next-tick ball7-next-tick 
                                      ball6-next-tick ball5-next-tick 
                                      ball4-next-tick ball3-next-tick 
                                      ball2-next-tick ball1-next-tick))
(define FULL-OF-BALLS-NEXT-TICK-WORLD (make-world FULL-OF-BALLS-NEXT-TICK 10))
(define ONE-TICK-AFTER (make-world LIST-OF-THREE-BALL-NEXT-TICK 3))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main functions

;; run : Any -> World
;; Ignores its argument and runs the world. Returns the final state of the world
;; exmaple (run 1) -> (make-world empty 0)
;; strategy : function compostion
(define (run n)
    (main (initial-world n)))

;; initial-world : Any -> World
;; Ignores its argument and returns the initial world.
;; example : 
;; (initial-world 1) =(make-world empty 0)
;; strategy : function compostion
(define (initial-world n)
   (make-world empty 0))

;; world-to-balls : World -> ListOf<Ball>
;; returns a list of balls in the given world
;; examples:
;; (world-to-balls initial-world) = listofball
;; strategy: structural decomposition on World [w]
(define (world-to-balls w)
    (world-list w))

(define-test-suite world-to-balls-tests
  (check-equal?
       (world-to-balls (initial-world 1))
       empty
       "for empty list")
  (check-equal?
       (world-to-balls (make-world (list ball1) 1))
       (list ball1)
       "for one ball")
  (check-equal?
       (world-to-balls LIST-OF-THREE-BALL-WORLD)
       LIST-OF-THREE-BALL
       "from normal list")
  (check-equal?
       (world-to-balls FULL-OF-BALLS-WORLD)
       FULL-OF-BALLS
       "for full list"))
(run-tests world-to-balls-tests)

;; ball-to-center : Ball -> Posn
;; Given a ball, returns the coordinates of its center as a Posn.
;; example:
;; (ball-to-center ball1) = (make-posn 150 20)
;; strategy: structural decomposition on ball [b]
(define (ball-to-center b)
    (ball-center b))

(define-test-suite ball-to-center-tests
  (check-equal?
       (ball-to-center ball1)
       (make-posn 20 20)
       "for normal ball"))
(run-tests ball-to-center-tests)
;; world-after-tick : World -> World
;; return a new world after each tick. 
;; Each ball moves to a new position
;; Example:
;; (world-after-tick initial-world) = one-tick-after-initial-world
;; strategy: structural decomposition on World [w]
(define (world-after-tick w) 
    (make-world 
         (new-lob-after-one-tick (world-to-balls w))
         (world-count w)))

;; new-lob-after-one-tick : ListOf<Ball> -> ListOf<Ball>
;; return a new list of balls after one tick
;; example: (new-lob-after-one-tick listofball)= listofball-one-tick-later
;; strategy: structural decomposition on List0f<Ball> [iob]
;(define (new-lob-after-one-tick lob)
;   (cond
;       [(empty? lob) empty]
;       [else (cons (new-ball-after-one-tick (first lob))
;                   (new-lob-after-one-tick (rest lob)))]))

;; strategy:higher order function composition
(define (new-lob-after-one-tick lob)
   (map new-ball-after-one-tick lob))

;; new-ball-after-one-tick : Ball -> Ball
;; return a new ball after one tick
;; example: (new-ball-after-one-tick ball1)= ball1-next-tick
;; strategy: structural decomposition on Ball [b]
(define (new-ball-after-one-tick b)
    (new-ball-after-one-tick-helper (ball-center b)
                                    (ball-cursor b)
                                    (ball-dir b)
                                    (ball-selected? b)))
;; new-ball-after-one-tick-helper : Posn Posn Direction Boolean -> Ball
;; return a new ball with new state. For all balls that are not selected
;; if th ball still exist in bound, then return a new position
;; else let it stick to the nearest bound
;; example (new-ball-after-one-tick-helper (make-posn 50 50) (make-posn 50 50)
;;         "left" false)=(make-ball (make-posn 45 50) (make-posn 45 50)
;;                                  "left" false)
;; strategy : function composition
(define (new-ball-after-one-tick-helper center cursor dir selected?)
    (if selected?
        (make-ball center cursor dir selected?)
        (if (next-tick-ball-still-in-bound? center dir)
              (move-ball-forward center dir)
              (stop-ball-at-bound center dir))))

;; next-tick-ball-still-in-bound?: Posn Direction -> Boolean
;; decide whether the ball after next tick will still in bound
;; if so, return the new position, else put the bool tangent to the wall
;; example : (next-tick-ball-still-in-bound? (make-posn 150 30) "left")= true
;; strategy : function composition
(define (next-tick-ball-still-in-bound? center dir)
    (and 
       (<= RADIUS
          (new-x-posn-of-ball (get-x center) dir)
          (- CANVAS-WIDTH RADIUS))
       (<= RADIUS
          (get-y center)
          (- CANVAS-HEIGHT RADIUS))))

;; move-ball-forward : Ball -> Ball
;; return a new ball after one tick if the ball is in bound
;; example: (new-ball-after-one-tick ball1)= ball1-next-tick
;; strategy: function composition
(define (move-ball-forward center dir)
  (make-ball (make-posn (new-x-posn-of-ball (get-x center) dir)
                        (get-y center))
             initial-cursor 
             dir false))

;; new-x-posn-of-ball : Number Direction -> Number
;; get the new x-position of the given x based on the Direction;
;; we assume the next of the ball will in bound, so we just add/minus speed
;; directly. 
;; example: (new-x-posn-of-ball 100 "left") = 95
;; strategy : structural decomposition on Direction [dir]
(define (new-x-posn-of-ball center-x dir)
    (cond 
        [(string=? dir "left") (- center-x SPEED)]
        [(string=? dir "right") (+ center-x SPEED)]))
  
;; stop-ball-at-bound : Number Direction -> Number
;; get the new x-position of the given x based on the Direction;
;; we assume the next of the ball will in bound, so we just add/minus speed
;; directly. 
;; example: (stop-ball-at-bound 100 "left") = 95
;; strategy : structural decomposition on Direction [dir]
(define (stop-ball-at-bound center dir)
    (cond 
        [(string=? dir "left") 
             ;; stop ball at left bound
            (make-ball (make-posn RADIUS (get-y center))
                                          initial-cursor "right" false)]
        [(string=? dir "right") 
            ;; stop ball at right bound
            (make-ball (make-posn (- CANVAS-WIDTH RADIUS)
                                                      (get-y center))
                                           initial-cursor 
                                           "left" false)]))
;; get-x : Posn -> Number
;; return the x axis for the given Posn
;; example : (get-x (make-posn 100 50 )) 100
;; strategy : structural decomposition on Posn [posn]
(define (get-x posn)
    (posn-x posn))

;; get-x : Posn -> Number
;; return the  y axis for the given Posn
;; example : (get-y (make-posn 100 50 ))= 50
;; strategy : structural decomposition on Posn [posn]
(define (get-y posn)
    (posn-y posn))

(define-test-suite new-ball-after-one-tick-tests
  (check-equal?
       (new-ball-after-one-tick ball1)
       ball1-next-tick
       "ball in bound")
  (check-equal?
       (new-ball-after-one-tick ball2)
       ball2-next-tick
       "ball out of bound"))
(run-tests new-ball-after-one-tick-tests)


(define-test-suite new-lob-after-one-tick-tests
  (check-equal?
       (new-lob-after-one-tick empty)
       empty
       "from empty list")
  (check-equal?
       (new-lob-after-one-tick LIST-OF-THREE-BALL)
       LIST-OF-THREE-BALL-NEXT-TICK
       "from normal list")
  (check-equal?
       (new-lob-after-one-tick FULL-OF-BALLS)
       FULL-OF-BALLS-NEXT-TICK
       "for full list"))
(run-tests new-lob-after-one-tick-tests)

(define-test-suite world-after-tick-tests
  (check-equal?
       (world-after-tick (initial-world 1))
       (initial-world 1)
       "from empty list")
  (check-equal?
       (world-after-tick LIST-OF-THREE-BALL-WORLD)
       LIST-OF-THREE-BALL-NEXT-TICK-WORLD
       "for normal list")
  ;;ball1 at left-up corner goes left
  ;; ball 7 will go out right boundary after next tick
  (check-equal?
       (world-after-tick FULL-OF-BALLS-WORLD)
       FULL-OF-BALLS-NEXT-TICK-WORLD
       "for full list"))
(run-tests world-after-tick-tests)

;; render : World -> Image
;; Given a world, produce the related image
;; example:
;; strategy: structural decomposition on World [w]
(define (render w)
    (place-image (draw-text (world-count w)) 
                 50
                 50
                 (draw-balls (world-to-balls w))))

;; draw-text : Number -> Image
;; draw the given number on the canvas
;; example: 
;; (draw-text 5)= (text "5" 11 "black")
;; strategy: domain knowledge
(define (draw-text n)
   (text (number->string n) 30 "green"))

;; draw-balls : ListOf<Ball> -> Image
;; draw the given ball on the canvas
;; example:
;; (draw-balls LIST-OF-THREE-BALL)= LIST-OF-THREE-BALL-IMAGE
;; strategy: structural decompositon on ListOf<Ball> [l]
;(define (draw-balls l)
;     (cond 
;      [(empty? l) BACKGROUND]
;      [else (draw-balls-helper 
;                  (first l)
;                  (draw-balls (rest l)))]))
;; strategy:higher order function composition
(define (draw-balls lob)
   (foldr draw-balls-helper BACKGROUND lob))

;; draw-balls-helper : Ball Image -> Image
;; draw the given Ball on the given image
;; example: (draw-balls-helper LIST-OF-THREE-BALL BACKGROUND)
;; = LIST-OF-THREE-BALL-IMAGE
;; strategy: function composition
(define (draw-balls-helper ball image)
     (place-image 
                  (select-ball-type ball)
                  (get-x (ball-to-center ball))
                  (get-y (ball-to-center ball))
                  image))


;; select-ball-type : Ball -> ?
;; select the right ball type to display
;; example: (select-ball-type ball1)=BALL-SELECTED
;; strategy : function composition
(define (select-ball-type ball)
    (if (ball-selected ball)
        BALL-SELECTED
        BALL))

;; draw-balls : Ball -> Boolean
;; check whether ball is selected
;; example:
;; (ball-selected? ball1) = false
;; strategy: structural decompositon on Ball [b]
(define ( ball-selected ball)
    (ball-selected? ball))

(define-test-suite draw-balls-tests
  (check-equal?
       (draw-balls empty)
       BACKGROUND
       "from empty list")
  (check-equal?
       (render LIST-OF-THREE-BALL-WORLD)
       LIST-OF-THREE-BALL-IMAGE
       "a normal list"))
(run-tests draw-balls-tests)

;; make-new-ball : World -> Ball
;; make a new ball based information in existing world
;; example : 
;; (make-new-ball initial-world)=(make-ball (make-posn 150 120) "right")
;; strategy: structural decomposition on World [w]
(define (make-new-ball w)
    (make-ball (make-posn 150 (+ (* (world-count w) DIAMETER) RADIUS))
               initial-cursor
               "right" false))

;; world-after-key-event : World KeyEvent -> World
;; Returns the world that follows the given world after the given key event.
;; example : (world-after-key-event LIST-OF-THREE-BALL-WORLD "left")
;;       =LIST-OF-THREE-BALL-WORLD
;; strategy: structural decomposition on Key [key]
(define (world-after-key-event w key)
    (cond 
       [(string=? key "n") (if (world-has-extra-space? w)
                               (world-add-new-ball w)
                               w)]
       [else w]))

;; world-has-extra-space? : World -> Boolean
;; decide whether there are more room for addition ball
;; example : 
;; (world-has-extra-space? FULL-OF-BALLS-WORLD) = true
;; (world-has-extra-space? LIST-OF-THREE-BALL-WORLD) = true
;; strategy : structural decomposition on world [w]
(define (world-has-extra-space? w)
    (<= (* DIAMETER (+ 1 (world-count w))) CANVAS-HEIGHT))

(define-test-suite world-has-extra-space?-tests
  (check-equal?
       (world-has-extra-space? LIST-OF-THREE-BALL-WORLD)
       true
       "ball in bound")
  (check-equal?
       (world-has-extra-space? FULL-OF-BALLS-WORLD)
       false
       "ball out of bound"))
(run-tests world-has-extra-space?-tests)

;; world-add-new-ball : World -> World
;; add a new ball to existing world
;; example : 
;; (world-add-new-ball FULL-OF-BALLS-WORLD) = FULL-OF-BALLS-WORLD
;; (world-add-new-ball LIST-OF-THREE-BALL-WORLD) = LIST-OF-FOUR-BALL-WORLD
;; strategy : structural decomposition on world [w]
(define (world-add-new-ball w)
    (make-world (cons (make-new-ball w) (world-list w))
                (+ (world-count w) 1)))

(define-test-suite world-add-new-ball-tests
  (check-equal?
       (world-add-new-ball LIST-OF-THREE-BALL-WORLD)
       LIST-OF-FOUR-BALL-WORLD
       "ball in bound"))
(run-tests world-add-new-ball-tests)

(define-test-suite world-after-key-event-tests
  (check-equal?
       (world-after-key-event (make-world empty 0) "n")
       (make-world (list (make-ball (make-posn 150 RADIUS) 
                                    initial-cursor "right" false)) 1)
       "for initial world, ball number from 0 to 1")
  (check-equal?
       (world-after-key-event (make-world 
                               (list 
                                 (make-ball (make-posn 160 RADIUS) 
                                    initial-cursor "right" false)) 1) "n")
       (make-world 
           (list 
             
             (make-ball (make-posn 150 (* 3 RADIUS)) initial-cursor 
                        "right" false)
             (make-ball (make-posn 160 RADIUS) initial-cursor "right" false)) 2)
       "from one to two balls")
  (check-equal?
       (world-after-key-event (make-world (list ball2 ball1) 2) "n")
       (make-world (list ball3-2 ball2 ball1) 3)
       "from two to three balls")
  (check-equal?
       (world-after-key-event LIST-OF-THREE-BALL-WORLD "n")
       LIST-OF-FOUR-BALL-WORLD
       "from three to fourballs")
  (check-equal?
       (world-after-key-event FULL-OF-BALLS-WORLD "n")
       FULL-OF-BALLS-WORLD
       "for list with full of balls")
  (check-equal?
       (world-after-key-event LIST-OF-THREE-BALL-WORLD "left")
       LIST-OF-THREE-BALL-WORLD
       "for other keys"))
(run-tests world-after-key-event-tests)

;; world-after-mouse-down : World Number Number -> World
;; return a new world based on current position after button-down
;; if select on the ball, then stay there with select? become true
;; else nothing changes
;; example : (world-after-mouse-down 
;; strategy: structural decomposition on World [w]
(define (world-after-mouse-down w x y) 
 (if (select-inside-list? (world-list w) x y)
     (make-world
        (lob-after-mouse-down (world-list w) x y)
        (world-count w))
     w))

;; select-inside-list? ListOf<Ball> Number Number -> Boolean
;; decide whether the given position which mouse clicked (NUmber Number)
;; is inside any element of the given ListOf<Ball>
;; example: 
;; strategy: structural decomposition on ListOf<Ball> [l]
;(define (select-inside-list? l x y)
;   (cond
;       [(empty? l) false]
;       [else (or
;                (select-inside-ball? (first l) x y)
;                (select-inside-list? (rest l) x y))]))
;; strategy:higher order function composition
(define (select-inside-list? l x y)
    (local (;; check-ball-selected? ListOf<Ball>->Boolean
            ;; it checks whether any of the ball is selected
            (define (check-ball-selected? l) (select-inside-ball? l x y)))
    (ormap check-ball-selected? l)))

;; select-inside-ball? Ball Number Number -> Boolean
;; decide whether the given position which mouse clicked (NUmber Number)
;; is inside any element of the given Ball
;; example: (select-inside-ball? ball1 250 250)=false
;; strategy: function composition
(define (select-inside-ball? b x y)
    (and
       (>= RADIUS (abs (- x (get-x (ball-to-center b)))))
       (>= RADIUS (abs (- y (get-y (ball-to-center b)))))))

;; lob-after-mouse-down : ListOf<Ball> Number Number -> ListOf<Ball>
;; update the given ListOf<Ball> based on the click
;; if any of the ball is selected, return a new one and add it
;; to the rest of the ListOf<Ball>
;; example : 
;; (lob-after-mouse-down LIST-OF-THREE-BALL 300 300)=LIST-OF-THREE-BALL
;; strategy: structural decomposition on ListOf<Ball> [l]
;(define (lob-after-mouse-down lob x y)
;   (cond 
;      [(empty? lob) empty]
;      [else (cons
;               (ball-after-mouse-down (first lob) x y)
;               (lob-after-mouse-down (rest lob) x y))]))
;; strategy:higher order function composition and 
;;          structural decomposition on Ball [b]
(define (lob-after-mouse-down lob x y)
    (local(;; lob-after-mouse-down-helper : Ball -> Ball
           ;; get a new position of ball after mouse down
           ;; update the given Ball based on the click if the ball is selected
           (define(lob-after-mouse-down-helper b)
               (if (select-inside-ball? b x y)
                   (make-ball (ball-center b) (make-posn x y) (ball-dir b) true)
                   b)))
      (map lob-after-mouse-down-helper lob)))

;;; ball-after-mouse-down : Ball Number Number -> Ball
;;; update the given Ball based on the click if the ball is selected
;;; example : (ball-after-mouse-down ball1 250 250)=ball1
;;; strategy: structural decomposition on Ball [b]
;(define (ball-after-mouse-down b x y)
;    (if (select-inside-ball? b x y)
;        (make-ball (ball-center b) (make-posn x y) (ball-dir b) true)
;        b))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-drag : World Number Number -> World
;; return a new world based on current position after dragging
;; if RECT has been select, return a new world locate at the position of mouse
;; example : (world-after-drag MOUSE-AT-155-145 180 180)
;;           =DRAG-TO-180-180
;; strategy: structural decomposition on World [w]
(define (world-after-drag w x y)
    (world-after-drag-helper (world-list w) (world-count w) x y))

;; world-after-drag-helper : ListOf<Ball> Number Number Number-> World
;; return a new world after the balls in the ListOf<Ball> is dragged
;; withh the posn (2nd and 3rd Number)
;; example: (world-after-drag-helper LIST-OF-THREE-BALL 3 300)
;; =LIST-OF-THREE-BALL-WORLD
;; strategy: function composition
(define (world-after-drag-helper lob count x y)
    (make-world 
        (lob-after-drag lob x y)
        count))

;; lob-after-mouse-down : ListOf<Ball> Number Number -> ListOf<Ball>
;; update the given ListOf<Ball> based on the click
;; if any of the ball is dragged, return a new one and add it
;; to the rest of the ListOf<Ball>
;; example : (lob-after-drag LIST-OF-THREE-BALL 300 300)
;; =LIST-OF-THREE-BALL-AFTER-DRAG
;; strategy: structural decomposition on ListOf<Ball> [lob]
;(define (lob-after-drag lob x y)
;    (cond 
;      [(empty? lob) empty]
;      [else (cons
;               (ball-after-drag (first lob) x y)
;               (lob-after-drag (rest lob) x y))]))

;; strategy:higher order function composition
;;          and structural decomposition on Ball [b]
(define (lob-after-drag lob x y)
    (local(;; lob-after-drag-helper : Ball -> Ball
           ;; update the given Ball based on the click if the ball is selected
           ;;;; example : (ball-after-drag ball1 300 300)=ball1
           (define(lob-after-drag-helper ball)
               (ball-after-drag-helper 
                            (ball-center ball)
                            (ball-cursor ball)
                            (ball-dir ball)
                            (ball-selected? ball)
                            x y)))
      (map lob-after-drag-helper lob)))

;; ball-after-mouse-down : Ball Number Number -> Ball
;; update the given Ball based on the click if the ball is selected
;; example : (ball-after-drag ball1 300 300)=ball1
;; strategy: structural decomposition on Ball [b]
;(define (ball-after-drag ball x y)
;    (ball-after-drag-helper (ball-center ball)
;                            (ball-cursor ball)
;                            (ball-dir ball)
;                            (ball-selected? ball)
;                            x y))
;; ball-after-drag-helper : Posn Posn Direction Boolean Number Number -> Ball
;; with the given information, returna new ball after dragged
;; example:  (ball-after-drag-helper (make-posn 20 20) (make-posn 15 10)
;;           "left" true 20 20)
;;           = (make-ball (make-posn 25 30) (make-posn 20 20) "left" true))
;; strategy: function composition
(define (ball-after-drag-helper center cursor dir selected? x y)
    (if selected?
        (make-ball (make-posn (get-ball-new-x center cursor x)
                              (get-ball-new-y center cursor y))
                   (make-posn x y)
                   dir
                   selected?)
        (make-ball center cursor dir selected?)
        ))
;; get-ball-new-x > Posn Posn Number -> Number
;; get the new x position of ball and get the new x
;; since we cannot let ball out of bound so, we first check the bound 
;; and return a new value
;; example: (get-ball-new-x (make-posn 20 20) (make-posn 15 10) 20) =25
;; strategy: function composition
(define (get-ball-new-x center cursor x)
   (cond 
     [(or (< CANVAS-WIDTH x) (> (+ (get-x center) (- x (get-x cursor))) 
                                (- CANVAS-WIDTH RADIUS))) 
          (- CANVAS-WIDTH RADIUS)]
     [(or (> 0 x) (< (+ (get-x center) (- x (get-x cursor))) RADIUS)) RADIUS]
     [else (+ (get-x center) (- x (get-x cursor)))]))

;; get-ball-new-y > Posn Posn Number -> Number
;; get the new y position of ball and get the new y
;; since we cannot let ball out of bound so, we first check the bound 
;; and return a new value
;; example:(get-ball-new-x (make-posn 20 20) (make-posn 15 10) 20) =30
;; strategy: function composition
(define (get-ball-new-y center cursor y)
   (cond 
       [(or (< CANVAS-HEIGHT y) (> (+ (get-y center) (- y (get-y cursor))) 
                                   (- CANVAS-HEIGHT RADIUS))) 
            (- CANVAS-HEIGHT RADIUS)]
       [(or (> 0 y) (< (+ (get-y center) (- y (get-y cursor))) RADIUS)) RADIUS]
       [else (+ (get-y center) (- y (get-y cursor)))]))


;(define SELECTED-BALL-WORLD5 (make-world 
;                              (list ball-left-middle-mouse-down-inside 
;                                    ball-middle-up-mouse-down-inside 
;                                    ball-middle-middle-mouse-up-inside 
;                                    ball-right-middle-mouse-down-inside) 4))

(define SELECTED-LEFT-MIDDLE-WORLD5 
  (make-world (list ball1 ball2 
           ball-left-middle-mouse-down-inside) 3))
(define SELECTED-MIDDLE-UP-WORLD5 
  (make-world (list ball1 ball2 
           ball-middle-up-mouse-down-inside) 3))
(define SELECTED-MIDDLE-DOWN-WORLD5 
  (make-world (list ball1 ball2 
         ball-middle-down-mouse-down-inside) 3))
(define SELECTED-RIGHT-MIDDLE-WORLD5 
  (make-world (list ball1 ball2 
              ball-right-middle-mouse-down-inside) 3))

(define DRAG-LEFT-MIDDLE-WORLD5 
  (make-world (list ball1 ball2 
                ball-left-middle-mouse-down-drag-to-left) 3))
(define DRAG-MIDDLE-UP-WORLD5 
  (make-world (list ball1 ball2 
               ball-middle-up-drag-up) 3))
(define DRAG-MIDDLE-DOWN-WORLD5 
  (make-world (list ball1 ball2 
                ball-middle-down-drag-down) 3))
(define DRAG-RIGHT-MIDDLE-WORLD5
  (make-world (list ball1 ball2 
                     ball-right-middle-drag-to-right) 3))

(define SELECTED-BALL-WORLD 
  (make-world (list ball1 ball-left-up-mouse-down-inside) 2))
(define LEFT-UP-BALL-DRAG-LEFT-WORLD 
  (make-world (list ball1 ball-left-up-drag-to-left) 2))
(define LEFT-UP-BALL-DRAG-UP-WORLD 
  (make-world (list  ball1 ball-left-up-drag-to-up) 2))
(define LEFT-UP-BALL-DRAG-LEFT-UP-WORLD 
  (make-world (list  ball1 ball-left-up-drag-to-left-up) 2))

(define SELECTED-BALL-WORLD3
  (make-world (list ball1 ball-left-down-mouse-down-inside) 2))
(define LEFT-DOWN-BALL-DRAG-LEFT-DOWN-WORLD
  (make-world (list ball1 ball-left-down-mouse-drag-to-left-down) 2))

(define SELECTED-BALL-WORLD4 
  (make-world (list ball1 ball-right-up-mouse-down-inside) 2))
(define RIGHT-UP-BALL-DRAG-RIGHT-UP-WORLD
  (make-world (list ball1 ball-right-up-mouse-drag-to-right-up) 2))


(define SELECTED-BALL-WORLD2 
  (make-world (list ball1 ball-right-down-mouse-down-inside) 2))
(define RIGHT-DOWN-BALL-DRAG-RIGHT-WORLD 
  (make-world (list ball1  ball-right-down-drag-to-right) 2))
(define RIGHT-DOWN-BALL-DRAG-DOWN-WORLD 
  (make-world (list ball1 ball-right-down-drag-down) 2))
(define RIGHT-DOWN-BALL-DRAG-RIGHT-DOWN-WORLD 
  (make-world (list ball1 ball-right-down-drag-right-down) 2))

(define MOUSE-DOWN-ON-THREE-INSIDE-WORLD 
  (make-world (list ball-middle-middle-mouse-down-inside
          ball-middle-middle-mouse2-down-inside 
          ball-middle-middle3-mouse-down-inside) 3))
(define DRAG-THREE-STILL-INSIDE-WORLD 
  (make-world (list ball-middle-middle-drag1
            ball-middle-middle2-drag1 ball-middle-middle3-drag1
                                                         ) 3))

(define DRAG-THREE-TO-OUTSIDE-WORLD 
  (make-world (list ball-middle-middle-drag2
             ball-middle-middle2-drag2 ball-middle-middle3-drag2) 3))
(define MOUSE-DOWN-ON-TWO-INSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-mouse-down-inside
            ball-middle-middle-mouse2-down-inside) 3))

(define DRAG-TWO-STILL-INSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-drag1
                    ball-middle-middle2-drag1 ) 3))

(define DRAG-TWO-TO-OUTSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-drag2
            ball-middle-middle2-drag2) 3))

(define MOUSE-DOWN-ON-ONE-INSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-mouse-down-inside) 2))
(define DRAG-ONE-INSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-drag1) 2))
(define DRAG-ONE-OUTSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-drag2) 2))



(define MOUSE-UP-INSIDE-WORLD 
  (make-world (list ball1 ball-middle-middle-mouse-up-inside) 2))
(define MOUSE-UP-ON-BOUNDARY-WORLD 
  (make-world (list ball1 ball-middle-middle-mouse-up) 2))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-mouse-up : World Number Number -> World
;; return a new world based on current position after releaseing the mouse
;; if RECT has been select, return a new world at current location
;; and the RECT is no longer selected
;; example: (world-after-mouse-up DRAG-TO-180-180 180 180)
;;          = MOUSE-UP-180-180
;; strategy: structural decomposition on World [w]
(define (world-after-mouse-up w x y)
    (world-after-mouse-up-helper (world-list w) (world-count w)))

;; world-after-mouse-up-helper : ListOf<Ball> Number Number Number -> 
 ;                                                        ListOf<Ball>
;; return a new ListOf<Ball> given the Posn where the mouse was up
;; example: (world-after-mouse-up-helper DRAF-ONE-INSIDE-WORLD 1)
;; = MOUSE-UP-INSIDE-WORLD
;; strategy: function composition
(define (world-after-mouse-up-helper lob count)
     (make-world 
        (lob-after-mouse-up lob)
        count))

;; lob-after-mouse-up : ListOf<Ball> Number Number -> ListOf<Ball>
;; return a new ListOf<Ball> given the Posn where the mouse was up
;; example:(lob-after-mouse-up (list ball1 ball-middle-middle-drag1))
;; =(list ball1 ball-middle-middle-mouse-up-inside)
;; strategy: structural decomposition on ListOf<Ball> [lob]
;(define (lob-after-mouse-up lob)
;    (cond 
;      [(empty? lob) empty]
;      [else (cons
;               (ball-after-mouse-up (first lob))
;               (lob-after-mouse-up (rest lob)))]))

;; strategy: higher order function composition
(define (lob-after-mouse-up lob)
     (map ball-after-mouse-up lob ))


;; ball-after-mouse-up : Ball Number Number -> Ball
;; return a new Ball given the Posn where the mouse was up
;; example: (ball-after-mouse-up ball-middle-middle-drag1)
;; =ball-middle-middle-mouse-up-inside
;; strategy: structural decomposition on Ball [ball]
(define (ball-after-mouse-up ball)
    (make-ball (ball-center ball) INITIAL-MOUSE (ball-dir ball) false))


;; world-after-mouse-event : World Number Number MouseEvent -> World
;; for the ball selected, drag it to anywhere. And return a new world.
;; examples:(world-after-mouse-event DRAG-ONE-INSIDE-WORLD 12 45 "button-up")
;; MOUSE-UP-INSIDE-WORLD
;; strategy : structural decomposition on MouseEvent [mev]
(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-mouse-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up") (world-after-mouse-up w mx my)]
    [else w]))
(define-test-suite world-after-mouse-event-tests

  (check-equal?
       (world-after-mouse-event DRAG-ONE-INSIDE-WORLD 12 45 "button-up")
       MOUSE-UP-INSIDE-WORLD
       "mouse up when ball is inside canvas")
    (check-equal?
       (world-after-mouse-event DRAG-ONE-OUTSIDE-WORLD 12 45 "button-up")
       MOUSE-UP-ON-BOUNDARY-WORLD
       "mouse up when ball is outside canvas")
    (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 12 45 "button-up")
       NINE-BALLS-LIST-WORLD
       "no ball is selected")
  ;;;;;;;;;;;;;;;;;;;;for drag
    (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD 15 5 "drag")
       LEFT-UP-BALL-DRAG-LEFT-WORLD
       "select left-up ball to left")
  (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD 8 10 "drag")
       LEFT-UP-BALL-DRAG-UP-WORLD
       "select left-up ball up")  
  (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD 1 1 "drag")
       LEFT-UP-BALL-DRAG-LEFT-UP-WORLD
       "select left-up ball left-up") 
  
  (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD2 280 395 "drag")
       RIGHT-DOWN-BALL-DRAG-RIGHT-WORLD
       "select RIGHT-DOWN ball to left")
  (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD2 290 390 "drag")
       RIGHT-DOWN-BALL-DRAG-DOWN-WORLD
       "select RIGHT-DOWN ball up")  
  (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD2 299 399 "drag")
       RIGHT-DOWN-BALL-DRAG-RIGHT-DOWN-WORLD
       "select RIGHT-DOWN ball right down")

    (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD3 1 399 "drag")
       LEFT-DOWN-BALL-DRAG-LEFT-DOWN-WORLD
       "select LEFT-DOWN ball left down")

    (check-equal?
       (world-after-mouse-event SELECTED-BALL-WORLD4 299 1 "drag")
       RIGHT-UP-BALL-DRAG-RIGHT-UP-WORLD
       "drag RIGHT-UP ball right up")  
;; drag four balls at each edge
  
  (check-equal?
       (world-after-mouse-event SELECTED-LEFT-MIDDLE-WORLD5 5 60 "drag")
       DRAG-LEFT-MIDDLE-WORLD5
       "drag RIGHT-middle ball left")  
  (check-equal?
       (world-after-mouse-event SELECTED-MIDDLE-UP-WORLD5 160 0 "drag")
       DRAG-MIDDLE-UP-WORLD5
       "drag middle-up ball up")  
  (check-equal?
       (world-after-mouse-event SELECTED-MIDDLE-DOWN-WORLD5 160 400 "drag")
       DRAG-MIDDLE-DOWN-WORLD5
       "drag middle-down ball down")  
  (check-equal?
       (world-after-mouse-event SELECTED-RIGHT-MIDDLE-WORLD5 300 160 "drag")
       DRAG-RIGHT-MIDDLE-WORLD5
       "drag RIGHT-middle ball right")  
  ;;;;
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-THREE-INSIDE-WORLD 130 350 "drag")
       DRAG-THREE-STILL-INSIDE-WORLD
       "drag two balls together , mouse still in-side")  
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-THREE-INSIDE-WORLD 0 400 "drag")
       DRAG-THREE-TO-OUTSIDE-WORLD
       "drag two balls together out")
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-TWO-INSIDE-WORLD 130 350 "drag")
       DRAG-TWO-STILL-INSIDE-WORLD
       "drag two balls together , mouse still in-side")  
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-TWO-INSIDE-WORLD 0 400 "drag")
       DRAG-TWO-TO-OUTSIDE-WORLD
       "drag two balls together out")
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-ONE-INSIDE-WORLD 130 350 "drag")
       DRAG-ONE-INSIDE-WORLD
       "drag one ball inside the world")
  (check-equal?
       (world-after-mouse-event MOUSE-DOWN-ON-ONE-INSIDE-WORLD 0 400 "drag")
       DRAG-ONE-OUTSIDE-WORLD
       "drag one ball outside the world")
    (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 100 100 "drag")
       NINE-BALLS-LIST-WORLD
       "drag when nothing selected")
;; ;;;;;;;;;;;;;;;;;;;;;;;;for button down
;; balls can appear in 9 places including:
;; left-up
;; left-middle
;; left-down
;; middle-up
;; middle-middle
;; middle-down
;; right-up
;; right-middle
;; right-down
;; the mouse event can be either inside the ball, on the boundary or ouside ball
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 15 10 "button-down")
       MOUSE-DOWN-INSIDE-LEFT-UP-WORLD
       "select inside left-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 10 60 "button-down")
       MOUSE-DOWN-INSIDE-LEFT-MIDDLE-WORLD
       "select inside left-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 10 380 "button-down")
       MOUSE-DOWN-INSIDE-LEFT-DOWN-WORLD
       "select inside left-bottom ball")
  
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 160 30 "button-down")
       MOUSE-DOWN-INSIDE-MIDDLE-UP-WORLD
       "select inside MIDDLE-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 160 70 "button-down")
       MOUSE-DOWN-INSIDE-MIDDLE-MIDDLE-WORLD
       "select inside MIDDLE-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 160 370 "button-down")
       MOUSE-DOWN-INSIDE-MIDDLE-DOWN-WORLD
       "select inside MIDDLE-bottom ball")

  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 280 10 "button-down")
       MOUSE-DOWN-INSIDE-RIGHT-UP-WORLD
       "select inside RIGHT-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 280 160 "button-down")
       MOUSE-DOWN-INSIDE-RIGHT-MIDDLE-WORLD
       "select inside RIGHT-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 280 390 "button-down")
       MOUSE-DOWN-INSIDE-RIGHT-DOWN-WORLD
       "select inside RIGHT-bottom ball")
  
  ;; select when the boundary of two balls
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 20 20 "button-down")
       MOUSE-DOWN-BOUNDARY-LEFT-UP-WORLD
       "select BOUNDARY left-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 0 60 "button-down")
       MOUSE-DOWN-BOUNDARY-LEFT-MIDDLE-WORLD
       "select BOUNDARY left-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 20 400 "button-down")
       MOUSE-DOWN-BOUNDARY-LEFT-DOWN-WORLD
       "select BOUNDARY left-bottom ball")

  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 150 0 "button-down")
       MOUSE-DOWN-BOUNDARY-MIDDLE-UP-WORLD
       "select BOUNDARY MIDDLE-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 150 40 "button-down")
       MOUSE-DOWN-BOUNDARY-MIDDLE-MIDDLE-WORLD
       "select BOUNDARY MIDDLE-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 150 400 "button-down")
       MOUSE-DOWN-BOUNDARY-MIDDLE-DOWN-WORLD
       "select BOUNDARY MIDDLE-bottom ball")
  
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 280 0 "button-down")
       MOUSE-DOWN-BOUNDARY-RIGHT-UP-WORLD
       "select BOUNDARY RIGHT-up ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 300 150 "button-down")
       MOUSE-DOWN-BOUNDARY-RIGHT-MIDDLE-WORLD
       "select BOUNDARY RIGHT-MIDDLE ball")
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 280 400 "button-down")
       MOUSE-DOWN-BOUNDARY-RIGHT-DOWN-WORLD
       "select BOUNDARY RIGHT-bottom ball")
  
  ;; select outside of balls
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 90 220 "button-down")
       NINE-BALLS-LIST-WORLD
       "select outside of balls")
    
  ;; select INSIDE of 2 balls
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD2 160 70 "button-down")
       MOUSE-DOWN-INSIDE-TWO-BALLS-WORLD
       "select outside of balls")

  ;; check all other mouse event
  (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 90 220 "move")
       NINE-BALLS-LIST-WORLD
       "check all other mouse event")
    (check-equal?
     (world-after-mouse-event NINE-BALLS-LIST-WORLD 90 220 "enter")
       NINE-BALLS-LIST-WORLD
       "check all other mouse event")
    (check-equal?
       (world-after-mouse-event NINE-BALLS-LIST-WORLD 90 220 "leave")
       NINE-BALLS-LIST-WORLD
       "check all other mouse event")
  )
(run-tests world-after-mouse-event-tests)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (main w)
  (big-bang w
            (on-tick world-after-tick)
            (on-draw render)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)
            ))
