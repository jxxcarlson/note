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


(define (count-notes)
  (println 
     (query-maybe-value  pgc "SELECT COUNT(*) FROM notes")
  ))

(define (build-query-aux acc args)
  (if (null? args)
       acc
       (build-query-aux (string-append acc " AND " (car args)) (cdr args))
  ))

(define (build-query args)
  (build-query-aux (car args) (cdr args)))

; FIND NOTES

(define (replace-template param)
  (string-replace "(LOWER(note) LIKE '%' || LOWER($ARG) || '%')" "ARG" param))

(define query-note
  "SELECT note FROM notes WHERE (LOWER(note) LIKE '%' || LOWER($1) || '%')")

(define query-two-keys
  (build-query 
    (list query-note (replace-template "2"))))

(define query-three-keys
  (build-query 
    (list query-note 
          (replace-template "2")
          (replace-template "3")
    )))

(define query-four-keys
  (build-query 
    (list query-note 
          (replace-template "2")
          (replace-template "3")
          (replace-template "4")
    )))


(define (by-body keys)
  (cond 
    [(= (length keys) 1) (query-list pgc query-note (car keys))]
    [(= (length keys) 2)  (query-list pgc query-two-keys (car keys) (cadr keys))]
    [(= (length keys) 3) (query-list pgc query-three-keys (car keys) (cadr keys) (caddr keys))]
    [else (query-list pgc query-four-keys (car keys) (cadr keys) (caddr keys) (cadddr keys))]
  ))


(define (find-notes method keys)
  (display-list
     (method keys)))
  
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
        "note -a          add note. First line used as title"
        "note -c          count notes"
        "note -h          show help"
        "note -m          migrate data"
        "note -v          view notes"
        "note -x          experimental command"
        "note yada        show notes matching 'yada'"
        "note foo bar     show notes matching 'foo' and 'bar'"
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
     [(string=? (car args) "-c") (count-notes) ]
     [(string=? (car args) "-h") (display-help) ]
     [(string=? (car args) "-m") (migrate data-file) ]
     [(string=? (car args) "-v") (display-notes) ]
     [(string=? (car args) "-x") (println (length (get-string-list data-file)))]
     [else (find-notes by-body args)]
  )
)


;; Main

(process-args get-args)