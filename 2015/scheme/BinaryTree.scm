(define (bt-empty-tree)
  (list '() '() '()))

(define (bt-empty? t)
  (if (null? (car t))
      #t
      #f))

(define (bt-insert t obj)
  (let ((data (car t)) (left (cadr t)) (right (caddr t)))
    (cond
     ((bt-empty? t) (list obj (bt-empty-tree) (bt-empty-tree)))
     ((string<? obj data) (list data (bt-insert left obj) right))
     ((string>? obj data) (list data left (bt-insert right obj)))
     (else t))))

(define (bt-find t obj)
  (let ((data (car t)) (left (cadr t)) (right (caddr t)))
    (cond
     ((bt-empty? t) #f)
     ((string<? obj data) (bt-find left obj))
     ((string>? obj data) (bt-find right obj))
     (else #t))))

(define (bt-min t)
  (let ((data (car t)) (left (cadr t)))
    (if (bt-empty? left)
        data
        (bt-min left))))

(define (bt-erase-min t)
  (let ((data (car t)) (left (cadr t)) (right (caddr t)))
    (if (bt-empty? left)
        right
        (list data (bt-erase-min left) right))))

(define (bt-erase t obj)
  (let ((data (car t)) (left (cadr t)) (right (caddr t)))  
    (cond
     ((bt-empty? t) t)
     ((string<? obj data) (list data (bt-erase left obj) right))
     ((string>? obj data) (list data left (bt-erase right obj)))
     (else
      (cond 
       ((and (bt-empty? left) (bt-empty? right)) (bt-empty-tree))
       ((bt-empty? right) left)
       (else (list (bt-min right) left (bt-erase-min right))))))))

(define (bt-to-list t)
  (let ((data (car t)) (left (cadr t)) (right (caddr t)))  
    (if (bt-empty? t)
        (list)
        (append (bt-to-list left) (list data) (bt-to-list right)))))
