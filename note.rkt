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
  (display 
    (string-concat 
      (filter-string-list-many args (get-string-list data-file))
      "\n"
    )
  )
)

(define (filter-string-list-many keys string-list)
  (if (null? keys)
    string-list
    (filter-string-list-many (cdr keys) (filter-string-list (car keys) string-list))
  )  
)

(define (string-concat-aux str strlist suffix) 
  (if  (null? strlist)
    str
    (string-concat-aux
       (string-append str (string-append (car strlist) suffix))
       (cdr strlist)
       suffix
    )
  )
)

(define (string-concat strlist suffix)
  (string-trim
     (string-concat-aux "" strlist suffix)
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
     [(string=? (car args) "-a") (save-string (string-concat (cdr args) " "))  ]
     [(string=? (car args) "-c") (println (length  (get-string-list data-file)))  ]
     [else (find-matches args)]
  )
)

;; Main

(process-args args)
