(define (my-sort l)
  (cond
   ((null? l) l)
   ((null? (cdr l)) l)
   (else 
    (let ((left (filter (lambda(x)(string>? (car l) x)) l))(right (filter (lambda(x)(string<=? (car l)x)) l)))
      (if (null? left)
	  (cons (car right) (my-sort (cdr right)))
	  (append (my-sort left)(my-sort right)))))))
