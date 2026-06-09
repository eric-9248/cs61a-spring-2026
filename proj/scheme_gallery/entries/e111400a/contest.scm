;;; Scheme Recursive Art Contest Entry
;;;
;;; Please do not include your name or personal info in this file.
;;;
;;; Title: 
;;;
;;; Description:
;;;   Triangles recurse,
;;;   tracing out spikes and sprials.
;;;   From lines, depth appears.

;;; ---------------------------------
;;; Constants/Tuneables
;;; ---------------------------------

;; Random seeds for bottom and top triangles
(define BOTTOM-SEED 196)
(define TOP-SEED    234)

;; Small tolerance value used for checking line parallelism
(define EPS 0.000001)

;; Drawing color RGB
(define DRAW-R 0.0)
(define DRAW-G 0.0)
(define DRAW-B 0.0)

;; Spiral length
(define SPIRAL-STEP 8)

;; Triangles above this area must subdivide
(define FORCE-SPLIT-AREA 100000)

;; Triangles below this area cannot subdivide
(define STOP-SPLIT-AREA 60000)

;; Probability that a triangle will subdivide past the area requirement
(define BRANCH-P 0.78)

;; Maximum number of random split attempts before falling back (safety-guard)
(define MAX-SPLIT-ATTEMPTS 10)

;; Minimum quality for a newly created triangle
(define MIN-CHILD-QUALITY 0.1)

;; Minimum quality for a triangle to be splittable
(define MIN-SPLITTABLE-QUALITY 0.08)

;; Region of a triangle's side where an subdivision intersection can occur
(define SPLIT-RATIO-MIN 0.35)
(define SPLIT-RATIO-MAX 0.65)

;; Minimum length of a triangle's longest side to be drawn
(define MIN-VISIBLE-LEN 1.9)

;; Maxmimum number of allowable subdivisions
(define MAX-DEPTH 10)

;; Maximum number of spiral recursions (safety-guard)
(define SPIRAL-SAFETY-LIMIT 200)

(define SPIRAL-MAX-RATIO 0.42)

;;; ---------------------------------
;;; Geometry Logic
;;; ---------------------------------

;; Point and Triangle constructors
;; `(point x y)` represents the point (x, y)
;; `(triangle a b c)` represents the triangle with points a, b, and c
(define (point x y) (list x y))
(define (triangle a b c) (list a b c))

;; Accessor functions
(define (first tuple) (car tuple))
(define (second tuple) (car (cdr tuple)))
(define (third tuple) (car (cdr (cdr tuple))))

;; Returns square of `x`
(define (sq x) (* x x))

;; Minimum and maximum functions
(define (min2 a b) (if (< a b) a b))
(define (min3 a b c) (min2 a (min2 b c)))
(define (max2 a b) (if (> a b) a b))
(define (max3 a b c) (max2 a (max2 b c)))

;; Returns euclidean distance between `pt1` and `pt2`
(define (distance pt1 pt2)
  (sqrt
    (+
      (sq (- (first  pt1) (first  pt2)))
      (sq (- (second pt1) (second pt2)))
    )
  )
)

;; Returns a point `ratio` the way from `pt1` to `pt2`
(define (linear-interpolate pt1 pt2 ratio)
  (point
    (+ (first pt1) (* ratio (- (first pt2) (first pt1))))
    (+ (second pt1) (* ratio (- (second pt2) (second pt1))))
  )
)

;; Returns vector sum of `vec1` and `vec2`
(define (vector+ vec1 vec2)
  (point (+ (first  vec1) (first  vec2))
         (+ (second vec1) (second vec2))
  )
)

;; Returns vector subtraction of `vec2` from `vec1`
(define (vector- vec1 vec2)
  (point (- (first  vec1) (first  vec2))
         (- (second vec1) (second vec2))
  )
)

;; Returns `vec` scaled by `scalar`
(define (vector* vec scalar)
  (point (* (first  vec) scalar)
         (* (second vec) scalar)
  )
)

;; Returns cross-product of `vec1` and `vec2`
(define (cross vec1 vec2)
  (- (* (first  vec1) (second vec2))
     (* (second vec1) (first  vec2))
  )
)

;; Returns the intersection point of the segment from `seg1-start` to `seg1-end` and the
;; segment from `seg2-start` to `seg2-end`, or #f if they are parallel
(define (segment-intersection seg1-start seg1-end seg2-start seg2-end)
  (let ((seg1-vec       (vector- seg1-end   seg1-start))
        (seg2-vec       (vector- seg2-end   seg2-start))
        (start-to-start (vector- seg2-start seg1-start)))
    
    ; The cross product of the direction vectors tells us whether the two segments are parallel 
    ; (or nearly parallel)
    (let ((denom (cross seg1-vec seg2-vec)))
      (if (<= (abs denom) EPS)
        ; If `denom` is very close to 0, the lines are parallel, so there is no intersection
        #f
        
        ; `t` represents how far along segment 1 the intersection occurs
        ; `u` represents how far along segment 2 the intersection occurs
        (let ((t (/ (cross start-to-start seg2-vec) denom))
              (u (/ (cross start-to-start seg1-vec) denom)))
          
          ; If `t` and `u` are both between 0 and 1, the intersection lies on both segments
          (if (and (>= t 0) (<= t 1) (>= u 0) (<= u 1))
              
            ; Compute the intersection point by starting at `seg1-start` and moving along 
            ; `seg1-vec` by `t`
            (vector+ seg1-start (vector* seg1-vec t))
            
            ; Otherwise, the lines intersect, but the segments don't
            #f
          )
        )
      )
    )
  )
)


;; Returns the minimum side length of `tri`
(define (min-edge tri)
  (min3
    (distance (first  tri) (second tri))
    (distance (second tri) (third  tri))
    (distance (third  tri) (first  tri))
  )
)

;; Returns the maximum side length of `tri`
(define (max-edge tri)
  (max3
    (distance (first  tri) (second tri))
    (distance (second tri) (third  tri))
    (distance (third  tri) (first  tri))
  )
)

;; Returns the area of `tri` using cross-product formula
(define (triangle-area tri)
  (let ((a (first tri)) (b (second tri)) (c (third tri)))
    (/ 
      (abs 
        (- 
          (* (- (first  b) (first  a)) 
             (- (second c) (second a)))
          (* (- (second b) (second a)) 
             (- (first  c) (first  a)))
        )
      )
      2
    )
  )
)

;; Returns the "quality" of `tri`, low quality values are skinny triangles,
;; high quality values are wide triangles
;; "Quality" is calulated as the area of the triangle divided by the squared length of
;; the longest edge
(define (triangle-quality tri)
  (let ((longest (max-edge tri)))
    (if (= longest 0)
      0
      (/ (triangle-area tri) (sq longest))
    )
  )
)

;; Returns `tri` with vertices cyclically reordered
(define (rotate-triangle tri k)
  (if (= k 0)
    tri
    (if (= k 1)
      (triangle (second tri) (third tri) (first  tri))
      (triangle (third  tri) (first tri) (second tri))
    )
  )
)

;; Returns `tri` with the last two vertices swapped
(define (flip-triangle tri)
  (triangle (first tri) (third tri) (second tri))
)

;;; ---------------------------------
;;; Drawing Logic
;;; ---------------------------------

;; Sets the drawing color
(define (set-draw-color)
  (color (rgb DRAW-R DRAW-G DRAW-B))
)

;; Draws the segment from `pt1` to `pt2`
(define (segment pt1 pt2)
  (penup)
  (setpos (first pt1) (second pt1))
  (pendown)
  (setpos (first pt2) (second pt2))
)

;; Draws the outline of `tri`
(define (draw-triangle-outline tri)
  (set-draw-color)
  (segment (first  tri) (second tri))
  (segment (second tri) (third  tri))
  (segment (third  tri) (first  tri))
)

;; Returns whether any part of `tri` overlaps the screen bounds
(define (triangle-visible? tri)
  (let ((ax (first  (first  tri)))
        (ay (second (first  tri)))
        (bx (first  (second tri)))
        (by (second (second tri)))
        (cx (first  (third  tri)))
        (cy (second (third  tri)))
        (half-w (/ (screen_width) 2))
        (half-h (/ (screen_height) 2)))
    (not
      (or
        (< (max3 ax bx cx) (- half-w))    ; entirely left of screen
        (> (min3 ax bx cx)    half-w)     ; entirely right of screen
        (< (max3 ay by cy) (- half-h))    ; entirely below screen
        (> (min3 ay by cy)    half-h)     ; entirely above screen
      )
    )
  )
)

;; Returns whether `tri` is large enough to bother drawing
(define (triangle-drawable? tri)
  (> (max-edge tri) min-visible-len)
)

;;; ---------------------------------
;;; Pseudo-random Generator
;;; ---------------------------------

(define MOD 2147483648)
(define MUL 1103515245)
(define INC 12345)

;; Returns the next random seed
(define (next-seed seed)
  (modulo (+ (* MUL seed) INC) MOD)
)

;; Returns a random number in [0, 1)
(define (rand seed)
  (/ (next-seed seed) MOD)
)

;; Returns a random integer in [0, n)
(define (rand-int seed n)
  (quotient (* (next-seed seed) n) MOD)
)

;; Returns a random number in [low, high)
(define (rand-range seed low high)
  (+ low (* (- high low) (rand seed)))
)

;;; ---------------------------------
;;; Triangle Splitting Logic
;;; ---------------------------------

;; Returns two subtriangles of `tri` by splitting along `edge` at `ratio`
(define (make-split tri edge ratio)
  (let ((a (first tri)) 
        (b (second tri)) 
        (c (third tri)))
    (if (= edge 0)
      (let ((intersect-pt (linear-interpolate a b ratio)))
        (list (triangle a intersect-pt c) 
              (triangle intersect-pt b c))
      )

      (if (= edge 1)
          (let ((intersect-pt (linear-interpolate b c ratio)))
            (list (triangle a b intersect-pt) 
                  (triangle a intersect-pt c))
          )

          (let ((intersect-pt (linear-interpolate c a ratio)))
            (list (triangle a b intersect-pt) 
                  (triangle intersect-pt b c))
          )
      )
    )
  )
)

;; Returns the lower quality of the two triangles in `parts`
(define (split-quality parts)
  (min2 (triangle-quality (first parts))
        (triangle-quality (second parts)))
)

;; Returns the index of the longest edge of `tri`
;; edge 0 = AB, edge 1 = BC, edge 2 = CA
(define (longest-edge tri)
  (let ((a (first tri))
        (b (second tri))
        (c (third tri)))
    (let ((ab (distance a b))
          (bc (distance b c))
          (ca (distance c a)))
      (if (and (>= ab bc) (>= ab ca))
        0
        (if (>= bc ca)
          1
          2
        )
      )
    )
  )
)

;; Returns a split of `tri`
;; Keeps trying random ratios along the longest edge until a healthy split is found,
;; then falls back to a midpoint split on the longest edge if necessary
(define (split-triangle tri seed)
  (define (try-splits attempts curr-seed)
    (let ((edge (longest-edge tri))
          (ratio (rand-range curr-seed SPLIT-RATIO-MIN SPLIT-RATIO-MAX)))
      (let ((parts (make-split tri edge ratio)))
        (if (>= (split-quality parts) MIN-CHILD-QUALITY)
          parts
          (if (= attempts 0)
            ;; Safe fallback: split midpoint of longest edge
            (make-split tri edge 0.5)
            (try-splits (- attempts 1) (next-seed curr-seed))
          )
        )
      )
    )
  )
  (try-splits MAX-SPLIT-ATTEMPTS seed)
)

;;; ---------------------------------
;;; Spiral Logic
;;; ---------------------------------

;; Converts a fixed edge-step length into a ratio for a particular edge.
;; For example, if an edge is 200 pixels long and SPIRAL-STEP is 28,
;; the ratio is 28 / 200 = 0.14.
;;
;; The ratio is capped by SPIRAL-MAX-RATIO so small triangles do not collapse
;; too aggressively.
(define (edge-step-ratio pt1 pt2 step-len)
  (let ((edge-len (distance pt1 pt2)))
    (if (<= edge-len EPS)
      0
      (min2 SPIRAL-MAX-RATIO (/ step-len edge-len))
    )
  )
)

;; Draws an inward spiral inside `tri`.
;; Instead of using one constant ratio for every triangle, each side advances
;; by approximately SPIRAL-STEP pixels.
(define (spiral tri guard)
  (if (or (= guard 0) (not (triangle-visible? tri)) (not (triangle-drawable? tri)))
    'done
    (let ((a (first tri))
          (b (second tri))
          (c (third tri)))
      (let ((q-ratio (edge-step-ratio b c SPIRAL-STEP))
            (r-ratio (edge-step-ratio c a SPIRAL-STEP))
            (t-ratio (edge-step-ratio a b SPIRAL-STEP)))
        (let ((q (linear-interpolate b c q-ratio))
              (r (linear-interpolate c a r-ratio))
              (t (linear-interpolate a b t-ratio)))
          (let ((s (segment-intersection r t a q)))
            (segment a q)
            (segment q r)
            (if s
              (begin
                (segment r s)
                (spiral (triangle s q r) (- guard 1))
              )
              (begin
                (segment r t)
                (spiral (triangle t q r) (- guard 1))
              )
            )
          )
        )
      )
    )
  )
)

;; Add info
(define (draw-leaf-spiral tri seed)
  (let ((start (rand-int seed 3))
        (flip? (rand-int (next-seed seed) 2)))
    (set-draw-color)
    (spiral
      (if (= flip? 0)
        (rotate-triangle tri start)
        (flip-triangle (rotate-triangle tri start))
      )
      SPIRAL-SAFETY-LIMIT)
  )
)

;;; ---------------------------------
;;; recursive tree
;;; ---------------------------------

;; Recursively subdivides `tri`, then draws a spiral at the leaves
(define (draw-tree tri depth seed)
  (draw-triangle-outline tri)
  (let ((area (triangle-area tri)))
    (if (or (= depth 0) (<= area STOP-SPLIT-AREA) (< (triangle-quality tri) MIN-SPLITTABLE-QUALITY))
      (draw-leaf-spiral tri seed)
      (if (or (>= area FORCE-SPLIT-AREA) (<= (rand seed) BRANCH-P))
        (let ((parts (split-triangle tri seed)))
          (draw-tree (first parts)  (- depth 1) (next-seed seed))
          (draw-tree (second parts) (- depth 1) (next-seed (next-seed seed)))
        )
        (draw-leaf-spiral tri seed)
      )
    )
  )
)



;;; ---------------------------------
;;; Entry point
;;; ---------------------------------

(define (draw)
  (hideturtle)
  (speed 0)
  (bgcolor "white")

  (let ((bottom-left  (point -500 -500))
        (bottom-right (point  500 -500))
        (top-right    (point  500  500))
        (top-left     (point -500  500)))
    (draw-tree (triangle bottom-left bottom-right top-right) MAX-DEPTH BOTTOM-SEED)
    (draw-tree (triangle bottom-left top-left top-right)     MAX-DEPTH TOP-SEED)
  )

  (exitonclick))

; please leave this last line alone. you may add additional procedures above
; this line.
(draw)
