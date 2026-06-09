;;; Scheme Recursive Art Contest Entry
;;;
;;; Please do not include your name or personal info in this file.
;;;
;;; Title: Black Lodge Overlook
;;;
;;; Description:
;;;   Curtains part and mountain shadows breathe.
;;;   Chevron roads fold inward through the dream.
;;;   A cup waits where the pines remember.

(define pi 3.1415926535)

(define maroon-dark "#2e060d")
(define maroon "#6b0f1a")
(define maroon-light "#8e1f2e")
(define sky "#173f4a")
(define mist "#87a2a4")
(define mountain-back "#40696a")
(define mountain-front "#1f3b3b")
(define snow "#e8eff0")
(define pine "#0a0f0d")
(define floor-light "#f3ead3")
(define floor-dark "#111111")
(define cup-white "#f7f1e6")
(define coffee "#2d170f")
(define gold "#d4b160")
(define moon "#efe7cc")

(define (pt x y) (list x y))
(define (px p) (car p))
(define (py p) (car (cdr p)))

(define (move-point p)
  (goto (px p) (py p)))

(define (trace pts)
  (if (null? pts)
      'done
      (begin
        (move-point (car pts))
        (trace (cdr pts)))))

(define (fill-shape c pts)
  (color c)
  (penup)
  (move-point (car pts))
  (pendown)
  (begin_fill)
  (trace (cdr pts))
  (move-point (car pts))
  (end_fill)
  (penup))

(define (rect x y w h c)
  (fill-shape c
    (list (pt x y)
          (pt (+ x w) y)
          (pt (+ x w) (+ y h))
          (pt x (+ y h)))))

(define (quad x1 y1 x2 y2 x3 y3 x4 y4 c)
  (fill-shape c
    (list (pt x1 y1)
          (pt x2 y2)
          (pt x3 y3)
          (pt x4 y4))))

(define (tri x1 y1 x2 y2 x3 y3 c)
  (fill-shape c
    (list (pt x1 y1)
          (pt x2 y2)
          (pt x3 y3))))

(define (ellipse-points cx cy rx ry k n)
  (if (= k n)
      nil
      (cons
        (pt (+ cx (* rx (cos (* 2 pi (/ k n)))))
            (+ cy (* ry (sin (* 2 pi (/ k n))))))
        (ellipse-points cx cy rx ry (+ k 1) n))))

(define (ellipse cx cy rx ry c)
  (fill-shape c (ellipse-points cx cy rx ry 0 28)))

(define (draw-mountain x y w h body)
  (tri x y (+ x (/ w 2)) (+ y h) (+ x w) y body)
  (tri (+ x (* 0.34 w)) (+ y (* 0.55 h))
       (+ x (* 0.5 w)) (+ y h)
       (+ x (* 0.66 w)) (+ y (* 0.55 h))
       snow))

(define (draw-tree x y w h depth)
  (if (= depth 0)
      'done
      (begin
        (tri x y (+ x (/ w 2)) (+ y h) (+ x w) y pine)
        (draw-tree (+ x (* 0.16 w))
                   (+ y (* 0.23 h))
                   (* w 0.68)
                   (* h 0.7)
                   (- depth 1)))))

(define (forest x y w h count)
  (if (= count 0)
      'done
      (begin
        (draw-tree x y w h 4)
        (forest (+ x (* w 0.72))
                y
                (* w 0.96)
                (* h 1.02)
                (- count 1)))))

(define (left-bands i n)
  (if (= i n)
      'done
      (begin
        (quad (+ -512 (* i 120)) -512
              (+ -452 (* i 120)) -512
              (+ -182 (* i 58)) 88
              (+ -216 (* i 58)) 88
              floor-dark)
        (left-bands (+ i 1) n))))

(define (right-bands i n)
  (if (= i n)
      'done
      (begin
        (quad (- 512 (* i 120)) -512
              (- 452 (* i 120)) -512
              (- 182 (* i 58)) 88
              (- 216 (* i 58)) 88
              floor-dark)
        (right-bands (+ i 1) n))))

(define (curtain-panel x w body accent)
  (quad x 80
        (+ x w) 80
        (+ x (* 0.82 w)) 512
        (+ x (* 0.18 w)) 512
        body)
  (quad (+ x (* 0.28 w)) 80
        (+ x (* 0.66 w)) 80
        (+ x (* 0.58 w)) 512
        (+ x (* 0.37 w)) 512
        accent))

(define (left-curtain x w n)
  (if (= n 0)
      'done
      (begin
        (curtain-panel x w maroon maroon-light)
        (left-curtain (+ x w) w (- n 1)))))

(define (right-curtain x w n)
  (if (= n 0)
      'done
      (begin
        (curtain-panel x w maroon maroon-light)
        (right-curtain (+ x w) w (- n 1)))))

(define (valance x w n)
  (if (= n 0)
      'done
      (begin
        (tri x 356
             (+ x (/ w 2)) 222
             (+ x w) 356
             (if (= (modulo n 2) 0) maroon maroon-light))
        (valance (+ x w) w (- n 1)))))

(define (draw-cup)
  (ellipse 0 -352 88 18 gold)
  (ellipse 0 -346 82 14 floor-light)
  (quad -54 -350
        54 -350
        40 -264
        -40 -264
        cup-white)
  (ellipse 0 -263 44 11 cup-white)
  (ellipse 0 -262 37 7 coffee)
  (rect -18 -336 36 8 gold))

(define (draw)
  (hideturtle)
  (rect -512 -512 1024 1024 maroon-dark)

  (rect -260 88 520 424 sky)
  (rect -260 88 520 94 mist)
  (ellipse 154 390 34 34 moon)

  (draw-mountain -210 168 248 220 mountain-back)
  (draw-mountain -24 160 292 252 mountain-back)
  (draw-mountain -154 132 340 248 mountain-front)
  (draw-mountain 82 120 236 208 mountain-front)
  (forest -258 84 48 120 12)

  (quad -512 -512
        512 -512
        222 88
        -222 88
        floor-light)
  (left-bands 0 4)
  (right-bands 0 4)
  (quad -28 -512 28 -512 12 88 -12 88 floor-dark)

  (left-curtain -512 46 5)
  (right-curtain 282 46 5)
  (rect -512 356 1024 156 maroon-dark)
  (valance -512 102 10)

  (draw-cup)
  (exitonclick))

; Please leave this last line alone. You may add additional procedures above
; this line.
(draw)
