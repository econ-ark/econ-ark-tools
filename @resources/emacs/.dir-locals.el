;; add econ-ark macros to the standard ones provided by ams
;; Whenever a .tex file is opened, define the prettify symbols mapping

((nil . ((eval . (progn
                   (if (or (derived-mode-p 'latex-mode)
                           (derived-mode-p 'LaTeX-mode)
                           (derived-mode-p 'TeX-mode))
                       (message "Prettifying because current mode: %s" major-mode))
                   (when (or (derived-mode-p 'latex-mode)
                             (derived-mode-p 'LaTeX-mode)
                             (derived-mode-p 'TeX-mode))
                     (let ((symbols-file (expand-file-name "@resources/emacs/prettify-symbols-tex_add-econark-symbols.el")))
                       (if (not (file-exists-p symbols-file))
                           (display-warning 'local-tex 
                                          (format "Could not find symbols file: %s" symbols-file)
                                          :warning)
                         ;; else - file exists
                         (load symbols-file)
                         (set-buffer-file-coding-system 'utf-8)
                         (enable-local-tex-symbols)))
                     (setq-local prettify-symbols-alist nil)
                     (setq-local prettify-symbols-alist
                                 (if (boundp 'local-tex-symbols-alist)
                                     (append tex--prettify-symbols-alist
                                             local-tex-symbols-alist)
                                   tex--prettify-symbols-alist))
                     (setq prettify-symbols-unprettify-at-point 'right-edge)
                     (prettify-symbols-mode 1)))))))

