;;; Scheme Recursive Art Contest Entry
;;;
;;; Please do not include your name or personal info in this file.
;;;
;;; Title: Digital Distortion
;;;
;;; Description:
;;   A visualization of audio signal clipping.
;;   High-frequency jitter & the precision of recursion.
;:


(define (glitch depth length angle)
  (if (> depth 0)
      (begin
        (if (= (modulo depth 2) 0)
            (color "lime")      
            (color "magenta")) 
(forward length)

             (left angle)
      
        (glitch (- depth 1) (* length 0.95) (+ angle 5))(right (* angle 2))(glitch (- depth 1) (* length 0.8) (- angle 10)))))


(define (draw)
  (speed 0)           
  (bgcolor "black")  

  (hideturtle)        
  (penup) 
  (goto -100 0) 

  (pendown)(glitch 11 55 45)   
  
  (exitonclick))

; Please leave this last line alone. You may add additional procedures above
; this line.
(draw)