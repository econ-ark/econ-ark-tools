(TeX-add-style-hook
 "econark-multibib"
 (lambda ()
   (TeX-run-style-hooks
    "ifthen"
    "etoolbox")
   (TeX-add-symbols
    '("econarkmultibib" 1)
    "filename")
   (LaTeX-add-bibliographies
    "system"))
 :latex)

