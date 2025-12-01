;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ========================
;; Basic Doom Configuration
;; ========================

(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)
(setq org-directory "~/org/")

;; ===================
;; Org-Agenda Settings
;; ===================

(after! org
  (setq org-agenda-files (directory-files-recursively "~/org/" "\\.org$")))

;; ==============================
;; Org-roam Configuration
;; ==============================

(after! org-roam
  ;; Org-roam Directory
  (setq org-roam-directory (file-truename "~/org/org-roam/"))

  ;; Org-roam Capture Templates
  (setq org-roam-capture-templates
        '(("n" "Generic Note" plain "%?"
           :if-new (file+head "notes/${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("u" "University Note" plain "%?"
           :if-new (file+head "unsw/y1t2/${slug}.org"
                              "#+title: ${title}\n#+filetags: :university:\n")
           :unnarrowed t)
          ("b" "Book Note" plain "%?"
           :if-new (file+head "books/${slug}.org"
                              "#+title: ${title}\n#+filetags: :book:\n")
           :unnarrowed t)
          ("p" "Personal Note" plain "%?"
           :if-new (file+head "personal/${slug}.org"
                              "#+title: ${title}\n#+filetags: :personal:\n")
           :unnarrowed t))))

;; ==============================
;; Custom Functions (Defined First)
;; ==============================

(defun my/org-capture-note-dispatch ()
  "Prompt for note type and launch corresponding org-roam-capture template."
  (interactive)
  (let* ((note-type (completing-read "Note type: " '("Generic" "University" "Book" "Personal") nil t))
         (template-key (pcase note-type
                         ("Generic" "n")
                         ("University" "u")
                         ("Book" "b")
                         ("Personal" "p"))))
    (org-roam-capture- :node (org-roam-node-read) :keys template-key)))

(defun my/org-daily-plan ()
  "Open or create a daily plan note for a selected date using a calendar picker."
  (interactive)
  ;; Prompt user with a date picker
  (let* ((time (org-read-date nil t nil "Select date (default: today): "))
         (date-str (format-time-string "%Y-%m-%d" time))
         (title (format "Daily Plan - %s" date-str))
         (file-path (expand-file-name (format "plans/%s.org" date-str) org-roam-directory)))
    ;; If file already exists, just open it
    (if (file-exists-p file-path)
        (find-file file-path)
      ;; Otherwise, create it manually (not using template that overrides date)
      (progn
        (make-directory (file-name-directory file-path) t)
        (find-file file-path)
        (insert (format "#+title: %s\n#+filetags: :daily:plan:\n\n" title))
        (save-buffer)
        (message "Created new daily plan for %s" date-str)))))

;; ==============================
;; Org Capture Configuration
;; ==============================

(after! org
  ;; Unified Org Capture Menu
  (setq org-capture-templates
        `(("t" "TODO" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Tasks")
           "* TODO %?\n  %i\n  %a")

          ("n" "Note" plain
           (function my/org-capture-note-dispatch)
           "")

          ("d" "Daily Plan" plain
           (function my/org-daily-plan)
           ""))))

;; ==============================
;; Keybindings
;; ==============================

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find roam node"   "f" #'org-roam-node-find
       :desc "Insert roam node" "i" #'org-roam-node-insert
       :desc "Capture menu"     "c" #'org-capture
       :desc "Daily Plan"       "d" #'my/org-daily-plan))
