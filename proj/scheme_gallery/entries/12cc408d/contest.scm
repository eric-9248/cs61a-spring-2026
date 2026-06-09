;;; Scheme Recursive Art Contest Entry
;;;
;;; Please do not include your name or personal info in this file.
;;;
;;; Title: 3D 67 Spin
;;;
;;; Description:
;;;   <Ever wondered if you can write a 3D rendering engine in turtle through scheme?
;;;    I did.
;;;    My unemployedness truly knows no bounds.>

(define (draw)

  (color "black")
  (hideturtle)
  (speed 0)

  (define (cadr x) (car (cdr x)))
  (define (cddr x) (cdr (cdr x)))
  (define (caddr x) (car (cdr (cdr x))))
  (define (element_at_index lst n)
    (if (= n 0)
        (car lst)
        (element_at_index (cdr lst) (- n 1))))

  (define vertices_6
    '((-1.5 -1.0 -0.5) (-0.5 -1.0 -0.5) (-0.5 0.0 -0.5) (-1.5 0.0 -0.5)
      (-1.5 1.0 -0.5)  (-0.5 1.0 -0.5)
      (-1.5 -1.0 0.5)  (-0.5 -1.0 0.5)  (-0.5 0.0 0.5)  (-1.5 0.0 0.5)
      (-1.5 1.0 0.5)   (-0.5 1.0 0.5)))

  (define edges_6
    '((0 1) (1 2) (2 3) (3 0) (3 4) (4 5)
      (6 7) (7 8) (8 9) (9 6) (9 10) (10 11)
      (0 6) (1 7) (2 8) (3 9) (4 10) (5 11)))

  (define vertices_7
    '((0.5 1.0 -0.5) (1.5 1.0 -0.5) (1.5 -1.0 -0.5)
      (0.5 1.0 0.5)  (1.5 1.0 0.5)  (1.5 -1.0 0.5)))

  (define edges_7
    '((0 1) (1 2)
      (3 4) (4 5)
      (0 3) (1 4) (2 5)))

  (define (rotate_y point angle)
    (define x (car point))
    (define y (cadr point))
    (define z (caddr point))
    (define cos_a (cos angle))
    (define sin_a (sin angle))
    (define x_new (- (* x cos_a) (* z sin_a)))
    (define z-new (+ (* x sin_a) (* z cos_a)))
    (list x_new y z-new))

  (define (y_offset point angle dir)
    (define x (car point))
    (define y (cadr point))
    (define z (caddr point))
    (define sin_a (sin (* 2 angle)))
    (list x (+ y (* dir sin_a 0.67)) z))

  (define (project point)
    (define x (car point))
    (define y (cadr point))
    (define z (caddr point))
    (define distance 4)
    (define factor (/ distance (+ distance z)))
    (define x_proj (* x factor 100.0))
    (define y_proj (* y factor 100.0))
    (list x_proj y_proj))

  (define (draw_object vertices edges angle dir)
    (define offset_verts (map (lambda (v) (y_offset v angle dir)) vertices))
    (define rotated_verts (map (lambda (v) (rotate_y v angle)) offset_verts))
    (define projected_verts (map project rotated_verts))
    (map
     (lambda (edge)
       (define p1 (element_at_index projected_verts (car edge)))
       (define p2 (element_at_index projected_verts (cadr edge)))
       (begin
         (penup)
         (goto (car p1) (cadr p1))
         (pendown)
         (goto (car p2) (cadr p2))))
     edges))

  (define (num_to_str n)
    (cond
      ((= n 0) "0") ((= n 1) "1") ((= n 2) "2") ((= n 3) "3") ((= n 4) "4")
      ((= n 5) "5") ((= n 6) "6") ((= n 7) "7") ((= n 8) "8") ((= n 9) "9")
      ((= n 10) "10") ((= n 11) "11") ((= n 12) "12") ((= n 13) "13") ((= n 14) "14")
      ((= n 15) "15") ((= n 16) "16") ((= n 17) "17") ((= n 18) "18") ((= n 19) "19")
      ((= n 20) "20") ((= n 21) "21") ((= n 22) "22") ((= n 23) "23") ((= n 24) "24")
      ((= n 25) "25") ((= n 26) "26") ((= n 27) "27") ((= n 28) "28") ((= n 29) "29")
      ((= n 30) "30") ((= n 31) "31") ((= n 32) "32") ((= n 33) "33") ((= n 34) "34")
      ((= n 35) "35") ((= n 36) "36") ((= n 37) "37") ((= n 38) "38") ((= n 39) "39")
      ((= n 40) "40") ((= n 41) "41") ((= n 42) "42") ((= n 43) "43") ((= n 44) "44")
      ((= n 45) "45") ((= n 46) "46") ((= n 47) "47") ((= n 48) "48") ((= n 49) "49")
      ((= n 50) "50") ((= n 51) "51") ((= n 52) "52") ((= n 53) "53") ((= n 54) "54")
      ((= n 55) "55") ((= n 56) "56") ((= n 57) "57") ((= n 58) "58") ((= n 59) "59")
      (else "high-number")))

  (define (animate i angle)
    (if (< i 60)
        (begin
          (clear)
          (draw_object vertices_6 edges_6 angle 1)
          (draw_object vertices_7 edges_7 angle -1)
          (save-to-file (num_to_str i))
          (animate (+ i 1) (+ angle 0.1)))))

  (animate 0 0.0)
  (exitonclick))

; Please leave this last line alone. You may add additional procedures above
; this line.
(draw)