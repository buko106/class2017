(define (caar x)
  (car (car x)))
(define (cadr x)
  (car (cdr x)))
(define (cdar x)
  (cdr (car x)))
(define (cddr x)
  (cdr (cdr x)))
(define (caddr x)
  (car (cdr (cdr x))))
(define (cdddr x)
  (cdr (cdr (cdr x))))
(define (cadddr x)
  (car (cdr (cdr (cdr x)))))

(define (map f l)
  (if (null? l)
      l
      (cons (f (car l)) (map f (cdr l)))))


;rep-loop
(define (scheme)
  (let ((top-env (make-top-env)))
    (define (rep-loop env)
      (display "> ")
      (let* ((res (base-eval (read) env))
             (env (car res))
             (val (cdr res)))
        (print-data val)
        (newline)
        (if (equal? val '*exit*)
            #t
            (rep-loop env))))
    (rep-loop top-env)))

;frame
(define (empty-frame)
  (list))
(define (update frame var val)
  (cons (cons var val) frame))
(define (lookup var frame)
  (assoc var frame))

;env
(define (make-env)
  (list (empty-frame)))
(define (extend-env env)
  (cons (empty-frame) env))
(define (define-var env var val)
  (if (null? env)
      #f
      (set-car! env (update (car env) var val)))
  env)
(define (lookup-var var env)
  (if (null? env)
      #f
      (let ((found (lookup var (car env))))
        (if (pair? found)
            found
            (lookup-var var (cdr env))))))

;closure
(define (make-closure env params body)
  (cons '*lambda* (cons env (cons params body))))
(define (data-closure? data)
  (and (pair? data) (equal? (car data) '*lambda*)))
(define closure-env cadr)
(define closure-params caddr)
(define closure-body cdddr)

;primitive
(define (make-primitive arity fun)
  (list '*primitive* arity fun))
(define (data-primitive? data)
  (and (pair? data) (equal? (car data) '*primitive*)))
(define primitive-arity cadr)
(define primitive-fun caddr)

;print-data
(define (print-data data)
  (cond ((data-closure? data) (display data))
        ((data-primitive? data) (display data))
        ((equal? data '*unspecified*) (display "#<unspecified>"))
        ((equal? data '*error*) (display "#<error>"))
        ((equal? data '*exit*))
        (else (write data))))

;base-eval
(define (base-eval exp env)
  (cond ((eof-object? exp) (cons env '*exit*))
        ((constant? exp) (cons env exp))
        ((symbol? exp) (var-eval exp env))
        ((not (pair? exp)) (eval-error 'non-evaluatable exp env))
        ((equal? (car exp) 'exit) (cons env '*exit*))
        ((equal? (car exp) 'define) (def-eval exp env))
        ((equal? (car exp) 'let) (let-eval exp env))
        ((equal? (car exp) 'let*) (let*-eval exp env))
        ;((equal? (car exp) 'letrec) (letrec-eval exp env))
        ((equal? (car exp) 'lambda) (lambda-eval exp env))
        ((equal? (car exp) 'if) (if-eval exp env))
        ((equal? (car exp) 'cond) (cond-eval exp env))
        ((equal? (car exp) 'begin) (begin-eval exp env))
        ((equal? (car exp) 'quote) (quote-eval exp env))
        ((equal? (car exp) 'list) (list-eval exp env))
        (else (app-eval exp env))))

(define (constant? exp)
  (or (boolean? exp) (number? exp) (string? exp)))

(define (eval-error type exp env)
  (display "ERROR: ")
  (write type)
  (display ": ")
  (print-data exp)
  (newline)
  (cons env '*error*))

(define (let-eval exp env)
  (base-eval (let->app exp) env))
(define (let->app exp)
  (let ((decl (cadr exp))
        (body (cddr exp)))
    (cons (cons 'lambda (cons (map car decl) body))
          (map cadr decl))))

(define (def-eval exp env);略記を実装せよ
  (if (pair? (cadr exp))
      (let* ((var (caadr exp));;関数定義の略記
            (params (cdadr exp))
            (body (cddr exp)))
        (cons (define-var env var (cdr (base-eval (cons 'lambda (cons params body)) env))) var))
      (let* ((var (cadr exp));;非略記
             (res (base-eval (caddr exp) env))
             (env (car res))
             (val (cdr res)))
        (cons (define-var env var val) var))))

(define (var-eval exp env)
  (let ((found (lookup-var exp env)))
    (if (pair? found)
        (cons env (cdr found))
        (eval-error 'unbound-variable exp env))))

(define (lambda-eval exp env)
  (cons env (make-closure env (cadr exp) (cddr exp))))

(define (repeat-base-eval el env)
  (cons env
        (map (lambda (exp) (cdr (base-eval exp env))) el)))

(define (begin-eval exp env)
  (let* ((res (repeat-base-eval (cdr exp) env))
         (env (car res))
         (vl (reverse (cdr res))))
    (cons env
          (if (null? vl) #t (car vl)))))

(define (app-eval exp env)
  (let* ((l (repeat-base-eval exp env))
         (env (car l))
         (fun (cadr l))
         (args (cddr l)))
    (base-apply fun args env)))

  ;自作部分
(define (cond-eval exp env)
  (if (or (equal? 'else (caadr exp)) (cdr (base-eval (caadr exp) env)))
      (cons env (last (repeat-base-eval (cdadr exp) env)))
      (cond-eval (cons 'cond (cddr exp)) env)))
(define (let*-eval exp env)
  (let* ((exenv (extend-env env))
         (exenv (define-var-rec* 
                  exenv
                  (map car (cadr exp)) 
                  (map cadr (cadr exp)))))
    (cons env (last (repeat-base-eval (cddr exp) exenv)))))

(define (define-var-rec* env params args)
  (if (null? params)
      env
      (define-var-rec*
        (define-var env (car params) (cdr (base-eval (car args) env)))
        (cdr params)
        (cdr args))))

(define (list-eval exp env)
  (repeat-base-eval (cdr exp) env))

(define (if-eval exp env)
  (cons env 
        (if (cdr (base-eval (cadr exp) env))
            (cdr (base-eval (caddr exp) env))
            (cdr (base-eval (cadddr exp) env)))))

(define (quote-eval exp env)
  (cons env (cadr exp)))

(define (define-var-rec env params args)
  (if (null? params)
      env
      (define-var-rec 
        (define-var env (car params) (car args))
        (cdr params)
        (cdr args))))
(define (last l)
  (if (null? (cdr l))
      (car l)
      (last (cdr l))))
;

(define (base-apply fun args env)
  (cond ((data-closure? fun)
         (if (= (length (closure-params fun)) (length args))
             (let* ((exenv (extend-env (closure-env fun)))
                    (exenv (define-var-rec exenv (closure-params fun) args)))
               (cons 
                env
                (last (cdr (repeat-base-eval (closure-body fun) exenv)))))
             (eval-error 'wrong-number-of-args fun env)))
        ((data-primitive? fun)
         (if (or (not (number? (primitive-arity fun)))
                 (= (primitive-arity fun) (length args)))
             ((primitive-fun fun) args env)
             (eval-error 'wrong-number-of-args fun env)))
        (else
         (eval-error 'non-function fun env))))

;make-top-env
(define (make-top-env)
  (let* ((env (make-env))
         (env (define-var env '=
                (make-primitive 2 (lambda (args env)
                                    (cons env (= (car args) (cadr args)))))))
         (env (define-var env '+
                (make-primitive 2 (lambda (args env)
                                    (cons env (+ (car args) (cadr args)))))))
         (env (define-var env '<
                (make-primitive 2 (lambda (args env)
                                    (cons env (< (car args) (cadr args)))))))
         (env (define-var env '-
                (make-primitive 2 (lambda (args env)
                                    (cons env (- (car args) (cadr args)))))))
         (env (define-var env '*
                (make-primitive 2 (lambda (args env)
                                    (cons env (* (car args) (cadr args)))))))
         (env (define-var env 'assoc
                (make-primitive 2 (lambda (args env)
                                    (cons env (assoc (car args) (cadr args)))))))
         (env (define-var env 'cons
                (make-primitive 2 (lambda (args env)
                                    (cons env (cons (car args) (cadr args)))))))
         (env (define-var env 'equal?
                (make-primitive 2 (lambda (args env)
                                    (cons env (equal? (car args) (cadr args)))))))
         (env (define-var env 'set-car!
                (make-primitive 2 (lambda (args env)
                                    (cons env (set-car! (car args) (cadr args)))))))
         (env (define-var env 'and
                (make-primitive 2 (lambda (args env)
                                    (cons env (and (car args) (cadr args)))))))
         (env (define-var env 'or
                (make-primitive 2 (lambda (args env)
                                    (cons env (or (car args) (cadr args)))))))
         (env (define-var env 'not
                (make-primitive 1 (lambda (args env)
                                    (cons env (not (car args)))))))

         (env (define-var env 'car
                (make-primitive 1 (lambda (args env)
                                    (cons env (car (car args)))))))
         (env (define-var env 'cdr
                (make-primitive 1 (lambda (args env)
                                    (cons env (cdr (car args)))))))
         (env (define-var env 'pair?
                (make-primitive 1 (lambda (args env)
                                    (cons env (pair? (car args)))))))
         (env (define-var env 'null?
                (make-primitive 1 (lambda (args env)
                                    (cons env (null? (car args)))))))
         (env (define-var env 'symbol?
                (make-primitive 1 (lambda (args env)
                                    (cons env (symbol? (car args)))))))
         (env (define-var env 'boolean?
                (make-primitive 1 (lambda (args env)
                                    (cons env (boolean? (car args)))))))
         (env (define-var env 'number?
                (make-primitive 1 (lambda (args env)
                                    (cons env (number? (car args)))))))
         (env (define-var env 'string?
                (make-primitive 1 (lambda (args env)
                                    (cons env (string? (car args)))))))
         (env (define-var env 'eof-object?
                (make-primitive 1 (lambda (args env)
                                    (cons env (eof-object? (car args)))))))
         (env (define-var env 'write
                (make-primitive 1 (lambda (args env)
                                    (cons env (write (car args)))))))

         (env (define-var env 'read
                (make-primitive 0 (lambda (args env)
                                    (cons env (read))))))
         (env (define-var env 'newline
                (make-primitive 0 (lambda (args env)
                                    (cons env (newline))))))
         (env (define-var env 'display
                (make-primitive 1 (lambda (args env)
                                    (display (car args))
                                    (cons env '*unspecified*)))))
         (env (define-var env 'load ; load に関しては理解できなくもよい
                (make-primitive 1 (lambda (args env)
                                    (with-input-from-file (car args)
                                      (lambda ()
                                        (define (re-loop env)
                                          (let* ((res (base-eval (read) env))
                                                 (env (car res))
                                                 (val (cdr res)))
                                            (if (equal? val '*exit*)
                                                (cons env '*unspecified*)
                                                (re-loop env))))
                                        (re-loop env))))))))
    env))


