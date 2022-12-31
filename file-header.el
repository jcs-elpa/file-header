;;; file-header.el --- Highly customizable self design file header  -*- lexical-binding: t; -*-

;; Copyright (C) 2018-2023  Shen, Jen-Chieh
;; Created date 2018-12-24 16:49:42

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs-elpa/file-header
;; Version: 0.1.2
;; Package-Requires: ((emacs "28.1"))
;; Keywords: convenience file header

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Highly customizable self design file header.
;;

;;; Code:

(require 'cl-lib)
(require 'thingatpt)

(defgroup file-header nil
  "Highly customizable self design file header."
  :prefix "file-header-"
  :group 'convenience
  :link '(url-link :tag "Repository" "https://github.com/jcs-elpa/file-header"))

(defcustom file-header-template-config-filepath
  (concat user-emacs-directory "templates/config.properties")
  "File path ot template config properties."
  :type 'string
  :group 'file-header)

(defcustom file-header-template-dir
  (concat user-emacs-directory "templates/")
  "Template directory path for file headers."
  :type 'string
  :group 'file-header)

(defcustom file-header-annotation-ratio 2.5
  "Ratio align from the right to display `completin-read' annotation."
  :type 'float
  :group 'file-header)

;;
;; (@* "Util" )
;;

(defun file-header--2str (obj)
  "Convert OBJ to string."
  (format "%s" obj))

(defun file-header--file-content (path)
  "Return PATH's file content."
  (if (file-exists-p path)
      (with-temp-buffer (insert-file-contents path) (buffer-string))
    ""))

(defun file-header--f-join (&rest args)
  "Concatenate ARGS to path."
  (cl-reduce (lambda (a b) (expand-file-name b a)) args))

(defun file-header--seq-str-max (sequence)
  "Return max length in SEQUENCE of strings."
  (let ((result 0))
    (mapc (lambda (elm) (setq result (max result (length (file-header--2str elm))))) sequence)
    result))

;;;###autoload
(defun file-header-template-string (path)
  "Read template from PATH to string."
  (file-header--file-content (file-header--f-join file-header-template-dir path)))

(defun file-header--completing-frame-offset (options)
  "Return frame offset while `completing-read'.

Argument OPTIONS ia an alist use to calculate the frame offset."
  (max (file-header--seq-str-max (if (consp (car options))
                                     (mapcar #'cdr options)
                                   options))
       (/ (frame-width) file-header-annotation-ratio)))

;;
;; (@* "Core" )
;;

(defun file-header--insert (lang file)
  "Insert file header by LANG and it's FILE path."
  (file-header-insert-template-by-file-path (file-header--f-join file-header-template-dir lang file)))

;;;###autoload
(defmacro file-header-defins (name lang file &optional doc-string)
  "Define insertfion function with NAME.

Arguments LANG and FILE see function `file-header--insert' for more information.

Optional argument DOC-STRING is optional document string."
  (declare (doc-string 4) (indent 3))
  (or name (error "Cannot define '%s' as a function" name))
  `(defun ,name nil ,doc-string (file-header--insert ,lang ,file)))

;;;###autoload
(defmacro file-header-defsrc (name prompt options &rest body)
  "Define file header source function with NAME.

Arugment PROMPT is the question to ask for completion; argument OPTIONS is used
for completion read.

The rest of the arguments BODY are use to fill insertion's condition."
  (declare (indent 2))
  (or name (error "Cannot define '%s' as a function" name))
  `(defun ,name ()
     (interactive)
     (let* ((prev-buffer (current-buffer))
            (is-alist (consp (nth 0 ,options)))
            (offset (file-header--completing-frame-offset ,options))
            (source
             (completing-read
              ,prompt
              (lambda (string predicate action)
                (with-current-buffer prev-buffer
                  (if (eq action 'metadata)
                      `(metadata
                        (display-sort-function . ,#'identity)
                        (annotation-function
                         . ,(lambda (cand)
                              (concat (propertize " " 'display `((space :align-to (- right ,offset))))
                                      (cdr (assoc cand ,options))))))
                    (complete-with-action action ,options string predicate))))
              nil t))
            (index (cl-position source (if is-alist (mapcar #'car ,options)
                                         ,options)
                                :test 'string=)))
       ,@body)))

(defun file-header--parse-ini (path)
  "Parse a .ini file from PATH."
  (let* ((tmp-ini (file-header--file-content path))
         (tmp-ini (split-string tmp-ini "\n"))
         (tmp-keyword "") (tmp-value "")
         (count 0) tmp-ini-list tmp-pair-list)

    (dolist (tmp-line tmp-ini)
      ;; check not comment
      (unless (string-match-p "#" tmp-line)
        ;; Split it
        (setq tmp-pair-list (split-string tmp-line "="))

        ;; Assign to temporary variables
        (setq tmp-keyword (nth 0 tmp-pair-list)
              tmp-value (nth 1 tmp-pair-list))

        ;; Check empty value
        (when (and (not (string= tmp-keyword "")) tmp-value)
          (let (tmp-list)
            (push tmp-keyword tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))
          (let (tmp-list)
            (push tmp-value tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))))
      (cl-incf count))

    ;; return list
    tmp-ini-list))

;;;###autoload
(defun file-header-swap-keyword-template (template-str)
  "Swap all keyword in TEMPLATE-STR to proper information."
  (let ((tmp-keyword "") (tmp-value "") (tmp-index 0) tmp-ini-list)
    ;; parse and get the list of keyword and value
    (setq tmp-ini-list (file-header--parse-ini file-header-template-config-filepath))

    (while (< tmp-index (length tmp-ini-list))
      (setq tmp-keyword (nth tmp-index tmp-ini-list)
            tmp-value (nth (1+ tmp-index) tmp-ini-list))

      ;; Add `#' infront and behind the keyword; for instance, `CREATOR' to `#CREATOR#'
      (setq tmp-keyword (format "#%s#" tmp-keyword))

      ;; NOTE: Check keyword exist before replacing it
      ;; Or else it will cause `max-lisp-eval-depth' error
      (when (string-match-p tmp-keyword template-str)
        ;; Check if the value is a snippet
        (if (string-match-p "`" tmp-value)
            ;; Remove ` for evaluation
            (setq tmp-value (string-replace "`" "" tmp-value)
                  template-str (string-replace tmp-keyword
                                               (eval (thing-at-point--read-from-whole-string tmp-value))
                                               template-str))
          ;; Replace it normally with a string
          (setq template-str (string-replace tmp-keyword
                                             tmp-value
                                             template-str))))
      ;; Add 2 to skip keyword and value at the same time
      (cl-incf tmp-index 2)))

  ;; return itself.
  template-str)

;;;###autoload
(defun file-header-get-template-by-file-path (path)
  "Swap all keywords then return it from the PATH."
  (file-header-swap-keyword-template (file-header--file-content path)))

;;;###autoload
(defun file-header-insert-template-by-file-path (path)
  "Swap all keywords from the PATH then insert it to current buffer."
  (insert (file-header-get-template-by-file-path path)))

(provide 'file-header)
;;; file-header.el ends here
