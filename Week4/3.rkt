;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |3|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANT VARIABLES
(define RADIUS 40)
(define DIAMETER (* 2 RADIUS))
(define BALL (circle RADIUS "solid" "red"))

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

;;A Ball is (make-ball Posn Direction)
(define-struct ball (posn dir))
;; Interp:
;; Posn is the Position of the ball;
;; dir represents the moving Direction of the ball
;; template
;; ball-fn : Posn -> ?
;(define (ball-fn p)
;    ...
;    (ball-posn p)
;    (ball-dir p))

;; A ListOf<Balls> is :
;; empty
;; (cons ball ListOf<Balls>)
;; Interp:
;; empty means no balls in the list
;; or it's a sequence made by a ball and another sequence of balls

;; template 
;; lob-fn : ListOf<Balls> ->?
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define ball1 (make-ball (make-posn 100 RADIUS) "left"))
(define ball1-next-tick (make-ball (make-posn 99 (* RADIUS 1)) "left"))
(define ball2 (make-ball (make-posn 20 (* RADIUS 3)) "left"))
(define ball2-next-tick (make-ball (make-posn 21 (* RADIUS 3)) "right"))
(define ball3 (make-ball (make-posn 150 (* RADIUS 5)) "right"))
(define ball3-next-tick (make-ball (make-posn 151 (* RADIUS 5)) "right"))
(define ball4 (make-ball (make-posn 150 (* RADIUS 7)) "right"))
(define ball4-next-tick (make-ball (make-posn 151 (* RADIUS 7)) "right"))
(define ball5 (make-ball (make-posn 182 (* RADIUS 9)) "left"))
(define ball5-next-tick (make-ball (make-posn 181 (* RADIUS 9)) "left"))
(define ball6 (make-ball (make-posn 150 (* RADIUS 11)) "right"))
(define ball6-next-tick (make-ball (make-posn 151 (* RADIUS 11)) "right"))
(define ball7 (make-ball (make-posn 200 (* RADIUS 13)) "right"))
(define ball7-next-tick (make-ball (make-posn 201 (* RADIUS 13)) "right"))
(define ball8 (make-ball (make-posn 280 (* RADIUS 15)) "right"))
(define ball8-next-tick (make-ball (make-posn 279 (* RADIUS 15)) "left"))
(define ball9 (make-ball (make-posn 150 (* RADIUS 17)) "left"))
(define ball9-next-tick (make-ball (make-posn 149 (* RADIUS 17)) "left"))
(define ball10 (make-ball (make-posn 150 (* RADIUS 19)) "right"))
(define ball10-next-tick (make-ball (make-posn 151 (* RADIUS 19)) "right"))

(define LIST-OF-BALL (list ball3 ball2 ball1))
(define LIST-OF-BALL-FOUR (list ball4 ball3 ball2 ball1))
(define LIST-OF-BALL-WORLD (make-world LIST-OF-BALL 3))
(define LIST-OF-BALL-FOUR-WORLD (make-world LIST-OF-BALL-FOUR 4))
(define LIST-OF-BALL-IMAGE (place-image 
                               BALL
                               150
                               (* RADIUS 5)
                               (place-image BALL
                                     20
                                     (* RADIUS 3)
                                     (place-image BALL
                                            100
                                            (* RADIUS 1)
                                            BACKGROUND))))

(define LIST-OF-BALL-NEXT-TICK (list ball3-next-tick ball2-next-tick 
                                          ball1-next-tick))
(define LIST-OF-BALL-NEXT-TICK-WORLD (make-world LIST-OF-BALL-NEXT-TICK 3))
(define FULL-OF-BALLS (list ball10 ball9 ball8 ball7 ball6 ball5 
                            ball4 ball3 ball2 ball1))
(define FULL-OF-BALLS-WORLD (make-world FULL-OF-BALLS 10))
(define FULL-OF-BALLS-NEXT-TICK (list ball10-next-tick ball9-next-tick 
                                      ball8-next-tick ball7-next-tick 
                                      ball6-next-tick ball5-next-tick 
                                      ball4-next-tick ball3-next-tick 
                                      ball2-next-tick ball1-next-tick))
(define FULL-OF-BALLS-NEXT-TICK-WORLD (make-world FULL-OF-BALLS-NEXT-TICK 10))
(define ONE-TICK-AFTER (make-world LIST-OF-BALL-NEXT-TICK 3))
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

;; ball-to-center : Ball -> Posn
;; Given a ball, returns the coordinates of its center as a Posn.
;; example:
;; (ball-to-center ball1) = (make-posn 150 20)
;; strategy: structural decomposition on ball [b]
(define (ball-to-center b)
    (ball-posn b))

;; world-after-tick : World -> World
;; return a new world after each tick. 
;; Each ball moves to a new position
;; Example:
;; (world-after-tick initial-world) = one-tick-after-initial-world
;; strategy: function composition
(define (world-after-tick w) 
    (make-world 
         (new-lob-after-one-tick (world-to-balls w))
         (world-count w)))

;; new-lob-after-one-tick : ListOf<Ball> -> ListOf<Ball>
;; return a new list of balls after one tick
;; example: (new-lob-after-one-tick listofball)= listofball-one-tick-later
;; strategy: function composition
(define (new-lob-after-one-tick lob)
   (cond
       [(empty? lob) empty]
       [else (cons (new-ball-after-one-tick (first lob))
                   (new-lob-after-one-tick (rest lob)))]))

;; new-ball-after-one-tick : Ball -> Ball
;; return a new ball after one tick
;; example: (new-ball-after-one-tick ball1)= ball1-next-tick
;; strategy: function composition
(define (new-ball-after-one-tick b)
    (if (ball-in-bound? b)
        (move-ball-forward b)
        (move-ball-backward b)))

;; move-ball-forward : Ball -> Ball
;; return a new ball after one tick if the ball is in bound
;; example: (new-ball-after-one-tick ball1)= ball1-next-tick
;; strategy: function composition
(define (move-ball-forward b)
    (cond
        [(string=? (ball-dir b) "left") (move-ball-left b)]
        [(string=? (ball-dir b) "right") (move-ball-right b)])) 

;; move-ball-backward : Ball -> Ball
;; return a new ball after one tick if the ball is out of bound
;; example: (move-ball-backward ball2) = ball2-next-tick
;; strategy: function composition
(define (move-ball-backward b)
    (cond
        [(string=? (ball-dir b) "left") (move-ball-right b)]
        [(string=? (ball-dir b) "right") (move-ball-left b)]))

;; move-ball-left : Ball -> Ball
;; move the ball one step left
;; example :
;; (move-ball-left ball1)= ball1-next-tick
;; strategy: function composition
(define (move-ball-left b)
   (make-ball (move-posn-left (ball-to-center b)) 
              "left"))

;; move-ball-right : Ball -> Ball
;; move the ball one step right
;; example :
;; (move-ball-right ball2)= ball2-next-tick
;; strategy: function composition
(define (move-ball-right b)
   (make-ball (move-posn-right (ball-to-center b)) 
              "right"))

;; move-posn-left : Posn -> Posn
;; move the x of given Posn one step left
;; example :
;; (move-posn-left (make-posn 10 10))= (make-posn 9 10)
;; strategy: function composition
(define (move-posn-left p)
     (make-posn 
         (- (posn-x p) 1)
         (posn-y p)))

;; move-posn-right : Posn -> Posn
;; move the x of given Posn one step right
;; example :
;; (move-posn-left (make-posn 10 10))= (make-posn 11 10)
;; strategy: function composition
(define (move-posn-right p)
     (make-posn 
         (+ (posn-x p) 1)
         (posn-y p)))

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
;; strategy: function composition
(define (draw-text n)
   (text (number->string n) 30 "green"))

;; draw-balls : ListOf<Ball> -> Image
;; draw the given ball on the canvas
;; example:
;; (draw-balls LIST-OF-BALL)= LIST-OF-BALL-IMAGE
;; strategy: function composition
(define (draw-balls l)
     (cond 
      [(empty? l) BACKGROUND]
      [else (place-image 
                  BALL
                  (posn-x (ball-to-center (first l)))
                  (posn-y (ball-to-center (first l)))
                  (draw-balls (rest l)))]))

;; ball-in-bound? : Ball -> Boolean
;; check whether the ball is running within the given canvas
;; (make-ball (make-posn 100 1000) "left") = false
;; strategy: structural decomposition on ball [b]
(define (ball-in-bound? ball)
    (and 
       (< RADIUS
          (posn-x (ball-to-center ball))
          (- CANVAS-WIDTH RADIUS))
       (<= RADIUS
          (posn-y (ball-to-center ball))
          (- CANVAS-HEIGHT RADIUS))))

;; make-new-ball : World -> Ball
;; make a new ball based information in existing world
;; example : (make-new-ball initial-world)=(make-ball (make-posn 150 120) "right")
;; strategy: function composition
(define (make-new-ball w)
    (make-ball (make-posn 150 (+ (* (world-count w) DIAMETER) RADIUS)) 
               "right"))

;; world-after-key-event : World KeyEvent -> World
;; Returns the world that follows the given world after the given key event.
;; example : 
;; strategy: function composition
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
;; (world-has-extra-space? LIST-OF-BALLS-WORLD) = true
;; strategy : structural decomposition on world [w]
(define (world-has-extra-space? w)
    (if (< (world-count w) (/ CANVAS-HEIGHT DIAMETER))
        true
        false))

;; world-add-new-ball : World -> World
;; add a new ball to existing world
;; example : 
;; (world-add-new-ball FULL-OF-BALLS-WORLD) = FULL-OF-BALLS-WORLD
;; (world-add-new-ball LIST-OF-BALLS-WORLD) = LIST-OF-BALL-FOUR-WORLD
;; strategy : function composition
(define (world-add-new-ball w)
    (make-world (cons (make-new-ball w) (world-list w))
                (+ (world-count w) 1)))

(define (main w)
  (big-bang w
            (on-tick world-after-tick)
            (on-draw render)
            (on-key world-after-key-event)
            ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tests

;; Catelog: 
;; world-to-balls-tests
;; world-after-tick-tests
;; new-lob-after-one-tick-tests
;; new-ball-after-one-tick-tests
;; move-ball-forward-tests
;; move-ball-backward-tests
;; draw-balls-tests
;; ball-in-bound?-tests
;; world-has-extra-space?-tests
;; world-add-new-ball-tests

(define-test-suite world-to-balls-tests
  (check-equal?
       (world-to-balls (initial-world 1))
       empty
       "from empty list")
  (check-equal?
       (world-to-balls LIST-OF-BALL-WORLD)
       LIST-OF-BALL
       "from normal list")
  (check-equal?
       (world-to-balls FULL-OF-BALLS-WORLD)
       FULL-OF-BALLS
       "for full list"))
(run-tests world-to-balls-tests)

(define-test-suite world-after-tick-tests
  (check-equal?
       (world-after-tick (initial-world 1))
       (initial-world 1)
       "from empty list")
  (check-equal?
       (world-after-tick LIST-OF-BALL-WORLD)
       LIST-OF-BALL-NEXT-TICK-WORLD
       "for normal list")
  (check-equal?
       (world-after-tick FULL-OF-BALLS-WORLD)
       FULL-OF-BALLS-NEXT-TICK-WORLD
       "for full list"))
(run-tests world-after-tick-tests)

(define-test-suite new-lob-after-one-tick-tests
  (check-equal?
       (new-lob-after-one-tick empty)
       empty
       "from empty list")
  (check-equal?
       (new-lob-after-one-tick LIST-OF-BALL)
       LIST-OF-BALL-NEXT-TICK
       "from normal list")
  (check-equal?
       (new-lob-after-one-tick FULL-OF-BALLS)
       FULL-OF-BALLS-NEXT-TICK
       "for full list"))
(run-tests new-lob-after-one-tick-tests)

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

(define-test-suite move-ball-forward-tests
  (check-equal?
       (move-ball-forward ball5)
       ball5-next-tick
       "ball go left")
  (check-equal?
       (move-ball-forward ball1)
       ball1-next-tick
       "ball go right"))
(run-tests move-ball-forward-tests)

(define-test-suite move-ball-backward-tests
  (check-equal?
       (move-ball-backward ball2)
       ball2-next-tick
       "ball on left edge")
  (check-equal?
       (move-ball-backward ball8)
       ball8-next-tick
       "ball on right edge"))
(run-tests move-ball-backward-tests)

(define-test-suite draw-balls-tests
  (check-equal?
       (draw-balls empty)
       BACKGROUND
       "from empty list")
  (check-equal?
       (draw-balls LIST-OF-BALL)
       LIST-OF-BALL-IMAGE
       "a normal list"))
(run-tests draw-balls-tests)

(define-test-suite ball-in-bound?-tests
  (check-equal?
       (ball-in-bound? (make-ball (make-posn 10 50) "left"))
       false
       "out of bound")
  (check-equal?
       (ball-in-bound? ball2)
       false
       "on bound")
  (check-equal?
       (ball-in-bound? ball1)
       true
       "in bound"))
(run-tests ball-in-bound?-tests)

(define-test-suite world-has-extra-space?-tests
  (check-equal?
       (world-has-extra-space? LIST-OF-BALL-WORLD)
       true
       "ball in bound")
  (check-equal?
       (world-has-extra-space? FULL-OF-BALLS-WORLD)
       false
       "ball out of bound"))
(run-tests world-has-extra-space?-tests)

(define-test-suite world-add-new-ball-tests
  (check-equal?
       (world-add-new-ball LIST-OF-BALL-WORLD)
       LIST-OF-BALL-FOUR-WORLD
       "ball in bound"))
(run-tests world-add-new-ball-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; run the program
(run 1)