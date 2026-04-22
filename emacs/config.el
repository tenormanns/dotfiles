;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ==============================
;; Core
;; ==============================

(setq doom-theme                'doom-gruvbox
      display-line-numbers-type t
      org-directory             "~/org/")

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose               nil)

;; ==============================
;; Org Agenda
;; ==============================

(after! org
  (setq org-agenda-files '("~/org"))

  (setq org-capture-templates
        `(("t" "TODO" entry
           (file+headline ,(expand-file-name "inbox.org" org-directory) "Tasks")
           "* TODO %?\n%i\n%a")))

  (setq org-latex-pdf-process
        '("latexmk -pdflatex='pdflatex -interaction nonstopmode' -pdf -bibtex -f %f"))

  (setq org-ref-default-bibliography
        (list (expand-file-name "~/org/refs/biblio.bib"))))

;; ==============================
;; Org-roam
;; ==============================

(after! org-roam
  (setq org-roam-directory (file-truename "~/org/org-roam/"))
  (setq org-roam-capture-templates
        '(("n" "Personal Note" plain "%?"
           :if-new (file+head "notes/${slug}.org"
                              "#+title: ${title}\n#+filetags: :personal:\n")
           :unnarrowed t)
          ("u" "University Note" plain "%?"
           :if-new (file+head "university/class/${slug}.org"
                              "#+title: ${title}\n#+filetags: :university:\n")
           :unnarrowed t)
          ("b" "Book Note" plain
           "* Summary\n\n* Key Ideas\n\n* Quotes\n\n%?"
           :if-new (file+head "books/${slug}.org"
                              "#+title: ${title}\n#+filetags: :book:\n")
           :unnarrowed t)
          ("r" "Research Paper" plain "%?"
           :target (file+head "~/org/org-roam/refs/${citekey}.org"
                              "#+title: ${title}
#+filetags: :research:paper:
#+created: %u
#+modified:

* ${title}
:PROPERTIES:
:CITEKEY: ${citekey}
:Tags:
:Start: %u
:Fin:
:END:

** Actions

** Key Ideas

** Notes
")
           :unnarrowed t))))

;; ==============================
;; Bibliography
;; orb var MUST be set before use-package!
;; to prevent ORB claiming SPC n r
;; ==============================

(setq orb-insert-link-no-default-keybinding t)

(use-package! org-ref
  :config
  (setq bibtex-completion-bibliography '("~/org/refs/biblio.bib")
        bibtex-completion-notes-path    "~/org/org-roam/refs"
        bibtex-completion-pdf-field     "file"
        bibtex-completion-pdf-open-function
        ;; Detect OS and use the right opener
        (lambda (fpath)
          (call-process
           (cond ((eq system-type 'darwin)  "open")       ; macOS
                 ((eq system-type 'gnu/linux) "xdg-open") ; Arch Linux
                 (t "open"))                               ; fallback
           nil 0 nil fpath))))

(use-package! ivy-bibtex
  :after org-ref)

(use-package! org-roam-bibtex
  :after (org-roam org-ref)
  :config
  (require 'org-ref)
  (org-roam-bibtex-mode +1))

;; ==============================
;; Note Capture Dispatch
;; ==============================

(defun my/note-dispatch ()
  "Choose a note type and open the matching org-roam capture template.
Switches to *scratch* first to avoid org-element errors when called
from a non-org buffer like the Doom dashboard."
  (interactive)
  (with-current-buffer (get-buffer-create "*scratch*")
    (let* ((choices '(("Personal Note"   . "n")
                      ("University Note" . "u")
                      ("Book Note"       . "b")))
           (pick (completing-read "Note type: " (mapcar #'car choices) nil t))
           (key  (cdr (assoc pick choices))))
      (org-roam-capture- :node (org-roam-node-read) :keys key))))

;; ==============================
;; Keybindings
;; ==============================

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find node"        "f" #'org-roam-node-find
       :desc "Insert node link" "i" #'org-roam-node-insert
       :desc "Capture note"     "c" #'my/note-dispatch
       :desc "Capture TODO"     "t" #'org-capture
       :desc "Capture paper"    "R" #'orb-insert-link))
