;;; Scheme Recursive Art Contest Entry
;;;
;;; Please do not include your name or personal info in this file.
;;;
;;; Title: <The Campanile>
;;;
;;; Description:
;;;   <See and hear you, everyday.>

(define (draw)
  (speed 0)
  (bgcolor "#0f0f10")
  (hideturtle)
  (draw-normal-tower)
  (exitonclick)
)

;;; --------------------------
;;; Helpers
;;; --------------------------

(define (move-to x y)
  (penup)
  (goto x y)
  (seth 0)
  (pendown)
)

(define (line-to x y)
  (goto x y)
)

(define (filled-poly c pts)
  (if (null? pts)
      nil
      (begin
        (color c)
        (move-to (car (car pts)) (car (cdr (car pts))))
        (begin_fill)
        (trace-points (cdr pts))
        (line-to (car (car pts)) (car (cdr (car pts))))
        (end_fill)
      )
  )
)

(define (trace-points pts)
  (if (null? pts)
      nil
      (begin
        (line-to (car (car pts)) (car (cdr (car pts))))
        (trace-points (cdr pts))
      )
  )
)

;;; --------------------------
;;; Main drawing parts
;;; --------------------------

(define (draw-shaft left-c right-c)
  ;; Main body with a tapered bottom closure.
  (filled-poly
   left-c
   (list (list -34 -145)
         (list -29 92)
         (list 0 112)
         (list 0 -178)
    )
  )
  (filled-poly
   right-c
   (list (list 0 -178)
         (list 0 112)
         (list 27 95)
         (list 30 -150)
    )
  )
)

(define (draw-belfry left-c right-c)
  ;; Upper tower block, merged into one continuous top edge.
  (filled-poly
   left-c
   (list (list -29 92)
         (list -22 115)
         (list -12 115)
         (list -8 130)
         (list 0 132)
         (list 0 112)
    )
  )
  (filled-poly
   right-c
   (list (list 0 112)
         (list 0 132)
         (list 8 130)
         (list 12 115)
         (list 22 115)
         (list 27 95)
    )
  )
  ;; add back the two small side pinnacles
  (filled-poly left-c
               (list (list -24 115)
                     (list -22 126)
                     (list -20 115)
                )
  )
  (filled-poly right-c
               (list (list 20 115)
                     (list 22 126)
                     (list 24 115)
                )
  )
)

(define (draw-spire left-c right-c tip-c)
  ;; Tall simplified pyramid roof (overlap downwards to avoid seams).
  (filled-poly
   left-c
   (list (list -12 128)
         (list -1 196)
         (list 0 196)
         (list 0 128)
    )
  )
  (filled-poly
   right-c
   (list (list 0 128)
         (list 0 196)
         (list 1 196)
         (list 14 128)
    )
  )
  (filled-poly
   tip-c
   (list (list -3 196)
         (list 0 220)
         (list 3 196)
    )
  )
)

(define (draw-tower body-left body-right belfry-left belfry-right spire-left spire-right spire-tip)
  (draw-shaft body-left body-right)
  (draw-belfry belfry-left belfry-right)
  (draw-spire spire-left spire-right spire-tip)
)

(define (draw-normal-tower)
  (draw-tower
   "#e9dfd1" "#5b5d70"
   "#ece3d6" "#4f5266"
   "#4e6f8a" "#072247" "#FDB515")
)

; Please leave this last line alone. You may add additional procedures above
; this line.
(draw)