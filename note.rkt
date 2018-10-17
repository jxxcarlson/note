#! /usr/bin/env racket
#lang racket

(require racket/string)


;; Files

(define data-file "/Users/carlson/dev/racket/data.txt")


(define (get-data filename) 
  (file->string filename)
)

(define (get-string-list filename)
   (string-split 
      (get-data filename)
      "\n"
    )
)

(define (append-item args)
  (string-append (get-data data-file) (car args) "\n")
)

(define (save-string str)
   (with-output-to-file data-file
     (lambda () (printf (string-append str "\n")))
     #:exists 'append #:mode 'text)
)



;; String lists

(define (contains-word? word phrase) (string-contains? phrase word))

(define (filter-string-list key string-list) 
   (filter (curry contains-word? key) string-list))

(define (find-matches args)
  (println (filter-string-list (car args) (get-string-list data-file)))
)

(define (string-concat-aux str strlist) 
  (if  (null? strlist)
    str
    (string-concat-aux
       (string-append str (string-append (car strlist) " "))
       (cdr strlist))
    )
  )

(define (string-concat strlist)
  (string-trim
     (string-concat-aux "" strlist)
     )
  )


;; Process args

(define args 
   (vector->list 
      (current-command-line-arguments)
   )
)


(define (process-args args) 
  (cond 
     [(string=? (car args) "-a") (save-string (string-concat (cdr args)))  ]
     [else (find-matches args)]
  )
)

;; Main

(process-args args)
