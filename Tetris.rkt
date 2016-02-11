;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname hw8) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;===========================================  Tetris ==============================================

;; By Will Gooley and Dylan Wight
;; Use the Left and Right arrow keys to shift the block and the 'A' and 'W' keys to turn the block

;=========================================== Constants =============================================

(require 2htdp/image)
(require 2htdp/universe)

;; Width in pixels of a square of the board
(define GRID-SIZE 30)

;; Width of board in grid squres
(define BOARD-WIDTH 10)

;; Half the width of the board in grid squares
(define HALF-BOARD-WIDTH (floor (/ BOARD-WIDTH 2)))

;; Height of board in grid squares
(define BOARD-HEIGHT 20)

;; Half the height of the board in grid squares
(define HALF-BOARD-HEIGHT (floor (/ BOARD-HEIGHT 2)))

;; Width of board in pixels
(define BOARD-WIDTH-PIXELS (* GRID-SIZE BOARD-WIDTH))

; Height of board in pixels
(define BOARD-HEIGHT-PIXELS (* GRID-SIZE BOARD-HEIGHT))

;; Empty background
(define BACKGROUND (empty-scene BOARD-WIDTH-PIXELS BOARD-HEIGHT-PIXELS))

;; Tetra types
(define O 0)
(define I 1)
(define L 2)
(define J 3)
(define T 4)
(define Z 5)
(define S 6)


;======================================== Data Definitions =========================================
 
;; A Block is a (make-block Number Number Color)
;; color is a symbol or string
(define-struct block [x y color])
#;(define (block-tmpl b)
     ... (block-x b) ... (block-y b) ... (block-color b) ...)
 
;; A Tetra is a (make-tetra Posn BSet)
;; The center point is the point around which the tetra rotates when it spins.
(define-struct tetra [center blocks])
#;(define (tetra-tmpl t)
    ... (tetra-center t) ... (block-x (first (tetra-blocks t))) ...
    (block-y (first (tetra-blocks t))) ... (block-color (first (tetra-blocks t)))
    ... (tetra-tmpl (tetra-center t) (rest (tetra-blocks t))) ...)
 
;; A Set of Blocks (BSet) is one of:
;; - empty
;; - (cons Block BSet)
;; Order does not matter.
#;(define (BSet-tmpl s)
     ... (block-x (first s)) ... (block-y (first s)) ...
    (block-color (first s)) ... (BSet-tmpl (rest s)) ...)

;; A World is a (make-world Tetra BSet Number)
;; The BSet represents the pile of blocks at the bottom of the screen
;; The Number is the current score
(define-struct world [tetra pile score])
#;(define (BSet-tmpl w)
     ... (world-tetra w) ... (world-pile w) ... )


;======================================= Testing Constants =======================================

(define TEST-TETRA-T (make-tetra (make-posn 4 4) (list (make-block 4 4 "orange")
                                                       (make-block 5 4 "orange")
                                                       (make-block 6 4 "orange")
                                                       (make-block 5 5 "orange"))))

(define TEST-TETRA-O (make-tetra (make-posn 0 0) (list (make-block 0 0 "green")
                                                       (make-block 1 0 "green")
                                                       (make-block 1 1 "green")
                                                       (make-block 0 1 "green"))))

(define TEST-TETRA-L (make-tetra (make-posn 2 0) (list (make-block 2 0 "purple")
                                                       (make-block 3 0 "purple")
                                                       (make-block 4 0 "purple")
                                                       (make-block 4 1 "purple"))))

(define TEST-TETRA-J (make-tetra (make-posn 0 2) (list (make-block 0 2 "cyan")
                                                       (make-block 1 2 "cyan")
                                                       (make-block 2 2 "cyan")
                                                       (make-block 2 1 "cyan"))))

(define TEST-TETRA-0 (make-tetra
                      (make-posn (- HALF-BOARD-WIDTH .5) (+ BOARD-HEIGHT .5))
                      (list (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "green")
                            (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "green")
                            (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "green")
                            (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "green"))))
        
(define TEST-TETRA-1 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 2) BOARD-HEIGHT "blue")
                           (make-block (- HALF-BOARD-WIDTH 1) BOARD-HEIGHT "blue")
                           (make-block (+ HALF-BOARD-WIDTH 0) BOARD-HEIGHT "blue")
                           (make-block (+ HALF-BOARD-WIDTH 1) BOARD-HEIGHT "blue"))))
        
(define TEST-TETRA-2 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "purple"))))
        
(define TEST-TETRA-3 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "cyan"))))
        
(define TEST-TETRA-4 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "orange"))))
        
(define TEST-TETRA-5 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "pink"))))
        
(define TEST-TETRA-6 (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "red")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "red")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "red")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "red"))))

(define TEST-WORLD1 (make-world TEST-TETRA-T (list (make-block 0 0 "cyan")
                                                   (make-block 1 0 "cyan")
                                                   (make-block 2 0 "cyan")
                                                   (make-block 3 0 "cyan")
                                                   (make-block 4 0 "cyan")
                                                   (make-block 5 0 "cyan")
                                                   (make-block 6 0 "cyan")
                                                   (make-block 7 0 "cyan")
                                                   (make-block 8 0 "cyan")
                                                   (make-block 9 0 "cyan")) 0))

(define TEST-WORLD2 (make-world TEST-TETRA-T (list (make-block 0 1 "cyan")
                                                   (make-block 1 1 "cyan")
                                                   (make-block 2 1 "cyan")
                                                   (make-block 3 1 "cyan")
                                                   (make-block 4 1 "cyan")
                                                   (make-block 5 1 "cyan")
                                                   (make-block 6 1 "cyan")
                                                   (make-block 7 1 "cyan")
                                                   (make-block 8 1 "cyan")
                                                   (make-block 9 1 "cyan")
                                                   (make-block 6 21 "cyan")) 0))

;======================================= Rendering Functions =======================================

;;place-image/grid: Image Number Number Image -> Image
;; Places an image onto the grid @ grid coords (x y) in the center of a grid square
(define (place-image/grid img x y base)
  (place-image img
               (round (* GRID-SIZE (+ x .5)))
               (round (- BOARD-HEIGHT-PIXELS (* GRID-SIZE (+ y .5))))
               base))


;; draw-block: Block Image -> Image
;; Places a block image in its correct place on the given image
(define (draw-block b img)
  (place-image/grid (square GRID-SIZE "solid" (block-color b)) (block-x b) (block-y b) img))

(check-expect (draw-block (make-block 7 1 "red") BACKGROUND)
              (place-image/grid (square GRID-SIZE "solid" "red") 7 1 BACKGROUND))


;; draw-blocks: BSet Image -> Image
;; places all the blocks in a given bset onto a given image
(define (draw-blocks bset img)
  (foldr draw-block img bset))

;; draw-tetra: Tetra Image -> Image
;; Places a tetra image on the given image 
(define (draw-tetra t img)
  (draw-blocks (tetra-blocks t) img))

(check-expect
 (draw-tetra (make-tetra (make-posn 0 2) (list (make-block 7 0 "orange") (make-block 8 4 "red")))
  BACKGROUND)
 (place-image/grid
  (square GRID-SIZE "solid" "orange") 7 0
  (place-image/grid (square GRID-SIZE "solid" "red") 8 4 BACKGROUND)))

;; draw-pile: BSet Image -> Image
;; Places the blocks in the pile bset on the image
(define (draw-pile pile img)
  (draw-blocks pile img))

(check-expect (draw-pile (list) BACKGROUND) BACKGROUND)

;; draw-score: World -> Image
;; Visual reprsentation of the current score
(define (draw-score w)
  (text (number->string (world-score w)) 20 'black))

(check-expect (draw-score (make-world (list) (list) 5)) (text (number->string 5) 20 'black))

;; draw-world: World -> Image
;; Draws the current state of the world
(define (draw-world w)
  (place-image/grid (draw-score w)
                    1 (* .95 BOARD-HEIGHT)
                    (draw-tetra (world-tetra w) (draw-pile (world-pile w) BACKGROUND))))

(check-expect (draw-world (make-world (make-tetra (make-posn 0 0) (list)) (list) 5))
              (place-image/grid (text (number->string 5) 20 'black)
                    1 (* .95 BOARD-HEIGHT) BACKGROUND))


;========================================= Block Functions ==========================================

;; block-shift-left: Block -> Block
;; Shifts a block left 1 unit
(define (block-shift-left b)
  (make-block (- (block-x b) 1) (block-y b) (block-color b)))

(check-expect (block-shift-left (make-block 4 4 'red)) (make-block 3 4 'red))

;; block-shift-left-offscreen?: Block -> Boolean
;; Determines whether a block can shift left on the x axis
(define (block-shift-left-offscreen? b)
  (<= (block-x (block-shift-left b)) -1))

(check-expect (block-shift-left-offscreen? (make-block 0 4 'red)) true)
(check-expect (block-shift-left-offscreen? (make-block 1 4 'red)) false)

;; block-shift-left-in-pile?: Block BSet -> Boolean
;; Determines whether a block can shift left on the x axis w/o touching the pile
(define (block-shift-left-in-pile? b pile)
  (ormap (lambda (bp) (block-equal? (block-shift-left b) bp)) pile))

(check-expect (block-shift-left-in-pile? (make-block 1 4 'red) (list (make-block 0 4 'red))) true)
(check-expect (block-shift-left-in-pile? (make-block 1 4 'red) (list (make-block 2 4 'red))) false)

;; block-can-shift-left? Block BSet -> Boolean
;; Determines whether a block can shift left
(define (block-can-shift-left? b pile)
  (not (or (block-shift-left-offscreen? b)
           (block-shift-left-in-pile? b pile))))

(check-expect (block-can-shift-left? (make-block 1 4 'red) (list (make-block 0 4 'red))) false)
(check-expect (block-can-shift-left? (make-block 1 4 'red) (list (make-block 2 4 'red))) true)
(check-expect (block-can-shift-left? (make-block 0 4 'red) (list (make-block 2 4 'red))) false)

;; block-shift-right: Block -> Block
;; Shifts a block right by 1 unit
(define (block-shift-right b)
  (make-block (+ (block-x b) 1) (block-y b) (block-color b)))

(check-expect (block-shift-right (make-block 4 4 'red)) (make-block 5 4 'red))

;; block-shift-right-offscreen?: Block -> Boolean
;; Determines whether a block shifted right will be offscreen
(define (block-shift-right-offscreen? b)
  (>= (block-x (block-shift-right b)) BOARD-WIDTH))

(check-expect (block-shift-right-offscreen? (make-block (- BOARD-WIDTH 2) 4 'red)) false)
(check-expect (block-shift-right-offscreen? (make-block BOARD-WIDTH 4 'red)) true)

;; block-shift-right-in-pile?: Block BSet -> Boolean
;; Determines whether a block shifted right will be in the pile
(define (block-shift-right-in-pile? b pile)
  (ormap (lambda (bp) (block-equal? (block-shift-right b) bp)) pile))

(check-expect (block-shift-right-in-pile? (make-block 1 4 'red) (list (make-block 0 4 'red))) false)
(check-expect (block-shift-right-in-pile? (make-block 1 4 'red) (list (make-block 2 4 'red))) true)

;; block-can-shift-right? Block BSet -> Boolean
;; Determines whether a block can shift right
(define (block-can-shift-right? b pile)
  (not (or (block-shift-right-offscreen? b)
           (block-shift-right-in-pile? b pile))))

(check-expect (block-can-shift-right?
               (make-block 1 4 'red) (list (make-block 0 4 'red))) true)
(check-expect (block-can-shift-right?
               (make-block 1 4 'red) (list (make-block 2 4 'red))) false)
(check-expect (block-can-shift-right?
               (make-block BOARD-WIDTH 4 'red) (list (make-block 2 4 'red))) false)

;; block-shift-down: Block -> Block
;; Shifts a block down by 1 unit
(define (block-shift-down b)
  (make-block (block-x b) (- (block-y b) 1) (block-color b)))

(check-expect (block-shift-down (make-block 4 4 'red)) (make-block 4 3 'red))

;; block-on-block? Block Block -> Boolean
;; Determines whether block falling is equal to block stationary
(define (block-on-block? bf bs)
  (and (= (block-x bf) (block-x bs))
       (= (block-y bf) (+ (block-y bs) 1))))

(check-expect (block-on-block? (make-block 1 4 'red) (make-block 1 3 'red)) true)
(check-expect (block-on-block? (make-block 1 4 'red) (make-block 2 4 'red)) false)

;; block-stop? Block Bset -> Boolean
;; Deterimes whether the a falling block is either on a block or is touching the ground
(define (block-stop? bf pile)
  (or (= (block-y bf) 0)
      (ormap (lambda (b) (block-on-block? bf b)) pile)))

(check-expect (block-stop? (make-block 1 4 'red) (list (make-block 1 3 'red))) true)
(check-expect (block-stop? (make-block 1 4 'red) (list (make-block 2 4 'red))) false)
(check-expect (block-stop? (make-block 1 0 'red) (list (make-block 1 3 'red))) true)

;; block-rotate-cw : Posn Block -> Block
;; Rotate the block 90 clockwise around the posn.
(define (block-rotate-cw pivot b)
  (make-block (- (posn-x pivot)
                 (- (posn-y pivot)
                    (block-y b)))
              (- (posn-y pivot)
                 (- (block-x b)
                    (posn-x pivot)))
              (block-color b)))

(check-expect (block-rotate-cw (make-posn 5 4) (make-block 4 4 'red)) (make-block 5 5 'red))

;; block-rotate-cw-offscreen?: Posn Block -> Boolean
;; Determines whether a block will rotate cw offscreen
(define (block-rotate-cw-offscreen? p b)
  (or (= (block-x (block-rotate-cw p b)) -1)
      (= (block-x (block-rotate-cw p b)) BOARD-WIDTH)
      (= (block-y (block-rotate-cw p b)) -1)))

(check-expect (block-rotate-cw-offscreen? (make-posn 0 0) (make-block 2 2 'red)) false)
(check-expect (block-rotate-cw-offscreen? (make-posn -1 0) (make-block 0 0 'red)) true)


;; block-rotate-cw-in-pile?: Posn Block BSet-> Boolean
;; Determines whether a block will rotate cw into the pile
(define (block-rotate-cw-in-pile? pivot b pile)
  (ormap (lambda (bp) (block-equal? (block-rotate-cw pivot b) bp)) pile))

(check-expect (block-rotate-cw-in-pile? (make-posn 1 1)
                                        (make-block 2 2 'red) (list (make-block 1 2 'red))) false)
(check-expect (block-rotate-cw-in-pile? (make-posn 5 4)
                                        (make-block 4 4 'red) (list (make-block 5 5 'red))) true)


;; block-can-rotate-cw?: Posn Block BSet -> Boolean
;; Determines whether a block can rotate cw
(define (block-can-rotate-cw? pivot b pile)
  (not (or (block-rotate-cw-offscreen? pivot b)
           (block-rotate-cw-in-pile? pivot b pile))))

(check-expect (block-can-rotate-cw? (make-posn 1 1) (make-block 2 2 'red)
                                    (list (make-block 1 2 'red))) true)
(check-expect (block-can-rotate-cw? (make-posn 5 4) (make-block 4 4 'red)
                                    (list (make-block 5 5 'red))) false)
(check-expect (block-can-rotate-cw? (make-posn -1 0) (make-block 0 0 'red)
                                    (list (make-block 5 5 'red))) false)

;; block-rotate-ccw : Posn Block -> Block
;; Rotate the block 90 counterclockwise around the posn.
(define (block-rotate-ccw pivot b)
  (make-block (+ (posn-x pivot)
                 (- (posn-y pivot)
                    (block-y b)))
              (+ (posn-y pivot)
                 (- (block-x b)
                    (posn-x pivot)))
              (block-color b)))

(check-expect (block-rotate-ccw (make-posn 5 4) (make-block 4 4 'red)) (make-block 5 3 'red))

;; block-rotate-ccw-offscreen? Posn Block -> Boolean
;; Determines whether a block will rotate ccw offscreen
(define (block-rotate-ccw-offscreen? pivot b)
  (or (= (block-x (block-rotate-ccw pivot b)) -1)
      (= (block-x (block-rotate-ccw pivot b)) BOARD-WIDTH)
      (= (block-y (block-rotate-ccw pivot b)) -1)))

(check-expect (block-rotate-ccw-offscreen? (make-posn 0 0) (make-block 2 2 'red)) false)
(check-expect (block-rotate-ccw-offscreen? (make-posn -1 0) (make-block 0 0 'red)) true)

;; block-rotate-ccw-in-pile? Posn Block BSet -> Boolean
;; Determines whether a block will rotate ccw into the pile
(define (block-rotate-ccw-in-pile? pivot b pile)
  (ormap (lambda (bp) (block-equal? (block-rotate-ccw pivot b) bp)) pile))

(check-expect (block-rotate-ccw-in-pile? (make-posn 5 4)
                                         (make-block 4 4 'red) (list (make-block 5 3 'red))) true)
(check-expect (block-rotate-ccw-in-pile? (make-posn 5 4)
                                         (make-block 4 4 'red) (list (make-block 5 2 'red))) false)

;; block-can-rotate-ccw? Posn Block BSet -> Boolean
;; Determines whether a block can rotate ccw
(define (block-can-rotate-ccw? pivot b pile)
  (not (or (block-rotate-ccw-offscreen? pivot b)
           (block-rotate-ccw-in-pile? pivot b pile))))

(check-expect (block-can-rotate-ccw? (make-posn 5 4)
                                     (make-block 4 4 'red) (list (make-block 5 3 'red))) false)
(check-expect (block-can-rotate-ccw? (make-posn 5 4)
                                     (make-block 4 4 'red) (list (make-block 5 2 'red))) true)
(check-expect (block-can-rotate-ccw? (make-posn -1 0)
                                     (make-block 0 0 'red) (list (make-block 5 2 'red))) false)

;; block-equal?: Block Block -> Boolean
;; Determines if two blocks are at the same position
(define (block-equal? b1 b2)
  (and (= (block-x b1) (block-x b2))
       (= (block-y b1) (block-y b2))))

(check-expect (block-equal? (make-block 4 4 'red) (make-block 4 4 'blue)) true)
(check-expect (block-equal? (make-block 4 4 'red) (make-block 3 4 'blue)) false)

;; block-y-equal?: Block Block -> Boolean
;; Determiens whether two blocks share a y value
(define (block-y-equal? b1 b2)
  (= (block-y b1) (block-y b2)))

(check-expect (block-y-equal? (make-block 4 4 'red) (make-block 1 4 'blue)) true)
(check-expect (block-y-equal? (make-block 4 4 'red) (make-block 3 2 'blue)) false)

;; block-above-top?: Block -> Boolean
;; Checks wheter the game is over from the pile being taller than the board height
(define (block-above-top? b)
  (> (block-y b) BOARD-HEIGHT))

(check-expect (block-above-top? (make-block 4 21 'red)) true)
(check-expect (block-above-top? (make-block 4 3'red)) false)

;========================================= BSet Movement ===========================================

;; bset-shift-left: BSet -> BSet
;; Shifts the list of blocks left by 1 unit
(define (bset-shift-left bset)
  (map block-shift-left bset))

(check-expect (bset-shift-left (list (make-block 4 4 'red) (make-block 4 3 'red)))
              (list (make-block 3 4 'red) (make-block 3 3 'red)))

;;bset-can-shift-left?: bset bset -> boolean
;;determines whether a bset can shift left on the x axis
(define (bset-can-shift-left? bset pile)
  (andmap (lambda (b) (block-can-shift-left? b pile)) bset))

(check-expect (bset-can-shift-left? (list (make-block 4 4 'red) (make-block 4 3 'red))
                                    (list (make-block 1 1 'red))) true)
(check-expect (bset-can-shift-left? (list (make-block 0 4 'red) (make-block 4 3 'red))
                                    (list (make-block 1 1 'red))) false)
(check-expect (bset-can-shift-left? (list (make-block 2 1 'red) (make-block 4 3 'red))
                                    (list (make-block 1 1 'red))) false)

;; bset-shift-right: BSet -> BSet
;; Shifts the list of blocks right by 1 unit
(define (bset-shift-right bset)
  (map block-shift-right bset))

(check-expect (bset-shift-right (list (make-block 4 4 'red) (make-block 4 3 'red)))
              (list (make-block 5 4 'red) (make-block 5 3 'red)))

;; bset-can-shift-right?: BSet BSet-> Boolean
;; Determines whether a bset can shift right on the x axis
(define (bset-can-shift-right? bset pile)
  (andmap (lambda (b) (block-can-shift-right? b pile)) bset))

(check-expect (bset-can-shift-right? (list (make-block 4 4 'red) (make-block 4 3 'red))
                                    (list (make-block 1 1 'red))) true)
#;(check-expect (bset-can-shift-right? (list (make-block 10 4 'red) (make-block 4 3 'red))
                                    (list (make-block 1 1 'red))) false)
(check-expect (bset-can-shift-right? (list (make-block 1 1 'red) (make-block 4 3 'red))
                                    (list (make-block 2 1 'red))) false)

;; bset-shift-down: BSet -> BSet
;; Shifts the list of blocks down by 1 unit
(define (bset-shift-down bset)
  (map block-shift-down bset))

(check-expect (bset-shift-down (list (make-block 4 4 'red) (make-block 4 3 'red)))
              (list (make-block 4 3 'red) (make-block 4 2 'red)))

;; bset-rotate-cw: Posn BSet -> BSet
;; Rotate the bset 90 clockwise around the posn
(define (bset-rotate-cw p bset)
  (map (lambda (b) (block-rotate-cw p b)) bset))


(check-expect (bset-rotate-cw (make-posn 5 4)
                                     (list (make-block 4 4 'red))) (list (make-block 5 5 'red)))

;; bset-can-rotate-cw?: Posn BSet BSet
;; Determines whether a bset can rotate clockwise around a certain point
(define (bset-can-rotate-cw? p bset pile)
  (andmap (lambda (b) (block-can-rotate-cw? p b pile)) bset))

(check-expect (bset-can-rotate-cw?
               (make-posn 5 4) (list (make-block 4 4 'red)) (list (make-block 5 5 'red))) false)
(check-expect (bset-can-rotate-cw?
               (make-posn 5 4) (list (make-block 4 4 'red)) (list (make-block 5 2 'red))) true)
(check-expect (bset-can-rotate-cw?
               (make-posn -1 0) (list (make-block 0 1 'red)) (list (make-block 5 5 'red))) false)


;; bset-rotate-ccw: Posn BSet -> BSet
;; Rotate the bset 90 counterclockwise around a posn
(define (bset-rotate-ccw p bset)
  (map (lambda (b) (block-rotate-ccw p b)) bset))

(check-expect (bset-rotate-ccw (make-posn 5 4)
                                     (list (make-block 4 4 'red))) (list (make-block 5 3 'red)))

;; bset-can-rotate-ccw? Posn BSet BSet
;; Deterimnes whether a bset can rotate counterclockwise around a certain point
(define (bset-can-rotate-ccw? p bset pile)
  (andmap (lambda (b) (block-can-rotate-ccw? p b pile)) bset))

(check-expect (bset-can-rotate-ccw?
               (make-posn 5 4) (list (make-block 4 4 'red)) (list (make-block 5 3 'red))) false)
(check-expect (bset-can-rotate-ccw?
               (make-posn 5 4) (list (make-block 4 4 'red)) (list (make-block 5 2 'red))) true)
(check-expect (bset-can-rotate-ccw?
               (make-posn -1 0) (list (make-block 1 0 'red)) (list (make-block 5 5 'red))) false)

;; bset-landed?: BSet BSet -> Boolean
;; Determines whether any block of a bset is on any of the blocks in pile or on the ground
(define (bset-landed? bset pile)
  (ormap (lambda (b) (block-stop? b pile)) bset))

(check-expect (bset-landed? (list (make-block 4 4 'red)) (list (make-block 4 3 'red))) true)
(check-expect (bset-landed? (list (make-block 4 0 'red)) (list (make-block 4 3 'red))) true)
(check-expect (bset-landed? (list (make-block 4 1 'red)) (list (make-block 4 3 'red))) false)



;========================================= Tetra Movement ===========================================

;; tetra-shift-left: Tetra -> Tetra
;; Shifts the given tetra one grid unit left
(define (tetra-shift-left t)
  (make-tetra (make-posn (+ (posn-x (tetra-center t)) -1) (posn-y (tetra-center t)))
              (bset-shift-left (tetra-blocks t))))

(check-expect (tetra-shift-left TEST-TETRA-T)
              (make-tetra (make-posn 3 4) (list (make-block 3 4 "orange")
                                                (make-block 4 4 "orange")
                                                (make-block 5 4 "orange")
                                                (make-block 4 5 "orange"))))

;; Tetra-can-shift-left?: Tetra BSet-> Boolean
;; Determines whether a tetra can shift left on the x axis
(define (tetra-can-shift-left? t pile)
  (bset-can-shift-left? (tetra-blocks t) pile))

(check-expect (tetra-can-shift-left? (make-tetra (make-posn 0 0)
                                                 (list (make-block 4 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 1 1 'red))) true)

(check-expect (tetra-can-shift-left? (make-tetra (make-posn 0 0)
                                                 (list (make-block 4 3 'red) (make-block 4 3 'red)))
                                    (list (make-block 3 3 'red))) false)

(check-expect (tetra-can-shift-left? (make-tetra (make-posn 0 0)
                                                 (list (make-block 0 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 1 1 'red))) false)
              
;; tetra-shift-right: Tetra -> Tetra
;; Shifts the given tetra one grid unit right
(define (tetra-shift-right t)
  (make-tetra (make-posn (+ (posn-x (tetra-center t)) 1) (posn-y (tetra-center t)))
              (bset-shift-right (tetra-blocks t))))

(check-expect (tetra-shift-right TEST-TETRA-T)
              (make-tetra (make-posn 5 4) (list (make-block 5 4 "orange")
                                                (make-block 6 4 "orange")
                                                (make-block 7 4 "orange")
                                                (make-block 6 5 "orange"))))

;;tetra-can-shift-right?: tetra bset-> boolean
;;determines whether a tetra can shift right on the x axis
(define (tetra-can-shift-right? t pile)
  (bset-can-shift-right? (tetra-blocks t) pile))

(check-expect (tetra-can-shift-right? (make-tetra (make-posn 0 0)
                                                 (list (make-block 4 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 1 1 'red))) true)

(check-expect (tetra-can-shift-right? (make-tetra (make-posn 0 0)
                                                 (list (make-block 4 3 'red) (make-block 4 3 'red)))
                                    (list (make-block 5 3 'red))) false)

#;(check-expect (tetra-can-shift-right? (make-tetra (make-posn 0 0)
                                                 (list (make-block 10 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 1 1 'red))) false)

;; tetra-shift-down: Tetra -> Tetra
;; Shifts the given tetra one grid unit down
(define (tetra-shift-down t)
    (make-tetra (make-posn (posn-x (tetra-center t)) (+ (posn-y (tetra-center t)) -1))
                (bset-shift-down (tetra-blocks t))))

(check-expect (tetra-shift-down TEST-TETRA-T)
              (make-tetra (make-posn 4 3) (list (make-block 4 3 "orange")
                                                (make-block 5 3 "orange")
                                                (make-block 6 3 "orange")
                                                (make-block 5 4 "orange"))))

;; tetra-landed? Tetra BSet -> Boolean
;; Determines whether a tetra is touching the pile or ground
(define (tetra-landed? t pile)
  (bset-landed? (tetra-blocks t) pile))

(check-expect (tetra-landed? (make-tetra (make-posn 0 0)
                                         (list (make-block 4 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 4 2 'red))) true)

(check-expect (tetra-landed? (make-tetra (make-posn 0 0)
                                         (list (make-block 4 3 'red) (make-block 4 3 'red)))
                                    (list (make-block 5 3 'red))) false)

(check-expect (tetra-landed? (make-tetra (make-posn 0 0)
                                         (list (make-block 10 4 'red) (make-block 4 3 'red)))
                                    (list (make-block 1 1 'red))) false)

;; tetra-rotate-cw: Tetra -> Tetra
;; Rotates the tetra 90 clockwise around its center
(define (tetra-rotate-cw t)
  (make-tetra (tetra-center t) (bset-rotate-cw (tetra-center t) (tetra-blocks t))))

(check-expect (tetra-rotate-cw TEST-TETRA-T) (make-tetra (make-posn 4 4)
                                              (list (make-block 4 4 "orange")
                                                    (make-block 4 3 "orange")
                                                    (make-block 4 2 "orange")
                                                    (make-block 5 3 "orange"))))


;;tetra-can-rotate-cw?: Tetra BSet -> Boolean
;; Determines whether a tetra can rotate clockwise
(define (tetra-can-rotate-cw? t pile)
  (bset-can-rotate-cw? (tetra-center t) (tetra-blocks t) pile))

(check-expect (tetra-can-rotate-cw? TEST-TETRA-T (list)) true)

;; tetra-rotate-ccw: Tetra -> Tetra
;; Rotates the tetra 90 counterclockwise around its center
(define (tetra-rotate-ccw t)
  (make-tetra (tetra-center t) (bset-rotate-ccw (tetra-center t) (tetra-blocks t))))

(check-expect (tetra-rotate-ccw TEST-TETRA-T) (make-tetra (make-posn 4 4)
                                              (list (make-block 4 4 "orange")
                                                    (make-block 4 5 "orange")
                                                    (make-block 4 6 "orange")
                                                    (make-block 3 5 "orange"))))

;; tetra-can-rotate-ccw?: Tetra BSet -> Boolean
;; Determines whether a tetra can rotate counterclockwise
(define (tetra-can-rotate-ccw? t pile)
  (bset-can-rotate-ccw? (tetra-center t) (tetra-blocks t) pile))

(check-expect (tetra-can-rotate-ccw? TEST-TETRA-T (list)) true)

;; new-tetra: Integer -> Tetra
;; Generates a new tetra at the top of the screen based off the given type
;; The given Integer must be within [0 - 6]
(define (new-tetra type)
  (cond [(= type O) (make-tetra
                     (make-posn (- HALF-BOARD-WIDTH .5) (+ BOARD-HEIGHT .5))
                     (list (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "green")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "green")
                           (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "green")
                           (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "green")))]
        
        [(= type I) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 2) BOARD-HEIGHT "blue")
                           (make-block (- HALF-BOARD-WIDTH 1) BOARD-HEIGHT "blue")
                           (make-block (+ HALF-BOARD-WIDTH 0) BOARD-HEIGHT "blue")
                           (make-block (+ HALF-BOARD-WIDTH 1) BOARD-HEIGHT "blue")))]
        
        [(= type L) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "purple")
                           (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "purple")))]
        
        [(= type J) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "cyan")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "cyan")))]
        
        [(= type T) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "orange")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "orange")))]
        
        [(= type Z) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "pink")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "pink")))]
        
        [(= type S) (make-tetra
                     (make-posn HALF-BOARD-WIDTH BOARD-HEIGHT)
                     (list (make-block (- HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 0) "red")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 0) "red")
                           (make-block (+ HALF-BOARD-WIDTH 0) (+ BOARD-HEIGHT 1) "red")
                           (make-block (+ HALF-BOARD-WIDTH 1) (+ BOARD-HEIGHT 1) "red")))]))

(check-expect (new-tetra 0) TEST-TETRA-0)
(check-expect (new-tetra 1) TEST-TETRA-1)
(check-expect (new-tetra 2) TEST-TETRA-2)
(check-expect (new-tetra 3) TEST-TETRA-3)
(check-expect (new-tetra 4) TEST-TETRA-4)
(check-expect (new-tetra 5) TEST-TETRA-5)
(check-expect (new-tetra 6) TEST-TETRA-6)

;========================================= Game Functions ==========================================

;; game-over?: World -> Boolean
;; Checks wheter the game is over from the world's pile being taller than the board height
(define (game-over? w)
  (ormap block-above-top? (world-pile w)))

(check-expect (game-over? TEST-WORLD1) false)
(check-expect (game-over? TEST-WORLD2) true)

;; clear-line: BSet Number -> BSet
;; Removes a line and shifts the necessary blocks down
(define (clear-line pile lineNum)
  (append (filter (λ (b) (< (block-y b) lineNum)) pile)
          (bset-shift-down (filter (λ (b) (> (block-y b) lineNum)) pile))))

(check-expect (clear-line (world-pile TEST-WORLD1) 0) (list))

;; clear-lines: BSet BSet -> BSet
;; Clears any lines that are filled with blocks
(define (clear-lines tetra-blocks pile)
  (cond [(empty? tetra-blocks) pile]
        [(cons? tetra-blocks)
         (cond [(= BOARD-WIDTH
                   (foldr + 0 (map (lambda (bp)
                                     (if (block-y-equal? (first tetra-blocks) bp) 1 0)) pile)))
                (clear-lines (rest tetra-blocks)
                             (clear-line pile (block-y (first tetra-blocks))))]
               [else (clear-lines (rest tetra-blocks) pile)])]))

#;(check-expect (clear-lines (list (make-block 8 1 "cyan")) (world-pile TEST-WORLD2))
              (list (make-block 6 20 "cyan")))
   
;; add-to-pile: World -> World
;; Adds the active tetra to the list of stationary bocks in the pile, makes a new active tetra
(define (add-to-pile w)
  (make-world (new-tetra (random 7))
              (clear-lines (tetra-blocks (world-tetra w))
                           (append (tetra-blocks (world-tetra w))
                                   (world-pile w))) (+ (world-score w) 4)))

(check-expect (world-pile (add-to-pile TEST-WORLD1))
                          (list
                           (make-block 4 4 "orange")
                           (make-block 5 4 "orange")
                           (make-block 6 4 "orange")
                           (make-block 5 5 "orange")
                           (make-block 0 0 "cyan")
                           (make-block 1 0 "cyan")
                           (make-block 2 0 "cyan")
                           (make-block 3 0 "cyan")
                           (make-block 4 0 "cyan")
                           (make-block 5 0 "cyan")
                           (make-block 6 0 "cyan")
                           (make-block 7 0 "cyan")
                           (make-block 8 0 "cyan")
                           (make-block 9 0 "cyan")))

 
;; advance: World -> World
;; Advances the game one step
(define (advance w)
  (cond [(tetra-landed? (world-tetra w) (world-pile w)) (add-to-pile w)]
        [else (make-world (tetra-shift-down (world-tetra w)) (world-pile w) (world-score w))]))

;; user-input: World Symbol -> World
;; Interprets the user input and calls the appropriate function
(define (user-input w ke)
  (cond [(key=? ke "left")
         (if (tetra-can-shift-left? (world-tetra w) (world-pile w))
             (make-world (tetra-shift-left (world-tetra w)) (world-pile w) (world-score w)) w)]
        
        [(key=? ke "right")
         (if (tetra-can-shift-right? (world-tetra w) (world-pile w))
             (make-world (tetra-shift-right (world-tetra w)) (world-pile w) (world-score w)) w)]
        
        [(key=? ke "a")
         (if (tetra-can-rotate-ccw? (world-tetra w) (world-pile w))
             (make-world (tetra-rotate-ccw  (world-tetra w)) (world-pile w) (world-score w)) w)]
        
        [(key=? ke "s")
         (if (tetra-can-rotate-ccw? (world-tetra w) (world-pile w))
             (make-world (tetra-rotate-cw   (world-tetra w)) (world-pile w) (world-score w)) w)]
        
        [else w]))

;; main: Number -> Number
;; Starts the game at the given speed, outputs the final score
(define (main speed)
  (world-score
   (big-bang (make-world (new-tetra (random 7)) (list) 0) 
          [to-draw draw-world]
          [on-tick advance speed]
          [on-key user-input]
          [stop-when game-over?])))

(main .5)