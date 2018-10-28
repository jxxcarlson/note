#! /usr/bin/env racket
#lang racket

(require racket/string)
(require racket/system)
(require gregor)


(define (date-string) (date->iso8601 (today)))

;; Files

(define data-path "/Users/carlson/dev/racket/note/")

(define (get-file-name-aux)
  (last
    (string-split
        (path->string 
           (find-system-path 'run-file) 
        )
        "/"
    )
  )
)

(define (get-filename extension)
  (add-extension (get-file-name-aux) extension))

(define (add-extension file-name extension)
  (string-append file-name extension))

(define (data-file-aux) 
  (get-filename ".txt")
)

(define (backup-file-aux)
  (get-filename ".txt.bak")
)

(define data-file (string-append data-path (data-file-aux)))

(define tmp-file (string-append data-path "tmp.txt"))

(define backup-file (string-append data-path (backup-file-aux)))

(define (get-data filename) 
  (file->string filename)
)

(define record-terminator "\n----\n")

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
  (let* 
    (
     [items-found (filter-string-list-many args (get-string-list data-file))] 
     [n-items-found (length items-found)]
    )
    (display-items items-found n-items-found)
   )
)  

(define (display-items items n-items)
  (display 
    (string-pad "=======\n" "\n=======\n"
      (string-append (string-concat  items "\n----\n") "\n" (number->string n-items))
    )
  )
)


(define (last-item args)
  (display 
     (string-pad "=======\n" "\n=======\n"
        (last (get-string-list data-file))
     )
  )
)
  
(define (display-data)
  (display  
    (string-concat  (get-string-list data-file)  "\n")
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

; > (string-concat '["one" "two" "three"] ":")
; "one:two:three:"
(define (string-concat strlist suffix)
  (string-trim
     (string-concat-aux "" strlist suffix)
     )
)

(define (random-element list)
  (car (shuffle list)))

(define (add-note args)
  (begin
    (save-string-guard args)
    (println (length (get-string-list data-file)))
  )
)

 

(define (save-string-guard args)
  (if (null? args)
    (display "-a option needs an argument")
    (save-string 
      (string-append
        (string-concat args " ") 
        " // "
        (date-string)
      )
    ))
)

;; ???

(define help-strings 
  (list "---------------------------------------------"
        "  -a ...    -- aadd new note"
        "  -aa ...   -- add new note using editor"
        "  -b        -- back up data file"
        "  -c        -- line count of data file"
        "  -d        -- location of data file"
        "  -e        -- edit data file"
        "  -l        -- show last item"
        "  -r        -- random line"
        "  -s        -- show all data"
        "  -v        -- view data"
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

(define edit-command
  (string-append "emacs " data-file))

(define edit-tmp-command
  (string-append "emacs " tmp-file)
)

(define append-tmp-file-command
  ; (string-append "cat " tmp-file " >>" data-file ";echo '----\n' >>" data-file ))
  (string-append "cat " tmp-file " >>" data-file " ; echo `date` >>" data-file " ;echo '----' >>" data-file ))


(define clear-tmp-file-command
  (string-append "rm " tmp-file))

(define (do-backup)
  (begin
    (system (string-append "cp " data-file " " backup-file))
    (println (length  (get-string-list data-file)))
  )
) 

(define read-command
  (string-append "more " data-file))

(define tail-command
  (string-append "tail " data-file))

(define (add-note-using-editor)
  (begin
    (system clear-tmp-file-command)
    (system edit-tmp-command)
    (system append-tmp-file-command)
    (println (length (get-string-list data-file)))
  )
  
)

; (save-string-guard (cdr args))

(define (process-args args) 
  (cond 
     [(null? args) (display-help)]
     [(string=? (car args) "-a") (add-note (cdr args)) ]
     [(string=? (car args) "-aa") (add-note-using-editor)  ]
     [(string=? (car args) "-b") (do-backup)  ]
     [(string=? (car args) "-c") (println (length  (get-string-list data-file)))  ]
     [(string=? (car args) "-d") (display-data-location)  ]
     [(string=? (car args) "-e") (system  edit-command)  ]
     [(string=? (car args) "-h") (display-help)]
     [(string=? (car args) "-l") (last-item args)  ]
     [(string=? (car args) "-r") (display (random-element (get-string-list data-file)))  ]
     [(string=? (car args) "-s") (display-data)  ]
     [(string=? (car args) "-v") (system read-command)  ]
     [(string=? (car args) "--test") (println backup-file)]
     [else (find-matches args)]
  )
)

;; Main

(process-args get-args)

