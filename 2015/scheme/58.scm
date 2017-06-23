(define (fix f)
  (lambda (x) ((f (fix f)) x)))

(define (fact5 n)
  (define (fact5-sub f)
    (lambda (n)
      (if (< n 1)
	  1
	  (* n (f (- n 1))))))
  ((fix fact5-sub) n))
