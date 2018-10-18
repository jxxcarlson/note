#! /usr/bin/env racket
#lang racket

(require racket/string)
(require racket/system)

;; Files

(define data-file "/Users/carlson/dev/racket/note/data.txt")


(define (get-data filename) 
  (file->string filename)
)

(define record-terminator "\n--\n")

(define (get-string-list filename)
   (string-split 
      (get-data filename)
      record-terminator
    )
)

(define (append-item args)
  (string-append (get-data data-file) (car args) "\n")
)


(define (save-string str)
   (with-output-to-file data-file
     (lambda () (printf (string-append str record-terminator)))
     #:exists 'append #:mode 'text)
)

;; String lists

(define (string-contains-ci? whole part)
 (string-contains? (string-downcase whole) (string-downcase part)))

(define (contains-word? word phrase) (string-contains-ci? phrase word))

(define (filter-string-list key string-list) 
   (filter 
     (curry contains-word? key)
     string-list
   )
)

(define (string-pad before after str)
  (string-append before str after))

(define (find-matches args)
  (display 
    (string-pad "\n" "\n\n"
      (string-concat 
        (filter-string-list-many args (get-string-list data-file))
        "\n\n"
      )
    )
  )
)

(define (display-data)
  (display 
    (string-concat 
       (get-string-list data-file)
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

(define (random-element list)
  (car (shuffle list)))

(define (save-string-guard args)
  (if (null? args)
    (display "-a option needs an argument")
    (save-string (string-concat args " ") ))
)

;; ???

(define help-strings 
  (list "---------------------------------------------"
        "  -a x y z  -- append x y z to the data-file"
        "  -c        -- line count of data file"
        "  -e        -- edit data file"
        "  -l        -- location of data file"
        "  -r        -- random line"
        "  -s        -- show all data"
        "  x         -- show lines containging x"
        "  x y       -- show lines containg x and y"
        "---------------------------------------------" 
))

(define (display-help)
  (display (string-concat help-strings "\n"))
)

;; Process args

(define get-args 
   (vector->list 
      (current-command-line-arguments)
   )
)

(define (display-data-location)
  (display data-file)
)

(define (edit-command)
  (string-append "emacs " data-file))


(define (process-args args) 
  (cond 
     [(null? args) (display-help)]
     [(string=? (car args) "-a") (save-string-guard (cdr args))  ]
     [(string=? (car args) "-c") (println (length  (get-string-list data-file)))  ]
     [(string=? (car args) "-l") (display-data-location)  ]
     [(string=? (car args) "-e") (system  (edit-command))  ]
     [(string=? (car args) "-h") (display-help)]
     [(string=? (car args) "-r") (display (random-element (get-string-list data-file)))  ]
     [(string=? (car args) "-s") (display-data)  ]
     [else (find-matches args)]
  )
)

;; Main

(process-args get-args)
