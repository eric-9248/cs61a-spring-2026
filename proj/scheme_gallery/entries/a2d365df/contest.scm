;;; Scheme Recursive Art Contest Entry
;;;
;;; Title: The Recursive Bridge!
;;;
;;; Description:
;;;    Seven paths of light,
;;;    Shimmering before your eyes,
;;;    Color found in bytes.

(define (draw-rainbow color-list radius)
    (if (null? color-list)
        'done
        (begin
          (pixelsize 25)
          (color (car color-list))
          
          (setheading 0)

          (begin_fill)
          (circle radius 180)
          (end_fill)

          (penup)
          (setposition (- radius 25) -50)
          (pendown)

          (draw-rainbow (cdr color-list) (- radius 25)))))

(define (draw)
  (speed 0)
  (hideturtle)
  
  (penup)
  (setposition 140 -50)
  (pendown)
  
  (draw-rainbow (list "#FF0000" "#FFA500" "#FFFF00" "#008000" "#0000FF" "#4B0082" "#EE82EE") 140)
  
  (exitonclick))

; Please leave this last line alone. You may add additional procedures above
; this line.
(draw)