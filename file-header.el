;;; file-header.el --- Self design file header.                     -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Shen, Jen-Chieh
;; Created date 2018-12-24 16:49:42

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Self design file header.
;; Keyword: file header
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (s "1.12.0"))
;; URL: https://github.com/jcs090218/file-header

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
;; Self design file header.
;;

;;; Code:

(require 's)


(defgroup file-header nil
  "Self design file header."
  :prefix "file-header-"
  :group 'convenience
  :link '(url-link :tag "Repository" "https://github.com/jcs090218/file-header"))


(defcustom file-header-template-config-filepath "~/.emacs.jcs/template/template_config.properties"
  "File path ot template config properties."
  :type 'string
  :group 'file-header)


(defun file-header-get-string-from-file (filePath)
  "Return filePath's file content.
FILEPATH : file path."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun file-header-parse-ini (filePath)
  "Parse a .ini file.
FILEPATH : .ini file to parse."
  (let ((tmp-ini (file-header-get-string-from-file filePath))
        (tmp-ini-list '())
        (tmp-pair-list nil)
        (tmp-keyword "")
        (tmp-value "")
        (count 0))
    (setq tmp-ini (split-string tmp-ini "\n"))

    (dolist (tmp-line tmp-ini)
      ;; check not comment.
      (when (not (string-match-p "#" tmp-line))
        ;; Split it.
        (setq tmp-pair-list (split-string tmp-line "="))

        ;; Assign to temporary variables.
        (setq tmp-keyword (nth 0 tmp-pair-list))
        (setq tmp-value (nth 1 tmp-pair-list))

        ;; Check empty value.
        (when (and (not (string= tmp-keyword ""))
                   (not (equal tmp-value nil)))
          (let ((tmp-list '()))
            (push tmp-keyword tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))
          (let ((tmp-list '()))
            (push tmp-value tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))))
      (setq count (1+ count)))

    ;; return list.
    tmp-ini-list))

(defun file-header-swap-keyword-template (template-str)
  "Swap all keyword in template to proper information.
TEMPLATE-STR : template string data."
  (let ((tmp-ini-list '())
        (tmp-keyword "")
        (tmp-value "")
        (tmp-index 0))

    ;; parse and get the list of keyword and value.
    (setq tmp-ini-list (file-header-parse-ini file-header-template-config-filepath))

    (while (< tmp-index (length tmp-ini-list))

      (setq tmp-keyword (nth tmp-index tmp-ini-list))
      (setq tmp-value (nth (1+ tmp-index) tmp-ini-list))

      ;; Add `#' infront and behind the keyword.
      ;; For instance, `CREATOR' -> `#CREATOR#'.
      (setq tmp-keyword (concat "#" tmp-keyword))
      (setq tmp-keyword (concat tmp-keyword "#"))

      ;; NOTE(jenchieh): Check keyword exist before replacing
      ;; it. Or else it will cause `max-lisp-eval-depth' error.
      (when (string-match-p tmp-keyword template-str)

        ;; Check if the value is a function?
        (if (string-match-p "(" tmp-value)
            (progn
              ;; Remove `(' and `)', if is a function.
              (setq tmp-value (s-replace "(" "" tmp-value))
              (setq tmp-value (s-replace ")" "" tmp-value))

              (setq template-str (s-replace tmp-keyword
                                            (funcall (intern tmp-value))
                                            template-str)))
          (progn
            ;; Replace it normally with a string.
            (setq template-str (s-replace tmp-keyword
                                          tmp-value
                                          template-str)))))
      ;; Add 2 to skip keyword and value at the same time.
      (setq tmp-index (+ tmp-index 2))))

  ;; return itself.
  template-str)

(defun file-header-insert-template-by-file-path (filePath)
  "Swap all keywords then insert it to current buffer.
FILEPATH : file path to insert and swap keyword."
  (let ((template-str (file-header-get-string-from-file filePath)))
    (setq template-str (file-header-swap-keyword-template template-str))
    (insert template-str)))

(provide 'file-header)
;;; file-header.el ends here
