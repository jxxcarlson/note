# NOTE

_Note_ is a Racket note-taking command-line tool.
Notes consist of a single line. To add a note, do
this:

```
$ note -a La di dah do day
```

To search for all notes containing `foo`, say
`note foo`. To search for all notes containing
`foo` and `bar`, say `note foo bar`. Etc.

For more information, say `note -h`.

## Installation

1. Do `git clone https://github.com/jxxcarlson/note.git`
   in some convenient directory on your machine.

2. Do `touch data.txt`

3. Edit line 9, `(define data-file "/Users/carlson/dev/racket/data.txt")`,
   so that it points to `data.txt`

4. In your `.profile`, create an alias pointng to `note.rkt`

5. In your currenct directory, do `source ~/.profile`

## Customization

The `note` tool is configured so that running `note -e` will
bring up the data file in emacs for editing. To use another
editor, modify this bit of code:

```
(define (edit-command)
  (string-append "emacs " data-file))
```

## Compilation

You can also compile this Racket script. Just do `raco exec note.rkt`.
The result will be a file `note`. Link to it instead of `note.rkt`
in your `.profile` file.
