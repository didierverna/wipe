;;; wipe.el --- Whitespace Inspection and Pruning for Emacs

;; Copyright (C) 2013 Didier Verna
;; Copyright (C) 2000-2013 Free Software Foundation, Inc.

;; Author: Didier Verna <didier@didierverna.net>
;; Maintainer: Didier Verna <didier@didierverna.net>
;; Keywords: data, wp
;; Version: 0.1
;; X-URL: http://www.lrde.epita.fr/~didier/software/emacs/#wipe

;; This file is part of Wipe.

;; Wipe is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Wipe is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Wipe.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Introduction
;; ------------
;;
;; This package is a minor mode to visualize blanks (TAB, (HARD) SPACE
;; and NEWLINE).
;;
;; Wipe uses two ways to visualize blanks: faces and display table.
;;
;; * Faces are used to highlight the background with a color.
;;   Wipe uses font-lock to highlight blank characters.
;;
;; * Display table changes the way a character is displayed, that is,
;;   it provides a visual mark for characters, for example, at the end
;;   of line (?\xB6), at SPACEs (?\xB7) and at TABs (?\xBB).
;;
;; The `wipe-file-style', `wipe-mode-style' and
;; `wipe-style' variables select which way blanks are
;; visualized.
;;
;; Note that when Wipe is turned on, Wipe saves the
;; font-lock state, that is, if font-lock is on or off.  And
;; Wipe restores the font-lock state when it is turned off.  So,
;; if Wipe is turned on and font-lock is off, Wipe also
;; turns on the font-lock to highlight blanks, but the font-lock will
;; be turned off when Wipe is turned off.  Thus, turn on
;; font-lock before Wipe is on, if you want that font-lock
;; continues on after Wipe is turned off.
;;
;; When Wipe is on, it takes care of highlighting some special
;; characters over the default mechanism of `nobreak-char-display'
;; (which see) and `show-trailing-whitespace' (which see).
;;
;; The trailing spaces are not highlighted while point is at end of line.
;; Also the spaces at beginning of buffer are not highlighted while point is at
;; beginning of buffer; and the spaces at end of buffer are not highlighted
;; while point is at end of buffer.
;;
;; There are two ways of using Wipe: local and global.
;;
;; * Local Wipe affects only the current buffer.
;;
;; * Global Wipe affects all current and future buffers.  That
;;   is, if you turn on global Wipe and then create a new
;;   buffer, the new buffer will also have Wipe on.  The
;;   `wipe-global-modes' variable controls which major-mode will
;;   be automagically turned on.
;;
;; You can mix the local and global usage without any conflict.  But
;; local Wipe has priority over global Wipe.  Wipe
;; mode is active in a buffer if you have enabled it in that buffer or
;; if you have enabled it globally.
;;
;; When global and local Wipe are on:
;;
;; * if local Wipe is turned off, Wipe is turned off for
;;   the current buffer only.
;;
;; * if global Wipe is turned off, Wipe continues on only
;;   in the buffers in which local Wipe is on.
;;
;; To use Wipe, insert in your ~/.emacs:
;;
;;    (require 'wipe)
;;
;; Or autoload at least one of the commands`wipe-mode',
;; `wipe-toggle-options', `global-wipe-mode' or
;; `global-wipe-toggle-options'.  For example:
;;
;;    (autoload 'wipe-mode "wipe"
;;      "Toggle Wipe mode." t)
;;    (autoload 'wipe-toggle-options "wipe"
;;      "Toggle local `wipe-mode' options." t)
;;
;;
;; Using Wipe
;; ----------------
;;
;; There is no problem if you mix local and global minor mode usage.
;;
;; * LOCAL Wipe:
;;    + To toggle Wipe options locally, type:
;;
;;         M-x wipe-toggle-options RET
;;
;;    + To activate Wipe locally, type:
;;
;;         C-u 1 M-x wipe-mode RET
;;
;;    + To deactivate Wipe locally, type:
;;
;;         C-u 0 M-x wipe-mode RET
;;
;;    + To toggle Wipe locally, type:
;;
;;         M-x wipe-mode RET
;;
;; * GLOBAL Wipe:
;;    + To toggle Wipe options globally, type:
;;
;;         M-x global-wipe-toggle-options RET
;;
;;    + To activate Wipe globally, type:
;;
;;         C-u 1 M-x global-wipe-mode RET
;;
;;    + To deactivate Wipe globally, type:
;;
;;         C-u 0 M-x global-wipe-mode RET
;;
;;    + To toggle Wipe globally, type:
;;
;;         M-x global-wipe-mode RET
;;
;; There are also the following useful commands:
;;
;; `wipe-newline-mode'
;;    Toggle NEWLINE minor mode visualization ("nl" on mode line).
;;
;; `global-wipe-newline-mode'
;;    Toggle NEWLINE global minor mode visualization ("NL" on mode line).
;;
;; `wipe-report'
;;    Report some blank problems in buffer.
;;
;; `wipe-report-region'
;;    Report some blank problems in a region.
;;
;; `wipe-cleanup'
;;    Cleanup some blank problems in all buffer or at region.
;;
;; `wipe-cleanup-region'
;;    Cleanup some blank problems at region.
;;
;; The problems, which are cleaned up, are:
;;
;; 1. empty lines at beginning of buffer.
;; 2. empty lines at end of buffer.
;;    If Wipe style includes the value `empty', remove all
;;    empty lines at beginning and/or end of buffer.
;;
;; 3. 8 or more SPACEs at beginning of line.
;;    If Wipe style includes the value `indentation':
;;    replace 8 or more SPACEs at beginning of line by TABs, if
;;    `indent-tabs-mode' is non-nil; otherwise, replace TABs by
;;    SPACEs.
;;    If Wipe style includes the value `indentation::tab',
;;    replace 8 or more SPACEs at beginning of line by TABs.
;;    If Wipe style includes the value `indentation::space',
;;    replace TABs by SPACEs.
;;
;; 4. SPACEs before TAB.
;;    If Wipe style includes the value `space-before-tab':
;;    replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
;;    otherwise, replace TABs by SPACEs.
;;    If Wipe style includes the value
;;    `space-before-tab::tab', replace SPACEs by TABs.
;;    If Wipe style includes the value
;;    `space-before-tab::space', replace TABs by SPACEs.
;;
;; 5. SPACEs or TABs at end of line.
;;    If Wipe style includes the value `trailing', remove all
;;    SPACEs or TABs at end of line.
;;
;; 6. 8 or more SPACEs after TAB.
;;    If Wipe style includes the value `space-after-tab':
;;    replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
;;    otherwise, replace TABs by SPACEs.
;;    If Wipe style includes the value `space-after-tab::tab',
;;    replace SPACEs by TABs.
;;    If Wipe style includes the value
;;    `space-after-tab::space', replace TABs by SPACEs.
;;
;;
;; Hooks
;; -----
;;
;; Wipe has the following hook variables:
;;
;; `wipe-mode-hook'
;;    It is evaluated always when Wipe is turned on locally.
;;
;; `global-wipe-mode-hook'
;;    It is evaluated always when Wipe is turned on globally.
;;
;; `wipe-load-hook'
;;    It is evaluated after Wipe package is loaded.
;;
;;
;; Options
;; -------
;;
;; Below it's shown a brief description of Wipe options, please,
;; see the options declaration in the code for a long documentation.
;;
;; `wipe-file-style'
;; `wipe-mode-style'
;; `wipe-style'		Specify which kind of blank is
;;				visualized.
;;
;; `wipe-space'		Face used to visualize SPACE.
;;
;; `wipe-hspace'		Face used to visualize HARD SPACE.
;;
;; `wipe-tab'		Face used to visualize TAB.
;;
;; `wipe-newline'		Face used to visualize NEWLINE char
;;				mapping.
;;
;; `wipe-trailing'	Face used to visualize trailing
;;				blanks.
;;
;; `wipe-line'		Face used to visualize "long" lines.
;;
;; `wipe-space-before-tab'	Face used to visualize SPACEs
;;					before TAB.
;;
;; `wipe-indentation'	Face used to visualize 8 or more
;;				SPACEs at beginning of line.
;;
;; `wipe-empty'		Face used to visualize empty lines at
;;				beginning and/or end of buffer.
;;
;; `wipe-space-after-tab'	Face used to visualize 8 or more
;;				SPACEs after TAB.
;;
;; `wipe-space-regexp'	Specify SPACE characters regexp.
;;
;; `wipe-hspace-regexp'	Specify HARD SPACE characters regexp.
;;
;; `wipe-tab-regexp'	Specify TAB characters regexp.
;;
;; `wipe-trailing-regexp'	Specify trailing characters regexp.
;;
;; `wipe-space-before-tab-regexp'	Specify SPACEs before TAB
;;					regexp.
;;
;; `wipe-indentation-regexp'	Specify regexp for 8 or more
;;					SPACEs at beginning of line.
;;
;; `wipe-empty-at-bob-regexp'	Specify regexp for empty lines
;;					at beginning of buffer.
;;
;; `wipe-empty-at-eob-regexp'	Specify regexp for empty lines
;;					at end of buffer.
;;
;; `wipe-space-after-tab-regexp'	Specify regexp for 8 or more
;;					SPACEs after TAB.
;;
;; `wipe-line-column'	Specify column beyond which the line
;;				is highlighted.
;;
;; `wipe-display-mappings'	Specify an alist of mappings
;;					for displaying characters.
;;
;; `wipe-global-modes'	Modes for which global
;;				`wipe-mode' is automagically
;;				turned on.
;;
;; `wipe-file-action'
;; `wipe-mode-action'
;; `wipe-action'		Specify which action is taken when a
;;				buffer is visited or written.
;;
;;
;; Acknowledgments
;; ---------------
;;
;; Wipe started as a fork of Emacs whitespace.el in version 13.2.2.
;; Whitespace.el itself has a long history of contributors, which see.

;; Transition from Whitespace to Wipe:
;; - s/whitespace/wipe


;;; Code:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User Variables:


;;; Interface to the command system


(defgroup wipe nil
  "Whitespace Inspection and Pruning for Emacs."
  :group 'convenience)


(defconst wipe-style-custom-type
  '(repeat :tag "Kind of Blank"
	   (choice :tag "Kind of Blank Face"
		   (const :tag "(Face) Face visualization" face)
		   (const :tag "(Face) Trailing TABs, SPACEs and HARD SPACEs"
			  trailing)
		   (const :tag "(Face) SPACEs and HARD SPACEs" spaces)
		   (const :tag "(Face) TABs" tabs)
		   (const :tag "(Face) Lines" lines)
		   (const :tag "(Face) SPACEs before TAB" space-before-tab)
		   (const :tag "(Face) NEWLINEs" newline)
		   (const :tag "(Face) Indentation SPACEs" indentation)
		   (const :tag "(Face) Empty Lines At BOB And/Or EOB" empty)
		   (const :tag "(Face) SPACEs after TAB" space-after-tab)
		   (const :tag "(Mark) SPACEs and HARD SPACEs" space-mark)
		   (const :tag "(Mark) TABs" tab-mark)
		   (const :tag "(Mark) NEWLINEs" newline-mark)))
  ;; Custom type specification for Wipe styles. Used in
  ;; WIPE-FILE-STYLE, WIPE-MODE-STYLE and
  ;; WIPE-STYLE.
  )

(defcustom wipe-file-style nil
  "Specify which kind of blank is visualized for specific files.

This is a list of elements of the form (REGEXP STYLE...) where
REGEXP is matched against file names.  For a list of possible
STYLEs, see `wipe-style'.

Wipe determines which style to use on a specific buffer by
trying a match from this variable, then from
`wipe-mode-style' and then by falling back to
`wipe-style'."
  :type `(repeat (cons :value ("")
		       (regexp :tag "File Name Matching")
		       ,wipe-style-custom-type))
  :version "24.3"
  :group 'wipe)

(defcustom wipe-mode-style nil
  "Specify which kind of blank is visualized for specific major modes.

This is a list of elements of the form (MODE STYLE...) where MODE
is a major mode name.  For a list of possible STYLEs, see
`wipe-style'.

Wipe determines which style to use on a specific buffer by
trying a match from `wipe-file-style', then from this
variable and then by falling back to `wipe-style'."
  :type `(repeat (cons :value (fundamental-mode)
		       (symbol :tag "Major Mode")
		       ,wipe-style-custom-type))
  :version "24.3"
  :group 'wipe)

(defcustom wipe-style
  '(face
    tabs spaces trailing lines space-before-tab newline
    indentation empty space-after-tab
    space-mark tab-mark newline-mark)
  "Specify which kind of blank is visualized.

It's a list containing some or all of the following values:

   face		enable all visualization via faces (see below).

   trailing		trailing blanks are visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   tabs		TABs are visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   spaces		SPACEs and HARD SPACEs are visualized via
			faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   lines		lines which have columns beyond
			`wipe-line-column' are highlighted via
			faces.
			Whole line is highlighted.
			It has precedence over `lines-tail' (see
			below).
			It has effect only if `face' (see above)
			is present in Wipe style.

   lines-tail		lines which have columns beyond
			`wipe-line-column' are highlighted via
			faces.
			But only the part of line which goes
			beyond `wipe-line-column' column.
			It has effect only if `lines' (see above)
			is not present in Wipe style
			and if `face' (see above) is present in
			Wipe style.

   newline		NEWLINEs are visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   empty		empty lines at beginning and/or end of buffer
			are visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   indentation::tab	8 or more SPACEs at beginning of line are
			visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   indentation::space	TABs at beginning of line are visualized via
			faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   indentation		8 or more SPACEs at beginning of line are
			visualized, if `indent-tabs-mode' (which see)
			is non-nil; otherwise, TABs at beginning of
			line are visualized via faces.
			It has effect only if `face' (see above)
			is present in Wipe style.

   space-after-tab::tab	8 or more SPACEs after a TAB are
				visualized via faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-after-tab::space	TABs are visualized when 8 or more
				SPACEs occur after a TAB, via faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-after-tab		8 or more SPACEs after a TAB are
				visualized, if `indent-tabs-mode'
				(which see) is non-nil; otherwise,
				the TABs are visualized via faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-before-tab::tab	SPACEs before TAB are visualized via
				faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-before-tab::space	TABs are visualized when SPACEs occur
				before TAB, via faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-before-tab		SPACEs before TAB are visualized, if
				`indent-tabs-mode' (which see) is
				non-nil; otherwise, the TABs are
				visualized via faces.
				It has effect only if `face' (see above)
				is present in Wipe style.

   space-mark		SPACEs and HARD SPACEs are visualized via
			display table.

   tab-mark		TABs are visualized via display table.

   newline-mark	NEWLINEs are visualized via display table.

Any other value is ignored.

If nil, don't visualize TABs, (HARD) SPACEs and NEWLINEs via faces and
via display table.

There is an evaluation order for some values, if they are
present, for example if indentation, indentation::tab and/or
indentation::space are included.  The evaluation order for these
values is:

 * For indentation:
   1. indentation
   2. indentation::tab
   3. indentation::space

 * For SPACEs after TABs:
   1. space-after-tab
   2. space-after-tab::tab
   3. space-after-tab::space

 * For SPACEs before TABs:
   1. space-before-tab
   2. space-before-tab::tab
   3. space-before-tab::space

So, for example, if indentation and indentation::space are
included, the indentation value is evaluated instead of
indentation::space value.

One reason for not visualize spaces via faces (if `face' is not
included in Wipe style) is to use exclusively for
cleaning up a buffer.  See `wipe-cleanup' and
`wipe-cleanup-region' for documentation.

Wipe determines which style to use on a specific buffer by
trying a match from `wipe-file-style', then from
`wipe-mode-style' and then by falling back to this
variable.

See also `wipe-display-mappings' for documentation."
  :type wipe-style-custom-type
  :group 'wipe)

(defun wipe-style ()
  "Determine which style to use on current buffer."
  (let (match)
    (when buffer-file-name
      (let ((styles wipe-file-style)
	    style)
	(while (and (not match) (setq style (pop styles)))
	  (when (string-match (car style) buffer-file-name)
	    (setq match style)))))
    (unless match
      (setq match (assoc major-mode wipe-mode-style)))
    (if match
	(cdr match)
      wipe-style)))


(defcustom wipe-space 'wipe-space
  "Symbol face used to visualize SPACE.

Used when Wipe style includes the value `spaces'."
  :type 'face
  :group 'wipe)


(defface wipe-space
  '((((class color) (background dark))
     :background "grey20"      :foreground "darkgray")
    (((class color) (background light))
     :background "LightYellow" :foreground "lightgray")
    (t :inverse-video t))
  "Face used to visualize SPACE."
  :group 'wipe)


(defcustom wipe-hspace 'wipe-hspace
  "Symbol face used to visualize HARD SPACE.

Used when Wipe style includes the value `spaces'."
  :type 'face
  :group 'wipe)


(defface wipe-hspace		; 'nobreak-space
  '((((class color) (background dark))
     :background "grey24"        :foreground "darkgray")
    (((class color) (background light))
     :background "LemonChiffon3" :foreground "lightgray")
    (t :inverse-video t))
  "Face used to visualize HARD SPACE."
  :group 'wipe)


(defcustom wipe-tab 'wipe-tab
  "Symbol face used to visualize TAB.

Used when Wipe style includes the value `tabs'."
  :type 'face
  :group 'wipe)


(defface wipe-tab
  '((((class color) (background dark))
     :background "grey22" :foreground "darkgray")
    (((class color) (background light))
     :background "beige"  :foreground "lightgray")
    (t :inverse-video t))
  "Face used to visualize TAB."
  :group 'wipe)


(defcustom wipe-newline 'wipe-newline
  "Symbol face used to visualize NEWLINE char mapping.

See `wipe-display-mappings'.

Used when Wipe style includes the values `newline-mark'
and `newline'."
  :type 'face
  :group 'wipe)


(defface wipe-newline
  '((default :weight normal)
    (((class color) (background dark)) :foreground "darkgray")
    (((class color) (min-colors 88) (background light)) :foreground "lightgray")
    ;; Displays with 16 colors use lightgray as background, so using a
    ;; lightgray foreground makes the newline mark invisible.
    (((class color) (background light)) :foreground "brown")
    (t :underline t))
  "Face used to visualize NEWLINE char mapping.

See `wipe-display-mappings'."
  :group 'wipe)


(defcustom wipe-trailing 'wipe-trailing
  "Symbol face used to visualize trailing blanks.

Used when Wipe style includes the value `trailing'."
  :type 'face
  :group 'wipe)


(defface wipe-trailing		; 'trailing-whitespace
  '((default :weight bold)
    (((class mono)) :inverse-video t :underline t)
    (t :background "red1" :foreground "yellow"))
  "Face used to visualize trailing blanks."
  :group 'wipe)


(defcustom wipe-line 'wipe-line
  "Symbol face used to visualize \"long\" lines.

See `wipe-line-column'.

Used when Wipe style includes the value `line'."
  :type 'face
  :group 'wipe)


(defface wipe-line
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "gray20" :foreground "violet"))
  "Face used to visualize \"long\" lines.

See `wipe-line-column'."
  :group 'wipe)


(defcustom wipe-space-before-tab 'wipe-space-before-tab
  "Symbol face used to visualize SPACEs before TAB.

Used when Wipe style includes the value `space-before-tab'."
  :type 'face
  :group 'wipe)


(defface wipe-space-before-tab
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "DarkOrange" :foreground "firebrick"))
  "Face used to visualize SPACEs before TAB."
  :group 'wipe)


(defcustom wipe-indentation 'wipe-indentation
  "Symbol face used to visualize 8 or more SPACEs at beginning of line.

Used when Wipe style includes the value `indentation'."
  :type 'face
  :group 'wipe)


(defface wipe-indentation
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "yellow" :foreground "firebrick"))
  "Face used to visualize 8 or more SPACEs at beginning of line."
  :group 'wipe)


(defcustom wipe-empty 'wipe-empty
  "Symbol face used to visualize empty lines at beginning and/or end of buffer.

Used when Wipe style includes the value `empty'."
  :type 'face
  :group 'wipe)


(defface wipe-empty
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "yellow" :foreground "firebrick"))
  "Face used to visualize empty lines at beginning and/or end of buffer."
  :group 'wipe)


(defcustom wipe-space-after-tab 'wipe-space-after-tab
  "Symbol face used to visualize 8 or more SPACEs after TAB.

Used when Wipe style includes the value `space-after-tab'."
  :type 'face
  :group 'wipe)


(defface wipe-space-after-tab
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "yellow" :foreground "firebrick"))
  "Face used to visualize 8 or more SPACEs after TAB."
  :group 'wipe)


(defcustom wipe-hspace-regexp
  "\\(\\(\xA0\\|\x8A0\\|\x920\\|\xE20\\|\xF20\\)+\\)"
  "Specify HARD SPACE characters regexp.

If you're using `mule' package, there may be other characters besides:

   \"\\xA0\"   \"\\x8A0\"   \"\\x920\"   \"\\xE20\"   \"\\xF20\"

that should be considered HARD SPACE.

Here are some examples:

   \"\\\\(^\\xA0+\\\\)\"		\
visualize only leading HARD SPACEs.
   \"\\\\(\\xA0+$\\\\)\"		\
visualize only trailing HARD SPACEs.
   \"\\\\(^\\xA0+\\\\|\\xA0+$\\\\)\"	\
visualize leading and/or trailing HARD SPACEs.
   \"\\t\\\\(\\xA0+\\\\)\\t\"		\
visualize only HARD SPACEs between TABs.

NOTE: Enclose always by \\\\( and \\\\) the elements to highlight.
      Use exactly one pair of enclosing \\\\( and \\\\).

Used when Wipe style includes `spaces'."
  :type '(regexp :tag "HARD SPACE Chars")
  :group 'wipe)


(defcustom wipe-space-regexp "\\( +\\)"
  "Specify SPACE characters regexp.

If you're using `mule' package, there may be other characters
besides \" \" that should be considered SPACE.

Here are some examples:

   \"\\\\(^ +\\\\)\"		visualize only leading SPACEs.
   \"\\\\( +$\\\\)\"		visualize only trailing SPACEs.
   \"\\\\(^ +\\\\| +$\\\\)\"	\
visualize leading and/or trailing SPACEs.
   \"\\t\\\\( +\\\\)\\t\"	visualize only SPACEs between TABs.

NOTE: Enclose always by \\\\( and \\\\) the elements to highlight.
      Use exactly one pair of enclosing \\\\( and \\\\).

Used when Wipe style includes `spaces'."
  :type '(regexp :tag "SPACE Chars")
  :group 'wipe)


(defcustom wipe-tab-regexp "\\(\t+\\)"
  "Specify TAB characters regexp.

If you're using `mule' package, there may be other characters
besides \"\\t\" that should be considered TAB.

Here are some examples:

   \"\\\\(^\\t+\\\\)\"		visualize only leading TABs.
   \"\\\\(\\t+$\\\\)\"		visualize only trailing TABs.
   \"\\\\(^\\t+\\\\|\\t+$\\\\)\"	\
visualize leading and/or trailing TABs.
   \" \\\\(\\t+\\\\) \"	visualize only TABs between SPACEs.

NOTE: Enclose always by \\\\( and \\\\) the elements to highlight.
      Use exactly one pair of enclosing \\\\( and \\\\).

Used when Wipe style includes `tabs'."
  :type '(regexp :tag "TAB Chars")
  :group 'wipe)


(defcustom wipe-trailing-regexp
  "\\([\t \u00A0]+\\)$"
  "Specify trailing characters regexp.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\u00A0\"

that should be considered blank.

NOTE: Enclose always by \"\\\\(\" and \"\\\\)$\" the elements to highlight.
      Use exactly one pair of enclosing elements above.

Used when Wipe style includes `trailing'."
  :type '(regexp :tag "Trailing Chars")
  :group 'wipe)


(defcustom wipe-space-before-tab-regexp "\\( +\\)\\(\t+\\)"
  "Specify SPACEs before TAB regexp.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\xA0\"  \"\\x8A0\"  \"\\x920\"  \"\\xE20\"  \
\"\\xF20\"

that should be considered blank.

Used when Wipe style includes `space-before-tab',
`space-before-tab::tab' or  `space-before-tab::space'."
  :type '(regexp :tag "SPACEs Before TAB")
  :group 'wipe)


(defcustom wipe-indentation-regexp
  '("^\t*\\(\\( \\{%d\\}\\)+\\)[^\n\t]"
    . "^ *\\(\t+\\)[^\n]")
  "Specify regexp for 8 or more SPACEs at beginning of line.

It is a cons where the cons car is used for SPACEs visualization
and the cons cdr is used for TABs visualization.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\xA0\"  \"\\x8A0\"  \"\\x920\"  \"\\xE20\"  \
\"\\xF20\"

that should be considered blank.

Used when Wipe style includes `indentation',
`indentation::tab' or  `indentation::space'."
  :type '(cons (regexp :tag "Indentation SPACEs")
	       (regexp :tag "Indentation TABs"))
  :group 'wipe)


(defcustom wipe-empty-at-bob-regexp "^\\(\\([ \t]*\n\\)+\\)"
  "Specify regexp for empty lines at beginning of buffer.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\xA0\"  \"\\x8A0\"  \"\\x920\"  \"\\xE20\"  \
\"\\xF20\"

that should be considered blank.

Used when Wipe style includes `empty'."
  :type '(regexp :tag "Empty Lines At Beginning Of Buffer")
  :group 'wipe)


(defcustom wipe-empty-at-eob-regexp "^\\([ \t\n]+\\)"
  "Specify regexp for empty lines at end of buffer.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\xA0\"  \"\\x8A0\"  \"\\x920\"  \"\\xE20\"  \
\"\\xF20\"

that should be considered blank.

Used when Wipe style includes `empty'."
  :type '(regexp :tag "Empty Lines At End Of Buffer")
  :group 'wipe)


(defcustom wipe-space-after-tab-regexp
  '("\t+\\(\\( \\{%d\\}\\)+\\)"
    . "\\(\t+\\) +")
  "Specify regexp for 8 or more SPACEs after TAB.

It is a cons where the cons car is used for SPACEs visualization
and the cons cdr is used for TABs visualization.

If you're using `mule' package, there may be other characters besides:

   \" \"  \"\\t\"  \"\\xA0\"  \"\\x8A0\"  \"\\x920\"  \"\\xE20\"  \
\"\\xF20\"

that should be considered blank.

Used when Wipe style includes `space-after-tab',
`space-after-tab::tab' or `space-after-tab::space'."
  :type '(regexp :tag "SPACEs After TAB")
  :group 'wipe)


(defcustom wipe-line-column 80
  "Specify column beyond which the line is highlighted.

It must be an integer or nil.  If nil, the `fill-column' variable value is
used.

Used when Wipe style includes `lines' or `lines-tail'."
  :type '(choice :tag "Line Length Limit"
		 (integer :tag "Line Length")
		 (const :tag "Use fill-column" nil))
  :group 'wipe)


;; Hacked from `visible-wipe-mappings' in visws.el
(defcustom wipe-display-mappings
  '(
    (space-mark   ?\     [?\u00B7]     [?.])		; space - centered dot
    (space-mark   ?\xA0  [?\u00A4]     [?_])		; hard space - currency
    ;; NEWLINE is displayed using the face `wipe-newline'
    (newline-mark ?\n    [?$ ?\n])			; eol - dollar sign
    ;; (newline-mark ?\n    [?\u21B5 ?\n] [?$ ?\n])	; eol - downwards arrow
    ;; (newline-mark ?\n    [?\u00B6 ?\n] [?$ ?\n])	; eol - pilcrow
    ;; (newline-mark ?\n    [?\u00AF ?\n]  [?$ ?\n])	; eol - overscore
    ;; (newline-mark ?\n    [?\u00AC ?\n]  [?$ ?\n])	; eol - negation
    ;; (newline-mark ?\n    [?\u00B0 ?\n]  [?$ ?\n])	; eol - degrees
    ;;
    ;; WARNING: the mapping below has a problem.
    ;; When a TAB occupies exactly one column, it will display the
    ;; character ?\xBB at that column followed by a TAB which goes to
    ;; the next TAB column.
    ;; If this is a problem for you, please, comment the line below.
    (tab-mark     ?\t    [?\u00BB ?\t] [?\\ ?\t])	; tab - left quote mark
    )
  "Specify an alist of mappings for displaying characters.

Each element has the following form:

   (KIND CHAR VECTOR...)

Where:

KIND	is the kind of character.
	It can be one of the following symbols:

	tab-mark	for TAB character

	space-mark	for SPACE or HARD SPACE character

	newline-mark	for NEWLINE character

CHAR	is the character to be mapped.

VECTOR	is a vector of characters to be displayed in place of CHAR.
	The first display vector that can be displayed is used;
	if no display vector for a mapping can be displayed, then
	that character is displayed unmodified.

The NEWLINE character is displayed using the face given by
`wipe-newline' variable.

Used when Wipe style includes `tab-mark', `space-mark' or
`newline-mark'."
  :type '(repeat
	  (list :tag "Character Mapping"
		(choice :tag "Char Kind"
			(const :tag "Tab" tab-mark)
			(const :tag "Space" space-mark)
			(const :tag "Newline" newline-mark))
		(character :tag "Char")
		(repeat :inline t :tag "Vector List"
			(vector :tag ""
				(repeat :inline t
					:tag "Vector Characters"
					(character :tag "Char"))))))
  :group 'wipe)


(defcustom wipe-global-modes t
  "Modes for which global `wipe-mode' is automagically turned on.

Global `wipe-mode' is controlled by the command
`global-wipe-mode'.

If nil, means no modes have `wipe-mode' automatically
turned on.

If t, all modes that support `wipe-mode' have it
automatically turned on.

Else it should be a list of `major-mode' symbol names for which
`wipe-mode' should be automatically turned on.  The sense
of the list is negated if it begins with `not'.  For example:

   (c-mode c++-mode)

means that `wipe-mode' is turned on for buffers in C and
C++ modes only."
  :type '(choice :tag "Global Modes"
		 (const :tag "None" nil)
		 (const :tag "All" t)
		 (set :menu-tag "Mode Specific" :tag "Modes"
		      :value (not)
		      (const :tag "Except" not)
		      (repeat :inline t
			      (symbol :tag "Mode"))))
  :group 'wipe)

(defconst wipe-action-custom-type
  '(choice :tag "Actions"
	   (const :tag "None" nil)
	   (repeat :tag "Action List"
		   (choice :tag "Action"
			   (const :tag "Cleanup When On" cleanup)
			   (const :tag "Report On Bogus" report-on-bogus)
			   (const :tag "Auto Cleanup" auto-cleanup)
			   (const :tag "Abort On Bogus" abort-on-bogus)
			   (const :tag "Warn If Read-Only"
				  warn-if-read-only))))
  ;; Custom type specification for Wipe actions. Used in
  ;; WIPE-FILE-ACTION, WIPE-MODE-ACTION and
  ;; WIPE-ACTION.
  )

(defcustom wipe-file-action nil
  "File-specific actions to take when a buffer is visited or written.

This is a list of elements of the form (REGEXP ACTION...) where
REGEXP is matched against file names.  For a list of possible
ACTIONs, see `wipe-action'.

Wipe determines which actions need to be taken on a
specific buffer by trying a match from this variable, then from
`wipe-mode-action' and then by falling back to
`wipe-action'."
  :type `(repeat (cons :value ("")
		       (regexp :tag "File Name Matching")
		       ,wipe-action-custom-type))
  :version "24.3"
  :group 'wipe)

(defcustom wipe-mode-action nil
  "Mode-specific actions to take when a buffer is visited or written.

This is a list of elements of the form (MODE ACTION...) where
MODE is a major mode name.  For a list of possible ACTIONs, see
`wipe-action'.

Wipe determines which actions need to be taken on a
specific buffer by trying a match from `wipe-file-action',
then from this variable and then by falling back to
`wipe-action'."
  :type `(repeat (cons :value (fundamental-mode)
		       (symbol :tag "Major Mode")
		       ,wipe-action-custom-type))
  :version "24.3"
  :group 'wipe)

(defcustom wipe-action nil
  "Default actions to take when a buffer is visited or written.

Wipe determines which actions need to be taken on a
specific buffer by trying a match from `wipe-file-action',
then from `wipe-mode-action' and then by falling back to
this variable.

Its value is a list containing some or all of the following symbols:

   nil			no action is taken.

   cleanup		cleanup any bogus whitespace always when local
			Wipe is turned on.
			See `wipe-cleanup' and
			`wipe-cleanup-region'.

   report-on-bogus	report if there is any bogus whitespace always
			when local Wipe is turned on.

   auto-cleanup	cleanup any bogus whitespace when buffer is
			written.
			See `wipe-cleanup' and
			`wipe-cleanup-region'.

   abort-on-bogus	abort if there is any bogus whitespace and the
			buffer is written.

   warn-if-read-only	give a warning if `cleanup' or `auto-cleanup'
			is present and the buffer is read-only.

Any other value is treated as nil."
  :type wipe-action-custom-type
  :group 'wipe)

(defun wipe-action ()
  "Determine which actions to take on current buffer."
  (let (match)
    (when buffer-file-name
      (let ((actions wipe-file-action)
	    action)
	(while (and (not match) (setq action (pop actions)))
	  (when (string-match (car action) buffer-file-name)
	    (setq match action)))))
    (unless match
      (setq match (assoc major-mode wipe-mode-action)))
    (if match
	(cdr match)
      wipe-action)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User commands - Local mode


;;;###autoload
(define-minor-mode wipe-mode
  "Toggle Whitespace Inspection and Pruning in this buffer (Wipe mode).
With a prefix argument ARG, enable Wipe mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil.

See also `wipe-style', `wipe-newline' and
`wipe-display-mappings'."
  :lighter    " ws"
  :init-value nil
  :global     nil
  :group      'wipe
  (cond
   (noninteractive			; running a batch job
    (setq wipe-mode nil))
   (wipe-mode			; wipe-mode on
    (wipe-turn-on)
    (wipe-action-when-on))
   (t					; wipe-mode off
    (wipe-turn-off))))


;;;###autoload
(define-minor-mode wipe-newline-mode
  "Toggle newline visualization (Wipe Newline mode).
With a prefix argument ARG, enable Wipe Newline mode if ARG
is positive, and disable it otherwise.  If called from Lisp,
enable the mode if ARG is omitted or nil.

Use `wipe-newline-mode' only for NEWLINE visualization
exclusively.  For other visualizations, including NEWLINE
visualization together with (HARD) SPACEs and/or TABs, please,
use `wipe-mode'.

See also `wipe-newline' and `wipe-display-mappings'."
  :lighter    " nl"
  :init-value nil
  :global     nil
  :group      'wipe
  (let ((wipe-style '(face newline-mark newline)))
    (wipe-mode (if wipe-newline-mode
			 1 -1)))
  ;; sync states (running a batch job)
  (setq wipe-newline-mode wipe-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User commands - Global mode


;;;###autoload
(define-minor-mode global-wipe-mode
  "Toggle Wipe mode in all buffers.
With a prefix argument ARG, enable Global Wipe mode if ARG
is positive, and disable it otherwise.  If called from Lisp,
enable it if ARG is omitted or nil.

See also `wipe-style', `wipe-newline' and
`wipe-display-mappings'."
  :lighter    " WS"
  :init-value nil
  :global     t
  :group      'wipe
  (cond
   (noninteractive			; running a batch job
    (setq global-wipe-mode nil))
   (global-wipe-mode		; global-wipe-mode on
    (save-current-buffer
      (add-hook 'find-file-hook 'wipe-turn-on-if-enabled)
      (add-hook 'after-change-major-mode-hook 'wipe-turn-on-if-enabled)
      (dolist (buffer (buffer-list))	; adjust all local mode
	(set-buffer buffer)
	(unless wipe-mode
	  (wipe-turn-on-if-enabled)))))
   (t					; global-wipe-mode off
    (save-current-buffer
      (remove-hook 'find-file-hook 'wipe-turn-on-if-enabled)
      (remove-hook 'after-change-major-mode-hook 'wipe-turn-on-if-enabled)
      (dolist (buffer (buffer-list))	; adjust all local mode
	(set-buffer buffer)
	(unless wipe-mode
	  (wipe-turn-off)))))))


(defun wipe-turn-on-if-enabled ()
  (when (cond
	 ((eq wipe-global-modes t))
	 ((listp wipe-global-modes)
	  (if (eq (car-safe wipe-global-modes) 'not)
	      (not (memq major-mode (cdr wipe-global-modes)))
	    (memq major-mode wipe-global-modes)))
	 (t nil))
    (let (inhibit-quit)
      ;; Don't turn on Wipe mode if...
      (or
       ;; ...we don't have a display (we're running a batch job)
       noninteractive
       ;; ...or if the buffer is invisible (name starts with a space)
       (eq (aref (buffer-name) 0) ?\ )
       ;; ...or if the buffer is temporary (name starts with *)
       (and (eq (aref (buffer-name) 0) ?*)
	    ;; except the scratch buffer.
	    (not (string= (buffer-name) "*scratch*")))
       ;; Otherwise, turn on Wipe mode.
       (wipe-turn-on)))))


;;;###autoload
(define-minor-mode global-wipe-newline-mode
  "Toggle global newline visualization (Global Wipe Newline mode).
With a prefix argument ARG, enable Global Wipe Newline mode
if ARG is positive, and disable it otherwise.  If called from
Lisp, enable it if ARG is omitted or nil.

Use `global-wipe-newline-mode' only for NEWLINE
visualization exclusively.  For other visualizations, including
NEWLINE visualization together with (HARD) SPACEs and/or TABs,
please use `global-wipe-mode'.

See also `wipe-newline' and `wipe-display-mappings'."
  :lighter    " NL"
  :init-value nil
  :global     t
  :group      'wipe
  (let ((wipe-style '(newline-mark newline)))
    (global-wipe-mode (if global-wipe-newline-mode
				1 -1))
    ;; sync states (running a batch job)
    (setq global-wipe-newline-mode global-wipe-mode)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User commands - Toggle


(defconst wipe-style-value-list
  '(face
    tabs
    spaces
    trailing
    lines
    lines-tail
    newline
    empty
    indentation
    indentation::tab
    indentation::space
    space-after-tab
    space-after-tab::tab
    space-after-tab::space
    space-before-tab
    space-before-tab::tab
    space-before-tab::space
    help-newline       ; value used by `wipe-insert-option-mark'
    tab-mark
    space-mark
    newline-mark
    )
  "List of valid Wipe style values.")


(defconst wipe-toggle-option-alist
  '((?f    . face)
    (?t    . tabs)
    (?s    . spaces)
    (?r    . trailing)
    (?l    . lines)
    (?L    . lines-tail)
    (?n    . newline)
    (?e    . empty)
    (?\C-i . indentation)
    (?I    . indentation::tab)
    (?i    . indentation::space)
    (?\C-a . space-after-tab)
    (?A    . space-after-tab::tab)
    (?a    . space-after-tab::space)
    (?\C-b . space-before-tab)
    (?B    . space-before-tab::tab)
    (?b    . space-before-tab::space)
    (?T    . tab-mark)
    (?S    . space-mark)
    (?N    . newline-mark)
    (?x    . wipe-style)
    )
  "Alist of toggle options.

Each element has the form:

   (CHAR . SYMBOL)

Where:

CHAR	is a char which the user will have to type.

SYMBOL	is a valid symbol associated with CHAR.
	See `wipe-style-value-list'.")


(defvar wipe-active-style nil
  "Used to save locally Wipe style value.")

(defvar wipe-indent-tabs-mode indent-tabs-mode
  "Used to save locally `indent-tabs-mode' value.")

(defvar wipe-tab-width tab-width
  "Used to save locally `tab-width' value.")

(defvar wipe-point (point)
  "Used to save locally current point value.
Used by function `wipe-trailing-regexp' (which see).")

(defvar wipe-font-lock-refontify nil
  "Used to save locally the font-lock refontify state.
Used by function `wipe-post-command-hook' (which see).")

(defvar wipe-bob-marker nil
  "Used to save locally the bob marker value.
Used by function `wipe-post-command-hook' (which see).")

(defvar wipe-eob-marker nil
  "Used to save locally the eob marker value.
Used by function `wipe-post-command-hook' (which see).")

(defvar wipe-buffer-changed nil
  "Used to indicate locally if buffer changed.
Used by `wipe-post-command-hook' and `wipe-buffer-changed'
functions (which see).")


;;;###autoload
(defun wipe-toggle-options (arg)
  "Toggle local `wipe-mode' options.

If local wipe-mode is off, toggle the option given by ARG
and turn on local wipe-mode.

If local wipe-mode is on, toggle the option given by ARG
and restart local wipe-mode.

Interactively, it reads one of the following chars:

  CHAR	MEANING
  (VIA FACES)
   f	toggle face visualization
   t	toggle TAB visualization
   s	toggle SPACE and HARD SPACE visualization
   r	toggle trailing blanks visualization
   l	toggle \"long lines\" visualization
   L	toggle \"long lines\" tail visualization
   n	toggle NEWLINE visualization
   e	toggle empty line at bob and/or eob visualization
   C-i	toggle indentation SPACEs visualization (via `indent-tabs-mode')
   I	toggle indentation SPACEs visualization
   i	toggle indentation TABs visualization
   C-a	toggle SPACEs after TAB visualization (via `indent-tabs-mode')
   A	toggle SPACEs after TAB: SPACEs visualization
   a	toggle SPACEs after TAB: TABs visualization
   C-b	toggle SPACEs before TAB visualization (via `indent-tabs-mode')
   B	toggle SPACEs before TAB: SPACEs visualization
   b	toggle SPACEs before TAB: TABs visualization

  (VIA DISPLAY TABLE)
   T	toggle TAB visualization
   S	toggle SPACEs before TAB visualization
   N	toggle NEWLINE visualization

   x	restore original Wipe style
   ?	display brief help

Non-interactively, ARG should be a symbol or a list of symbols.
The valid symbols are:

   face			toggle face visualization
   tabs			toggle TAB visualization
   spaces		toggle SPACE and HARD SPACE visualization
   trailing		toggle trailing blanks visualization
   lines		toggle \"long lines\" visualization
   lines-tail		toggle \"long lines\" tail visualization
   newline		toggle NEWLINE visualization
   empty		toggle empty line at bob and/or eob visualization
   indentation		toggle indentation SPACEs visualization
   indentation::tab	toggle indentation SPACEs visualization
   indentation::space	toggle indentation TABs visualization
   space-after-tab		toggle SPACEs after TAB visualization
   space-after-tab::tab	toggle SPACEs after TAB: SPACEs visualization
   space-after-tab::space	toggle SPACEs after TAB: TABs visualization
   space-before-tab		toggle SPACEs before TAB visualization
   space-before-tab::tab	toggle SPACEs before TAB: SPACEs visualization
   space-before-tab::space	toggle SPACEs before TAB: TABs visualization

   tab-mark		toggle TAB visualization
   space-mark		toggle SPACEs before TAB visualization
   newline-mark		toggle NEWLINE visualization

   wipe-style	restore original Wipe style

See `wipe-style' and `indent-tabs-mode' for documentation."
  (interactive (wipe-interactive-char t))
  (let ((wipe-style
	 (wipe-toggle-list t arg wipe-active-style)))
    (wipe-mode 0)
    (wipe-mode 1)))


(defvar wipe-toggle-style nil
  "Used to toggle the global `wipe-style' value.")


;;;###autoload
(defun global-wipe-toggle-options (arg)
  "Toggle global `wipe-mode' options.

If global wipe-mode is off, toggle the option given by ARG
and turn on global wipe-mode.

If global wipe-mode is on, toggle the option given by ARG
and restart global wipe-mode.

Interactively, it accepts one of the following chars:

  CHAR	MEANING
  (VIA FACES)
   f	toggle face visualization
   t	toggle TAB visualization
   s	toggle SPACE and HARD SPACE visualization
   r	toggle trailing blanks visualization
   l	toggle \"long lines\" visualization
   L	toggle \"long lines\" tail visualization
   n	toggle NEWLINE visualization
   e	toggle empty line at bob and/or eob visualization
   C-i	toggle indentation SPACEs visualization (via `indent-tabs-mode')
   I	toggle indentation SPACEs visualization
   i	toggle indentation TABs visualization
   C-a	toggle SPACEs after TAB visualization (via `indent-tabs-mode')
   A	toggle SPACEs after TAB: SPACEs visualization
   a	toggle SPACEs after TAB: TABs visualization
   C-b	toggle SPACEs before TAB visualization (via `indent-tabs-mode')
   B	toggle SPACEs before TAB: SPACEs visualization
   b	toggle SPACEs before TAB: TABs visualization

  (VIA DISPLAY TABLE)
   T	toggle TAB visualization
   S	toggle SPACEs before TAB visualization
   N	toggle NEWLINE visualization

   x	restore original Wipe style
   ?	display brief help

Non-interactively, ARG should be a symbol or a list of symbols.
The valid symbols are:

   face			toggle face visualization
   tabs			toggle TAB visualization
   spaces		toggle SPACE and HARD SPACE visualization
   trailing		toggle trailing blanks visualization
   lines		toggle \"long lines\" visualization
   lines-tail		toggle \"long lines\" tail visualization
   newline		toggle NEWLINE visualization
   empty		toggle empty line at bob and/or eob visualization
   indentation		toggle indentation SPACEs visualization
   indentation::tab	toggle indentation SPACEs visualization
   indentation::space	toggle indentation TABs visualization
   space-after-tab		toggle SPACEs after TAB visualization
   space-after-tab::tab		toggle SPACEs after TAB: SPACEs visualization
   space-after-tab::space	toggle SPACEs after TAB: TABs visualization
   space-before-tab		toggle SPACEs before TAB visualization
   space-before-tab::tab	toggle SPACEs before TAB: SPACEs visualization
   space-before-tab::space	toggle SPACEs before TAB: TABs visualization

   tab-mark		toggle TAB visualization
   space-mark		toggle SPACEs before TAB visualization
   newline-mark		toggle NEWLINE visualization

   wipe-style	restore original Wipe style

See `wipe-style' and `indent-tabs-mode' for documentation."
  (interactive (wipe-interactive-char nil))
  (let ((wipe-style
	 (wipe-toggle-list nil arg wipe-toggle-style)))
    (setq wipe-toggle-style wipe-style)
    (global-wipe-mode 0)
    (global-wipe-mode 1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User commands - Cleanup


;;;###autoload
(defun wipe-cleanup ()
  "Cleanup some blank problems in all buffer or at region.

It usually applies to the whole buffer, but in transient mark
mode when the mark is active, it applies to the region.  It also
applies to the region when it is not in transient mark mode, the
mark is active and \\[universal-argument] was pressed just before
calling `wipe-cleanup' interactively.

See also `wipe-cleanup-region'.

The problems cleaned up are:

1. empty lines at beginning of buffer.
2. empty lines at end of buffer.
   If Wipe style includes the value `empty', remove all
   empty lines at beginning and/or end of buffer.

3. 8 or more SPACEs at beginning of line.
   If Wipe style includes the value `indentation':
   replace 8 or more SPACEs at beginning of line by TABs, if
   `indent-tabs-mode' is non-nil; otherwise, replace TABs by
   SPACEs.
   If Wipe style includes the value `indentation::tab',
   replace 8 or more SPACEs at beginning of line by TABs.
   If Wipe style includes the value `indentation::space',
   replace TABs by SPACEs.

4. SPACEs before TAB.
   If Wipe style includes the value `space-before-tab':
   replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
   otherwise, replace TABs by SPACEs.
   If Wipe style includes the value
   `space-before-tab::tab', replace SPACEs by TABs.
   If Wipe style includes the value
   `space-before-tab::space', replace TABs by SPACEs.

5. SPACEs or TABs at end of line.
   If Wipe style includes the value `trailing', remove
   all SPACEs or TABs at end of line.

6. 8 or more SPACEs after TAB.
   If Wipe style includes the value `space-after-tab':
   replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
   otherwise, replace TABs by SPACEs.
   If Wipe style includes the value
   `space-after-tab::tab', replace SPACEs by TABs.
   If Wipe style includes the value
   `space-after-tab::space', replace TABs by SPACEs.

See `wipe-style', `indent-tabs-mode' and `tab-width' for
documentation."
  (interactive "@")
  (cond
   ;; read-only buffer
   (buffer-read-only
    (wipe-warn-read-only "cleanup"))
   ;; region active
   ((and (or transient-mark-mode
	     current-prefix-arg)
	 mark-active)
    ;; PROBLEMs 1 and 2 are not handled in region
    ;; PROBLEM 3: 8 or more SPACEs at bol
    ;; PROBLEM 4: SPACEs before TAB
    ;; PROBLEM 5: SPACEs or TABs at eol
    ;; PROBLEM 6: 8 or more SPACEs after TAB
    (wipe-cleanup-region (region-beginning) (region-end)))
   ;; whole buffer
   (t
    (save-excursion
      (save-match-data                ;FIXME: Why?
	;; PROBLEM 1: empty lines at bob
	;; PROBLEM 2: empty lines at eob
	;; ACTION: remove all empty lines at bob and/or eob
	(when (memq 'empty (wipe-style))
	  (let (overwrite-mode)		; enforce no overwrite
	    (goto-char (point-min))
	    (when (looking-at wipe-empty-at-bob-regexp)
	      (delete-region (match-beginning 1) (match-end 1)))
	    (when (re-search-forward
		   (concat wipe-empty-at-eob-regexp "\\'") nil t)
	      (delete-region (match-beginning 1) (match-end 1)))))))
    ;; PROBLEM 3: 8 or more SPACEs at bol
    ;; PROBLEM 4: SPACEs before TAB
    ;; PROBLEM 5: SPACEs or TABs at eol
    ;; PROBLEM 6: 8 or more SPACEs after TAB
    (wipe-cleanup-region (point-min) (point-max)))))


;;;###autoload
(defun wipe-cleanup-region (start end)
  "Cleanup some blank problems at region.

The problems cleaned up are:

1. 8 or more SPACEs at beginning of line.
   If Wipe style includes the value `indentation':
   replace 8 or more SPACEs at beginning of line by TABs, if
   `indent-tabs-mode' is non-nil; otherwise, replace TABs by
   SPACEs.
   If Wipe style includes the value `indentation::tab',
   replace 8 or more SPACEs at beginning of line by TABs.
   If Wipe style includes the value `indentation::space',
   replace TABs by SPACEs.

2. SPACEs before TAB.
   If Wipe style includes the value `space-before-tab':
   replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
   otherwise, replace TABs by SPACEs.
   If Wipe style includes the value
   `space-before-tab::tab', replace SPACEs by TABs.
   If Wipe style includes the value
   `space-before-tab::space', replace TABs by SPACEs.

3. SPACEs or TABs at end of line.
   If Wipe style includes the value `trailing', remove
   all SPACEs or TABs at end of line.

4. 8 or more SPACEs after TAB.
   If Wipe style includes the value `space-after-tab':
   replace SPACEs by TABs, if `indent-tabs-mode' is non-nil;
   otherwise, replace TABs by SPACEs.
   If Wipe style includes the value
   `space-after-tab::tab', replace SPACEs by TABs.
   If Wipe style includes the value
   `space-after-tab::space', replace TABs by SPACEs.

See Wipe style, `indent-tabs-mode' and `tab-width' for
documentation."
  (interactive "@r")
  (if buffer-read-only
      ;; read-only buffer
      (wipe-warn-read-only "cleanup region")
    ;; non-read-only buffer
    (let ((rstart           (min start end))
	  (rend             (copy-marker (max start end)))
	  (indent-tabs-mode wipe-indent-tabs-mode)
	  (tab-width        wipe-tab-width)
	  overwrite-mode		; enforce no overwrite
	  tmp)
      (save-excursion
	(save-match-data                ;FIXME: Why?
	  ;; PROBLEM 1: 8 or more SPACEs at bol
	  (cond
	   ;; ACTION: replace 8 or more SPACEs at bol by TABs, if
	   ;; `indent-tabs-mode' is non-nil; otherwise, replace TABs
	   ;; by SPACEs.
	   ((memq 'indentation (wipe-style))
	    (let ((regexp (wipe-indentation-regexp)))
	      (goto-char rstart)
	      (while (re-search-forward regexp rend t)
		(setq tmp (current-indentation))
		(goto-char (match-beginning 0))
		(delete-horizontal-space)
		(unless (eolp)
		  (indent-to tmp)))))
	   ;; ACTION: replace 8 or more SPACEs at bol by TABs.
	   ((memq 'indentation::tab (wipe-style))
	    (wipe-replace-action
	     'tabify rstart rend
	     (wipe-indentation-regexp 'tab) 0))
	   ;; ACTION: replace TABs by SPACEs.
	   ((memq 'indentation::space (wipe-style))
	    (wipe-replace-action
	     'untabify rstart rend
	     (wipe-indentation-regexp 'space) 0)))
	  ;; PROBLEM 3: SPACEs or TABs at eol
	  ;; ACTION: remove all SPACEs or TABs at eol
	  (when (memq 'trailing (wipe-style))
	    (wipe-replace-action
	     'delete-region rstart rend
	     wipe-trailing-regexp 1))
	  ;; PROBLEM 4: 8 or more SPACEs after TAB
	  (cond
	   ;; ACTION: replace 8 or more SPACEs by TABs, if
	   ;; `indent-tabs-mode' is non-nil; otherwise, replace TABs
	   ;; by SPACEs.
	   ((memq 'space-after-tab (wipe-style))
	    (wipe-replace-action
	     (if wipe-indent-tabs-mode 'tabify 'untabify)
	     rstart rend (wipe-space-after-tab-regexp) 1))
	   ;; ACTION: replace 8 or more SPACEs by TABs.
	   ((memq 'space-after-tab::tab (wipe-style))
	    (wipe-replace-action
	     'tabify rstart rend
	     (wipe-space-after-tab-regexp 'tab) 1))
	   ;; ACTION: replace TABs by SPACEs.
	   ((memq 'space-after-tab::space (wipe-style))
	    (wipe-replace-action
	     'untabify rstart rend
	     (wipe-space-after-tab-regexp 'space) 1)))
	  ;; PROBLEM 2: SPACEs before TAB
	  (cond
	   ;; ACTION: replace SPACEs before TAB by TABs, if
	   ;; `indent-tabs-mode' is non-nil; otherwise, replace TABs
	   ;; by SPACEs.
	   ((memq 'space-before-tab (wipe-style))
	    (wipe-replace-action
	     (if wipe-indent-tabs-mode 'tabify 'untabify)
	     rstart rend wipe-space-before-tab-regexp
	     (if wipe-indent-tabs-mode 0 2)))
	   ;; ACTION: replace SPACEs before TAB by TABs.
	   ((memq 'space-before-tab::tab (wipe-style))
	    (wipe-replace-action
	     'tabify rstart rend
	     wipe-space-before-tab-regexp 0))
	   ;; ACTION: replace TABs by SPACEs.
	   ((memq 'space-before-tab::space (wipe-style))
	    (wipe-replace-action
	     'untabify rstart rend
	     wipe-space-before-tab-regexp 2)))))
      (set-marker rend nil))))		; point marker to nowhere


(defun wipe-replace-action (action rstart rend regexp index)
  "Do ACTION in the string matched by REGEXP between RSTART and REND.

INDEX is the level group matched by REGEXP and used by ACTION.

See also `tab-width'."
  (goto-char rstart)
  (while (re-search-forward regexp rend t)
    (goto-char (match-end index))
    (funcall action (match-beginning index) (match-end index))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User command - report


(defun wipe-regexp (regexp &optional kind)
  "Return REGEXP depending on `wipe-indent-tabs-mode'."
  (cond
   ((or (eq kind 'tab)
	wipe-indent-tabs-mode)
    (format (car regexp) wipe-tab-width))
   ((or (eq kind 'space)
	(not wipe-indent-tabs-mode))
    (cdr regexp))))


(defun wipe-indentation-regexp (&optional kind)
  "Return the indentation regexp depending on `wipe-indent-tabs-mode'."
  (wipe-regexp wipe-indentation-regexp kind))


(defun wipe-space-after-tab-regexp (&optional kind)
  "Return the space-after-tab regexp depending on `wipe-indent-tabs-mode'."
  (wipe-regexp wipe-space-after-tab-regexp kind))


(defconst wipe-report-list
  (list
   (cons 'empty                   wipe-empty-at-bob-regexp)
   (cons 'empty                   wipe-empty-at-eob-regexp)
   (cons 'trailing                wipe-trailing-regexp)
   (cons 'indentation             nil)
   (cons 'indentation::tab        nil)
   (cons 'indentation::space      nil)
   (cons 'space-before-tab        wipe-space-before-tab-regexp)
   (cons 'space-before-tab::tab   wipe-space-before-tab-regexp)
   (cons 'space-before-tab::space wipe-space-before-tab-regexp)
   (cons 'space-after-tab         nil)
   (cons 'space-after-tab::tab    nil)
   (cons 'space-after-tab::space  nil)
   )
   "List of Wipe bogus symbol and corresponding regexp.")


(defconst wipe-report-text
  '( ;; `indent-tabs-mode' has non-nil value
    "\
 Wipe Report

 Current Setting                       Whitespace Problem

 empty                    []     []  empty lines at beginning of buffer
 empty                    []     []  empty lines at end of buffer
 trailing                 []     []  SPACEs or TABs at end of line
 indentation              []     []  8 or more SPACEs at beginning of line
 indentation::tab         []     []  8 or more SPACEs at beginning of line
 indentation::space       []     []  TABs at beginning of line
 space-before-tab         []     []  SPACEs before TAB
 space-before-tab::tab    []     []  SPACEs before TAB: SPACEs
 space-before-tab::space  []     []  SPACEs before TAB: TABs
 space-after-tab          []     []  8 or more SPACEs after TAB
 space-after-tab::tab     []     []  8 or more SPACEs after TAB: SPACEs
 space-after-tab::space   []     []  8 or more SPACEs after TAB: TABs

 indent-tabs-mode =
 tab-width        = \n\n"
    . ;; `indent-tabs-mode' has nil value
    "\
 Wipe Report

 Current Setting                       Whitespace Problem

 empty                    []     []  empty lines at beginning of buffer
 empty                    []     []  empty lines at end of buffer
 trailing                 []     []  SPACEs or TABs at end of line
 indentation              []     []  TABs at beginning of line
 indentation::tab         []     []  8 or more SPACEs at beginning of line
 indentation::space       []     []  TABs at beginning of line
 space-before-tab         []     []  SPACEs before TAB
 space-before-tab::tab    []     []  SPACEs before TAB: SPACEs
 space-before-tab::space  []     []  SPACEs before TAB: TABs
 space-after-tab          []     []  8 or more SPACEs after TAB
 space-after-tab::tab     []     []  8 or more SPACEs after TAB: SPACEs
 space-after-tab::space   []     []  8 or more SPACEs after TAB: TABs

 indent-tabs-mode =
 tab-width        = \n\n")
  "Text for Wipe bogus report.

It is a cons of strings, where the car part is used when
`indent-tabs-mode' is non-nil, and the cdr part is used when
`indent-tabs-mode' is nil.")


(defconst wipe-report-buffer-name "*Wipe Report*"
  "The buffer name for Wipe bogus report.")


;;;###autoload
(defun wipe-report (&optional force report-if-bogus)
  "Report some Wipe problems in buffer.

Return nil if there is no Wipe problem; otherwise, return
non-nil.

If FORCE is non-nil or \\[universal-argument] was pressed just
before calling `wipe-report' interactively, it forces
Wipe style to have:

   empty
   trailing
   indentation
   space-before-tab
   space-after-tab

If REPORT-IF-BOGUS is non-nil, it reports only when there are any
Wipe problems in buffer.

Report if some of the following whitespace problems exist:

* If `indent-tabs-mode' is non-nil:
   empty		1. empty lines at beginning of buffer.
   empty		2. empty lines at end of buffer.
   trailing		3. SPACEs or TABs at end of line.
   indentation		4. 8 or more SPACEs at beginning of line.
   space-before-tab	5. SPACEs before TAB.
   space-after-tab	6. 8 or more SPACEs after TAB.

* If `indent-tabs-mode' is nil:
   empty		1. empty lines at beginning of buffer.
   empty		2. empty lines at end of buffer.
   trailing		3. SPACEs or TABs at end of line.
   indentation		4. TABS at beginning of line.
   space-before-tab	5. SPACEs before TAB.
   space-after-tab	6. 8 or more SPACEs after TAB.

See `wipe-style' for documentation.
See also `wipe-cleanup' and `wipe-cleanup-region' for
cleaning up these problems."
  (interactive (list current-prefix-arg))
  (wipe-report-region (point-min) (point-max)
			    force report-if-bogus))


;;;###autoload
(defun wipe-report-region (start end &optional force report-if-bogus)
  "Report some whitespace problems in a region.

Return nil if there is no whitespace problem; otherwise, return
non-nil.

If FORCE is non-nil or \\[universal-argument] was pressed just
before calling `wipe-report-region' interactively, it
forces Wipe style to have:

   empty
   indentation
   space-before-tab
   trailing
   space-after-tab

If REPORT-IF-BOGUS is non-nil, it reports only when there are any
whitespace problems in buffer.

Report if some of the following whitespace problems exist:

* If `indent-tabs-mode' is non-nil:
   empty		1. empty lines at beginning of buffer.
   empty		2. empty lines at end of buffer.
   trailing		3. SPACEs or TABs at end of line.
   indentation		4. 8 or more SPACEs at beginning of line.
   space-before-tab	5. SPACEs before TAB.
   space-after-tab	6. 8 or more SPACEs after TAB.

* If `indent-tabs-mode' is nil:
   empty		1. empty lines at beginning of buffer.
   empty		2. empty lines at end of buffer.
   trailing		3. SPACEs or TABs at end of line.
   indentation		4. TABS at beginning of line.
   space-before-tab	5. SPACEs before TAB.
   space-after-tab	6. 8 or more SPACEs after TAB.

See `wipe-style' for documentation.
See also `wipe-cleanup' and `wipe-cleanup-region' for
cleaning up these problems."
  (interactive "r")
  (setq force (or current-prefix-arg force))
  (save-excursion
    (save-match-data                ;FIXME: Why?
      (let* ((style (wipe-style))
	     (has-bogus nil)
	     (rstart    (min start end))
	     (rend      (max start end))
	     (bogus-list
	      (mapcar
	       #'(lambda (option)
		   (when force
		     (add-to-list 'style (car option)))
		   (goto-char rstart)
		   (let ((regexp
			  (cond
			   ((eq (car option) 'indentation)
			    (wipe-indentation-regexp))
			   ((eq (car option) 'indentation::tab)
			    (wipe-indentation-regexp 'tab))
			   ((eq (car option) 'indentation::space)
			    (wipe-indentation-regexp 'space))
			   ((eq (car option) 'space-after-tab)
			    (wipe-space-after-tab-regexp))
			   ((eq (car option) 'space-after-tab::tab)
			    (wipe-space-after-tab-regexp 'tab))
			   ((eq (car option) 'space-after-tab::space)
			    (wipe-space-after-tab-regexp 'space))
			   (t
			    (cdr option)))))
		     (and (re-search-forward regexp rend t)
			  (setq has-bogus t))))
	       wipe-report-list)))
	(when (if report-if-bogus has-bogus t)
	  (wipe-kill-buffer wipe-report-buffer-name)
	  ;; `wipe-indent-tabs-mode' is local to current buffer
	  ;; `wipe-tab-width' is local to current buffer
	  (let ((ws-indent-tabs-mode wipe-indent-tabs-mode)
		(ws-tab-width wipe-tab-width))
	    (with-current-buffer (get-buffer-create
				  wipe-report-buffer-name)
	      (erase-buffer)
	      (insert (if ws-indent-tabs-mode
			  (car wipe-report-text)
			(cdr wipe-report-text)))
	      (goto-char (point-min))
	      (forward-line 3)
	      (dolist (option wipe-report-list)
		(forward-line 1)
		(wipe-mark-x 27 (memq (car option) style))
		(wipe-mark-x 7 (car bogus-list))
		(setq bogus-list (cdr bogus-list)))
	      (forward-line 1)
	      (wipe-insert-value ws-indent-tabs-mode)
	      (wipe-insert-value ws-tab-width)
	      (when has-bogus
		(goto-char (point-max))
		(insert " Type `M-x wipe-cleanup'"
			" to cleanup the buffer.\n\n"
			" Type `M-x wipe-cleanup-region'"
			" to cleanup a region.\n\n"))
	      (wipe-display-window (current-buffer)))))
	has-bogus))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Internal functions


(defvar wipe-font-lock-mode nil
  "Used to remember whether a buffer had font lock mode on or not.")

(defvar wipe-font-lock nil
  "Used to remember whether a buffer initially had font lock on or not.")

(defvar wipe-font-lock-keywords nil
  "Used to save locally `font-lock-keywords' value.")


(defconst wipe-help-text
  "\
 Wipe Toggle Options                  | scroll up  :  SPC   or > |
				      | scroll down:  M-SPC or < |
 FACES                                \__________________________/
 []  f   - toggle face visualization
 []  t   - toggle TAB visualization
 []  s   - toggle SPACE and HARD SPACE visualization
 []  r   - toggle trailing blanks visualization
 []  l   - toggle \"long lines\" visualization
 []  L   - toggle \"long lines\" tail visualization
 []  n   - toggle NEWLINE visualization
 []  e   - toggle empty line at bob and/or eob visualization
 []  C-i - toggle indentation SPACEs visualization (via `indent-tabs-mode')
 []  I   - toggle indentation SPACEs visualization
 []  i   - toggle indentation TABs visualization
 []  C-a - toggle SPACEs after TAB visualization (via `indent-tabs-mode')
 []  A   - toggle SPACEs after TAB: SPACEs visualization
 []  a   - toggle SPACEs after TAB: TABs visualization
 []  C-b - toggle SPACEs before TAB visualization (via `indent-tabs-mode')
 []  B   - toggle SPACEs before TAB: SPACEs visualization
 []  b   - toggle SPACEs before TAB: TABs visualization

 DISPLAY TABLE
 []  T - toggle TAB visualization
 []  S - toggle SPACE and HARD SPACE visualization
 []  N - toggle NEWLINE visualization

      x - restore original Wipe style

      ? - display this text\n\n"
  "Text for Wipe toggle options.")


(defconst wipe-help-buffer-name "*Wipe Toggle Options*"
  "The buffer name for Wipe toggle options.")


(defun wipe-insert-value (value)
  "Insert VALUE at column 20 of next line."
  (forward-line 1)
  (move-to-column 20 t)
  (insert (format "%s" value)))


(defun wipe-mark-x (nchars condition)
  "Insert the mark ('X' or ' ') after NCHARS depending on CONDITION."
  (forward-char nchars)
  (insert (if condition "X" " ")))


(defun wipe-insert-option-mark (the-list the-value)
  "Insert the option mark ('X' or ' ') in toggle options buffer."
  (goto-char (point-min))
  (forward-line 2)
  (dolist (sym  the-list)
    (if (eq sym 'help-newline)
	(forward-line 2)
      (forward-line 1)
      (wipe-mark-x 2 (memq sym the-value)))))


(defun wipe-help-on (style)
  "Display the Wipe toggle options."
  (unless (get-buffer wipe-help-buffer-name)
    (delete-other-windows)
    (let ((buffer (get-buffer-create wipe-help-buffer-name)))
      (with-current-buffer buffer
	(erase-buffer)
	(insert wipe-help-text)
	(wipe-insert-option-mark
	 wipe-style-value-list style)
	(wipe-display-window buffer)))))


(defun wipe-display-window (buffer)
  "Display BUFFER in a new window."
  (goto-char (point-min))
  (set-buffer-modified-p nil)
  (when (< (window-height) (* 2 window-min-height))
    (kill-buffer buffer)
    (error "Window height is too small; \
can't split window to display Wipe toggle options"))
  (let ((win (split-window)))
    (set-window-buffer win buffer)
    (shrink-window-if-larger-than-buffer win)))


(defun wipe-kill-buffer (buffer-name)
  "Kill buffer BUFFER-NAME and windows related with it."
  (let ((buffer (get-buffer buffer-name)))
    (when buffer
      (delete-windows-on buffer)
      (kill-buffer buffer))))


(defun wipe-help-off ()
  "Remove the buffer and window of the Wipe toggle options."
  (wipe-kill-buffer wipe-help-buffer-name))


(defun wipe-help-scroll (&optional up)
  "Scroll help window, if it exists.

If UP is non-nil, scroll up; otherwise, scroll down."
  (condition-case nil
      (let ((buffer (get-buffer wipe-help-buffer-name)))
	(if buffer
	    (with-selected-window (get-buffer-window buffer)
	      (if up
		  (scroll-up 3)
		(scroll-down 3)))
	  (ding)))
    ;; handler
    ((error)
     ;; just ignore error
     )))


(defun wipe-interactive-char (local-p)
  "Interactive function to read a char and return a symbol.

If LOCAL-P is non-nil, it uses a local context; otherwise, it
uses a global context.

It accepts one of the following chars:

  CHAR	MEANING
  (VIA FACES)
   f	toggle face visualization
   t	toggle TAB visualization
   s	toggle SPACE and HARD SPACE visualization
   r	toggle trailing blanks visualization
   l	toggle \"long lines\" visualization
   L	toggle \"long lines\" tail visualization
   n	toggle NEWLINE visualization
   e	toggle empty line at bob and/or eob visualization
   C-i	toggle indentation SPACEs visualization (via `indent-tabs-mode')
   I	toggle indentation SPACEs visualization
   i	toggle indentation TABs visualization
   C-a	toggle SPACEs after TAB visualization (via `indent-tabs-mode')
   A	toggle SPACEs after TAB: SPACEs visualization
   a	toggle SPACEs after TAB: TABs visualization
   C-b	toggle SPACEs before TAB visualization (via `indent-tabs-mode')
   B	toggle SPACEs before TAB: SPACEs visualization
   b	toggle SPACEs before TAB: TABs visualization

  (VIA DISPLAY TABLE)
   T	toggle TAB visualization
   S	toggle SPACE and HARD SPACE visualization
   N	toggle NEWLINE visualization

   x	restore original Wipe style
   ?	display brief help

See also `wipe-toggle-option-alist'."
  (let* ((is-off (not (if local-p wipe-mode global-wipe-mode)))
	 (style  (cond (is-off (if local-p
				   (wipe-style)
				 wipe-style))
		       (local-p wipe-active-style)
		       (t       wipe-toggle-style)))
	 (prompt
	  (format "Wipe Toggle %s (type ? for further options)-"
		  (if local-p "Local" "Global")))
	 ch sym)
    ;; read a valid option and get the corresponding symbol
    (save-window-excursion
      (condition-case data
	  (progn
	    (while
		;; while condition
		(progn
		  (setq ch (read-char prompt))
		  (not
		   (setq sym
			 (cdr
			  (assq ch wipe-toggle-option-alist)))))
	      ;; while body
	      (cond
	       ((eq ch ?\?)   (wipe-help-on style))
	       ((eq ch ?\ )   (wipe-help-scroll t))
	       ((eq ch ?\M- ) (wipe-help-scroll))
	       ((eq ch ?>)    (wipe-help-scroll t))
	       ((eq ch ?<)    (wipe-help-scroll))
	       (t             (ding))))
	    (wipe-help-off)
	    (message " "))		; clean echo area
	;; handler
	((quit error)
	 (wipe-help-off)
	 (error (error-message-string data)))))
    (list sym)))			; return the appropriate symbol


(defun wipe-toggle-list (local-p arg the-list)
  "Toggle options in THE-LIST based on list ARG.

If LOCAL-P is non-nil, it uses a local context; otherwise, it
uses a global context.

ARG is a list of options to be toggled.

THE-LIST is a list of options.  This list will be toggled and the
resultant list will be returned."
  (unless (if local-p wipe-mode global-wipe-mode)
    (setq the-list (if local-p (wipe-style) wipe-style)))
  (setq the-list (copy-sequence the-list)) ; keep original list
  (dolist (sym (if (listp arg) arg (list arg)))
    (cond
     ;; ignore help value
     ((eq sym 'help-newline))
     ;; restore default values
     ((eq sym 'wipe-style)
      (setq the-list (if local-p (wipe-style) wipe-style)))
     ;; toggle valid values
     ((memq sym wipe-style-value-list)
      (setq the-list (if (memq sym the-list)
			 (delq sym the-list)
		       (cons sym the-list))))))
  the-list)


(defvar wipe-display-table nil
  "Used to save a local display table.")

(defvar wipe-display-table-was-local nil
  "Used to remember whether a buffer initially had a local display table.")


(defun wipe-turn-on ()
  "Turn Wipe mode on."
  ;; prepare local hooks
  (add-hook 'write-file-functions 'wipe-write-file-hook nil t)
  ;; create Wipe local buffer environment
  (set (make-local-variable 'wipe-font-lock-mode) nil)
  (set (make-local-variable 'wipe-font-lock) nil)
  (set (make-local-variable 'wipe-font-lock-keywords) nil)
  (set (make-local-variable 'wipe-display-table) nil)
  (set (make-local-variable 'wipe-display-table-was-local) nil)
  (set (make-local-variable 'wipe-active-style)
       (if (listp (wipe-style))
	   (wipe-style)
	 (list (wipe-style))))
  (set (make-local-variable 'wipe-indent-tabs-mode)
       indent-tabs-mode)
  (set (make-local-variable 'wipe-tab-width)
       tab-width)
  ;; turn on Wipe
  (when wipe-active-style
    (wipe-color-on)
    (wipe-display-char-on)))


(defun wipe-turn-off ()
  "Turn Wipe mode off."
  (remove-hook 'write-file-functions 'wipe-write-file-hook t)
  (when wipe-active-style
    (wipe-color-off)
    (wipe-display-char-off)))


(defun wipe-style-face-p ()
  "Return t if there is some visualization via face."
  (and (memq 'face wipe-active-style)
       (or (memq 'tabs                    wipe-active-style)
	   (memq 'spaces                  wipe-active-style)
	   (memq 'trailing                wipe-active-style)
	   (memq 'lines                   wipe-active-style)
	   (memq 'lines-tail              wipe-active-style)
	   (memq 'newline                 wipe-active-style)
	   (memq 'empty                   wipe-active-style)
	   (memq 'indentation             wipe-active-style)
	   (memq 'indentation::tab        wipe-active-style)
	   (memq 'indentation::space      wipe-active-style)
	   (memq 'space-after-tab         wipe-active-style)
	   (memq 'space-after-tab::tab    wipe-active-style)
	   (memq 'space-after-tab::space  wipe-active-style)
	   (memq 'space-before-tab        wipe-active-style)
	   (memq 'space-before-tab::tab   wipe-active-style)
	   (memq 'space-before-tab::space wipe-active-style))))


(defun wipe-color-on ()
  "Turn on color visualization."
  (when (wipe-style-face-p)
    (unless wipe-font-lock
      (setq wipe-font-lock t
	    wipe-font-lock-keywords
	    (copy-sequence font-lock-keywords)))
    ;; save current point and refontify when necessary
    (set (make-local-variable 'wipe-point)
	 (point))
    (set (make-local-variable 'wipe-font-lock-refontify)
	 0)
    (set (make-local-variable 'wipe-bob-marker)
	 (point-min-marker))
    (set (make-local-variable 'wipe-eob-marker)
	 (point-max-marker))
    (set (make-local-variable 'wipe-buffer-changed)
	 nil)
    (add-hook 'post-command-hook #'wipe-post-command-hook nil t)
    (add-hook 'before-change-functions #'wipe-buffer-changed nil t)
    ;; turn off font lock
    (set (make-local-variable 'wipe-font-lock-mode)
	 font-lock-mode)
    (font-lock-mode 0)
    ;; add wipe-mode color into font lock
    (when (memq 'spaces wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs
	(list wipe-space-regexp  1 wipe-space  t)
	;; Show HARD SPACEs
	(list wipe-hspace-regexp 1 wipe-hspace t))
       t))
    (when (memq 'tabs wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show TABs
	(list wipe-tab-regexp 1 wipe-tab t))
       t))
    (when (memq 'trailing wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show trailing blanks
	(list #'wipe-trailing-regexp 1 wipe-trailing t))
       t))
    (when (or (memq 'lines      wipe-active-style)
	      (memq 'lines-tail wipe-active-style))
      (font-lock-add-keywords
       nil
       (list
	;; Show "long" lines
	(list
	 (let ((line-column (or wipe-line-column fill-column)))
	   (format
	    "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
	    wipe-tab-width
	    (1- wipe-tab-width)
	    (/ line-column wipe-tab-width)
	    (let ((rem (% line-column wipe-tab-width)))
	      (if (zerop rem)
		  ""
		(format ".\\{%d\\}" rem)))))
	 (if (memq 'lines wipe-active-style)
	     0				; whole line
	   2)				; line tail
	 wipe-line t))
       t))
    (cond
     ((memq 'space-before-tab wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs before TAB (indent-tabs-mode)
	(list wipe-space-before-tab-regexp
	      (if wipe-indent-tabs-mode 1 2)
	      wipe-space-before-tab t))
       t))
     ((memq 'space-before-tab::tab wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs before TAB (SPACEs)
	(list wipe-space-before-tab-regexp
	      1 wipe-space-before-tab t))
       t))
     ((memq 'space-before-tab::space wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs before TAB (TABs)
	(list wipe-space-before-tab-regexp
	      2 wipe-space-before-tab t))
       t)))
    (cond
     ((memq 'indentation wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show indentation SPACEs (indent-tabs-mode)
	(list (wipe-indentation-regexp)
	      1 wipe-indentation t))
       t))
     ((memq 'indentation::tab wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show indentation SPACEs (SPACEs)
	(list (wipe-indentation-regexp 'tab)
	      1 wipe-indentation t))
       t))
     ((memq 'indentation::space wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show indentation SPACEs (TABs)
	(list (wipe-indentation-regexp 'space)
	      1 wipe-indentation t))
       t)))
    (when (memq 'empty wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show empty lines at beginning of buffer
	(list #'wipe-empty-at-bob-regexp
	      1 wipe-empty t))
       t)
      (font-lock-add-keywords
       nil
       (list
	;; Show empty lines at end of buffer
	(list #'wipe-empty-at-eob-regexp
	      1 wipe-empty t))
       t))
    (cond
     ((memq 'space-after-tab wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs after TAB (indent-tabs-mode)
	(list (wipe-space-after-tab-regexp)
	      1 wipe-space-after-tab t))
       t))
     ((memq 'space-after-tab::tab wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs after TAB (SPACEs)
	(list (wipe-space-after-tab-regexp 'tab)
	      1 wipe-space-after-tab t))
       t))
     ((memq 'space-after-tab::space wipe-active-style)
      (font-lock-add-keywords
       nil
       (list
	;; Show SPACEs after TAB (TABs)
	(list (wipe-space-after-tab-regexp 'space)
	      1 wipe-space-after-tab t))
       t)))
    ;; now turn on font lock and highlight blanks
    (font-lock-mode 1)))


(defun wipe-color-off ()
  "Turn off color visualization."
  ;; turn off font lock
  (when (wipe-style-face-p)
    (font-lock-mode 0)
    (remove-hook 'post-command-hook #'wipe-post-command-hook t)
    (remove-hook 'before-change-functions #'wipe-buffer-changed t)
    (when wipe-font-lock
      (setq wipe-font-lock nil
	    font-lock-keywords   wipe-font-lock-keywords))
    ;; restore original font lock state
    (font-lock-mode wipe-font-lock-mode)))


(defun wipe-trailing-regexp (limit)
  "Match trailing spaces which do not contain the point at end of line."
  (let ((status t))
    (while (if (re-search-forward wipe-trailing-regexp limit t)
	       (= wipe-point (match-end 1)) ;; loop if point at eol
	     (setq status nil)))		  ;; end of buffer
    status))


(defun wipe-empty-at-bob-regexp (limit)
  "Match spaces at beginning of buffer which do not contain the point at \
beginning of buffer."
  (let ((b (point))
	r)
    (cond
     ;; at bob
     ((= b 1)
      (setq r (and (/= wipe-point 1)
		   (looking-at wipe-empty-at-bob-regexp)))
      (set-marker wipe-bob-marker (if r (match-end 1) b)))
     ;; inside bob empty region
     ((<= limit wipe-bob-marker)
      (setq r (looking-at wipe-empty-at-bob-regexp))
      (if r
	  (when (< (match-end 1) limit)
	    (set-marker wipe-bob-marker (match-end 1)))
	(set-marker wipe-bob-marker b)))
     ;; intersection with end of bob empty region
     ((<= b wipe-bob-marker)
      (setq r (looking-at wipe-empty-at-bob-regexp))
      (set-marker wipe-bob-marker (if r (match-end 1) b)))
     ;; it is not inside bob empty region
     (t
      (setq r nil)))
    ;; move to end of matching
    (and r (goto-char (match-end 1)))
    r))


(defsubst wipe-looking-back (regexp limit)
  (save-excursion
    (when (/= 0 (skip-chars-backward " \t\n" limit))
      (unless (bolp)
	(forward-line 1))
      (looking-at regexp))))


(defun wipe-empty-at-eob-regexp (limit)
  "Match spaces at end of buffer which do not contain the point at end of \
buffer."
  (let ((b (point))
	(e (1+ (buffer-size)))
	r)
    (cond
     ;; at eob
     ((= limit e)
      (when (/= wipe-point e)
	(goto-char limit)
	(setq r (wipe-looking-back wipe-empty-at-eob-regexp b)))
      (if r
	  (set-marker wipe-eob-marker (match-beginning 1))
	(set-marker wipe-eob-marker limit)
	(goto-char b)))			; return back to initial position
     ;; inside eob empty region
     ((>= b wipe-eob-marker)
      (goto-char limit)
      (setq r (wipe-looking-back wipe-empty-at-eob-regexp b))
      (if r
	  (when (> (match-beginning 1) b)
	    (set-marker wipe-eob-marker (match-beginning 1)))
	(set-marker wipe-eob-marker limit)
	(goto-char b)))			; return back to initial position
     ;; intersection with beginning of eob empty region
     ((>= limit wipe-eob-marker)
      (goto-char limit)
      (setq r (wipe-looking-back wipe-empty-at-eob-regexp b))
      (if r
	  (set-marker wipe-eob-marker (match-beginning 1))
	(set-marker wipe-eob-marker limit)
	(goto-char b)))			; return back to initial position
     ;; it is not inside eob empty region
     (t
      (setq r nil)))
    r))


(defun wipe-buffer-changed (_beg _end)
  "Set `wipe-buffer-changed' variable to t."
  (setq wipe-buffer-changed t))


(defun wipe-post-command-hook ()
  "Save current point into `wipe-point' variable.
Also refontify when necessary."
  (setq wipe-point (point))	; current point position
  (let ((refontify
	 (or
	  ;; it is at end of line ...
	  (and (eolp)
	       ;; ... with trailing SPACE or TAB
	       (or (= (preceding-char) ?\ )
		   (= (preceding-char) ?\t)))
	  ;; it is at beginning of buffer (bob)
	  (= wipe-point 1)
	  ;; the buffer was modified and ...
	  (and wipe-buffer-changed
	       (or
		;; ... or inside bob Wipe region
		(<= wipe-point wipe-bob-marker)
		;; ... or at bob Wipe region border
		(and (= wipe-point (1+ wipe-bob-marker))
		     (= (preceding-char) ?\n))))
	  ;; it is at end of buffer (eob)
	  (= wipe-point (1+ (buffer-size)))
	  ;; the buffer was modified and ...
	  (and wipe-buffer-changed
	       (or
		;; ... or inside eob Wipe region
		(>= wipe-point wipe-eob-marker)
		;; ... or at eob Wipe region border
		(and (= wipe-point (1- wipe-eob-marker))
		     (= (following-char) ?\n)))))))
    (when (or refontify (> wipe-font-lock-refontify 0))
      (setq wipe-buffer-changed nil)
      ;; adjust refontify counter
      (setq wipe-font-lock-refontify
	    (if refontify
		1
	      (1- wipe-font-lock-refontify)))
      ;; refontify
      (jit-lock-refontify))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hacked from visws.el (Miles Bader <miles@gnu.org>)


(defun wipe-style-mark-p ()
  "Return t if there is some visualization via display table."
  (or (memq 'tab-mark     wipe-active-style)
      (memq 'space-mark   wipe-active-style)
      (memq 'newline-mark wipe-active-style)))


(defsubst wipe-char-valid-p (char)
  ;; This check should be improved!!!
  (or (< char 256)
      (characterp char)))


(defun wipe-display-vector-p (vec)
  "Return true if every character in vector VEC can be displayed."
  (let ((i (length vec)))
    (when (> i 0)
      (while (and (>= (setq i (1- i)) 0)
		  (wipe-char-valid-p (aref vec i))))
      (< i 0))))


(defun wipe-display-char-on ()
  "Turn on character display mapping."
  (when (and wipe-display-mappings
	     (wipe-style-mark-p))
    (let (vecs vec)
      ;; Remember whether a buffer has a local display table.
      (unless wipe-display-table-was-local
	(setq wipe-display-table-was-local t
	      wipe-display-table
	      (copy-sequence buffer-display-table))
	;; Assure `buffer-display-table' is unique
	;; when two or more windows are visible.
	(setq buffer-display-table
	      (copy-sequence buffer-display-table)))
      (unless buffer-display-table
	(setq buffer-display-table (make-display-table)))
      (dolist (entry wipe-display-mappings)
	;; check if it is to display this mark
	(when (memq (car entry) (wipe-style))
	  ;; Get a displayable mapping.
	  (setq vecs (cddr entry))
	  (while (and vecs
		      (not (wipe-display-vector-p (car vecs))))
	    (setq vecs (cdr vecs)))
	  ;; Display a valid mapping.
	  (when vecs
	    (setq vec (copy-sequence (car vecs)))
	    ;; NEWLINE char
	    (when (and (eq (cadr entry) ?\n)
		       (memq 'newline wipe-active-style))
	      ;; Only insert face bits on NEWLINE char mapping to avoid
	      ;; obstruction of other faces like TABs and (HARD) SPACEs
	      ;; faces, font-lock faces, etc.
	      (dotimes (i (length vec))
		(or (eq (aref vec i) ?\n)
		    (aset vec i
			  (make-glyph-code (aref vec i)
					   wipe-newline)))))
	    ;; Display mapping
	    (aset buffer-display-table (cadr entry) vec)))))))


(defun wipe-display-char-off ()
  "Turn off character display mapping."
  (and wipe-display-mappings
       (wipe-style-mark-p)
       wipe-display-table-was-local
       (setq wipe-display-table-was-local nil
	     buffer-display-table wipe-display-table)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hook


(defun wipe-action-when-on ()
  "Action to be taken always when local Wipe is turned on."
  (cond ((memq 'cleanup (wipe-action))
	 (wipe-cleanup))
	((memq 'report-on-bogus (wipe-action))
	 (wipe-report nil t))))


(defun wipe-write-file-hook ()
  "Action to be taken when buffer is written.
It should be added buffer-locally to `write-file-functions'."
  (cond ((memq 'auto-cleanup (wipe-action))
	 (wipe-cleanup))
	((memq 'abort-on-bogus (wipe-action))
	 (when (wipe-report nil t)
	   (error "Abort write due to whitespace problems in %s"
		  (buffer-name)))))
  nil)					; continue hook processing


(defun wipe-warn-read-only (msg)
  "Warn if buffer is read-only."
  (when (memq 'warn-if-read-only (wipe-action))
    (message "Can't %s: %s is read-only" msg (buffer-name))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun wipe-unload-function ()
  "Unload the Wipe library."
  (global-wipe-mode -1)
  ;; be sure all local Wipe mode is turned off
  (save-current-buffer
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (wipe-mode -1)))
  nil)					; continue standard unloading


(provide 'wipe)


(run-hooks 'wipe-load-hook)


;;; wipe.el ends here
