(TeX-add-style-hook
 "econark"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("scrartcl" "fontsize=12pt" "english" "numbers=noenddot" "captions=tableheading" "captions=nooneline" "headings=optiontocandhead")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "setspace"
    "scrartcl"
    "scrartcl10")
   (LaTeX-add-counters
    "IncludeTitlePage"))
 :latex)

