#! /usr/bin/env racket
#lang racket

(require racket/string)
(require racket/system)
(require db)
(require db/util/datetime)


(define pgc (postgresql-connect #:user "carlson"
                      #:database "notes"))


(define (now) (seconds->date (current-seconds)))

(define (timestamp) (srfi-date->sql-timestamp (now)))


; (define describe-table (query-exec notes-connection "DESCRIBE TABLE notes"))

(define list-columns-query
  "SELECT * FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes'")


; CREATE RECORD
(define (insert-note note)
  (query-exec
      pgc
      "INSERT INTO notes VALUES ($1, $2, $3, $4)"
      9999 (timestamp) (timestamp) note
  ))

(define (insert-note1 note)
  (query-exec
      pgc
      "INSERT INTO notes VALUES (id, created_on, modified_on, note)"
       9999 (timestamp) (timestamp) note))


; LIST ALL RECORDS
(define (list-notes)
   (query-list pgc "select note from notes order by id"))

(define (display-list the-list)
  (let ([n (length the-list)])
    (begin 
     (map displayln the-list)
     n)))


(define (display-notes)
  (begin
    (display-list (list-notes))))


; FIND NOTES
(define (find-notes-base key)
  (query-list pgc "SELECT note FROM notes WHERE note LIKE '%' || $1 || '%'" key))

(define (find-notes key)
  (display-list
     (find-notes-base key)))
  

  ;;;;;;;;;;;;;;;;;;;



(define help-strings 
  (list "---------------------------------------------"
        "-v          view notes                       "
        "---------------------------------------------" 
))

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

; > (string-concat '["one" "two" "three"] ":")
; "one:two:three:"
(define (string-concat strlist suffix)
  (string-trim
     (string-concat-aux "" strlist suffix)
     )
)

(define (display-help)
  (display (string-concat help-strings "\n"))
)

;; Process args

(define get-args 
   (vector->list 
      (current-command-line-arguments)
   )
)


(define (process-args args) 
  (cond 
     [(null? args) (display-help)]
     [(string=? (car args) "-v") (display-notes) ]
     [(string=? (car args) "-x") (println (string-append "Test: " (cadr args))) ]
     [else (find-notes (car args))]
  )
)

;; Main

(process-args get-args)