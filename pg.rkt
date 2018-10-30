#! /usr/bin/env racket
#lang racket

(require racket/string)
(require racket/system)
(require db)
(require db/util/datetime)
(require libuuid)


(define pgc (postgresql-connect #:user "carlson"
                      #:database "notes"))


(define (now) (seconds->date (current-seconds)))

(define (timestamp) (srfi-date->sql-timestamp (now)))


; (define describe-table (query-exec notes-connection "DESCRIBE TABLE notes"))

(define list-columns-query
  "SELECT * FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'notes'")


; CREATE RECORD
; CREATE RECORD
(define (insert-note title note)
  (query-exec
      pgc
      "INSERT INTO notes VALUES ($1, $2, $3, $4, $5)"
      (uuid-generate) (timestamp) (timestamp) title note
  ))



; LIST ALL RECORDS
(define (list-notes)
   (query-list pgc "select note from notes order by id"))

(define record-terminator "\n================\n")

(define (display-record record)
  (display (string-append record record-terminator))
)
(define (display-list the-list)
  (let ([n (length the-list)])
    (begin 
       (display "\n")
       (map display-record the-list)
       (println n)
       (display "\n")
    )
  )
)



(define (display-notes)
  (begin
    (display-list (list-notes))))


; FIND NOTES
(define (by-body key)
  (query-list pgc "SELECT note FROM notes WHERE LOWER(note) LIKE '%' || LOWER($1) || '%'" key))

(define (by-title key)
  (query-list pgc "SELECT note FROM LOWER(notes) WHERE title LIKE '%' || LOWER($1) || '%'" key))


(define (find-notes method key)
  (display-list
     (method key)))
  
;;;;;;;;;;;;


(define data-file "/Users/carlson/dev/racket/note/note.txt")

(define eor "\n----\n")

(define (get-data filename) 
  (file->string filename)
)

(define (get-string-list filename)
   (string-split 
      (get-data filename)
      eor
    )
)

(define (add-record body)
  (let* (
          [title (car (string-split body "\n"))]
        )
      (insert-note title body)
  )
)


(define (migrate filename)
  (map add-record (get-string-list filename)))

;;;;;;;;;;;;;;;;;;;


(define (add-note args)
  (if (null? args)
    (display "-a option needs an argument")
    (add-note-aux args)
  )
)


(define (add-note-aux args)
  (let* (
          [body (string-concat args " ")]
          [title (car (string-split body "\n"))]
        )
      (insert-note title body)
  )
)


(define help-strings 
  (list "---------------------------------------------"
        "db -a          add note. First line used as title"
        "db -h          show help"
        "db -m          migrate data"
        "db -t yada     show records with 'yada' in the title"
        "db -v          view notes   "
        "db -x          experimental command   "
        "db yada        show notes matching 'yada'    "
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
     [(string=? (car args) "-a") (add-note (cdr args)) ]
     [(string=? (car args) "-h") (display-help) ]
     [(string=? (car args) "-m") (migrate data-file) ]
     [(string=? (car args) "-t") (find-notes by-title (car args)) ]
     [(string=? (car args) "-v") (display-notes) ]
     [(string=? (car args) "-x") (println (length (get-string-list data-file)))]
     [else (find-notes by-body (car args))]
  )
)

;; Main

(process-args get-args)