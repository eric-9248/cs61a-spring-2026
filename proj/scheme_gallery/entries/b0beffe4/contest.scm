(define (draw)
  (bgcolor "black") (speed 0) (hideturtle) (penup)
  (coral 0 0 120 4 90) (exitonclick))

(define (ts a) (sin (* a 0.01745329)))
(define (tc a) (cos (* a 0.01745329)))
(define (vx cx sz a) (+ cx (* sz (ts a))))
(define (vy cy sz a) (+ cy (* sz (tc a))))

(define (dc d)
  (if (= d 4) (rgb 0 1 1)
  (if (= d 3) (rgb 0.3 0.5 1)
  (if (= d 2) (rgb 0.7 0.1 1)
  (if (= d 1) (rgb 1 0.2 0.5)
              (rgb 1 0.8 0.1))))))

(define (pe cx cy sz d a i)
  (if (= i 5) 'done
    (begin
      (penup) (goto (vx cx sz (+ a (* i 72))) (vy cy sz (+ a (* i 72))))
      (pendown) (color (dc d))
      (goto (vx cx sz (+ a (* (+ i 1) 72))) (vy cy sz (+ a (* (+ i 1) 72))))
      (penup) (pe cx cy sz d a (+ i 1)))))

(define (rc cx cy sz d a i)
  (if (= i 5) 'done
    (let ((oa (+ a (* i 72) 36)) (ns (* sz 0.38)))
      (let ((mx (/ (+ (vx cx sz (+ a (* i 72))) (vx cx sz (+ a (* (+ i 1) 72)))) 2))
            (my (/ (+ (vy cy sz (+ a (* i 72))) (vy cy sz (+ a (* (+ i 1) 72)))) 2)))
        (coral (vx mx ns oa) (vy my ns oa) ns (- d 1) (+ oa 36))
        (rc cx cy sz d a (+ i 1))))))

(define (coral cx cy sz d a)
  (pe cx cy sz d a 0)
  (if (> d 0) (rc cx cy sz d a 0)))

(draw)