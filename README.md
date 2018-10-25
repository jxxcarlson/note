# NOTE

Note is a command-line tool for taking notes.
It is written in Racket.

## Adding a note

To add a note, do either

(1)

```
$ note -a La di dah do day
```

and then type <RETURN>. Or

(2)

```
$ note -aa
```

This command will open an editor, e.g. emacs. Write
your note, then save and exit.

## Searching for a note

To search for all notes containing `foo`, say
`note foo`. To search for all notes containing
`foo` and `bar`, say `note foo bar`. Etc.

## Help

For more information, say `note -h`.

## Installation

1. Do `git clone https://github.com/jxxcarlson/note.git`
   in some convenient directory on your machine. Let's
   imagine that it is in `Users/turing/stuff/`. You will
   find the file `note.rkt`, which is the source text
   for the `note` application.

2. Edit line 9, `(define data-path "/Users/turing/stuff/")`,
   so that it points to the path in (1)

3. By default, the `note` application is configured
   to use emacs as its editor. To used a different
   editor, modify line 176-7:

```
(define (edit-command)
  (string-append "emacs " data-file))
```

3. Compile the application using `raco exe note.rkt`.
   This will produce the file `note`.

4. In your `.profile`, create an alias pointng to `note`

5. In your current directory, do `source ~/.profile`

## Notes

- Your data is in `note.txt`

- Use `note -b` to make a backup of your data. It
  resides in `note.txt.bak`

- Suppose you want to have an app for some other purpose,
  say, a diary. Do (1) `cp note.rkt diary.rkt`
  (2) `raco exe diary.rkt` (3) Then, in your `profile`,
  make an alias pointing to `diary`.

- Data format. The data for `note` is in the file `note.txt`.
  Individual notes are separated by `"\n----\n"`, as defined
  in line 46: `(define record-terminator "\n----\n")`
