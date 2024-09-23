;; -*- lexical-binding: t -*-


(defvar create-cider-test-macro
  "(defmacro convert-to-test [intended-output & args]
    (let [test-form (last args)]
      `(~'deftest ~'my-cider-gen-test
         (~'testing \"test1\"
           (do ~@(drop-last 1 args)
             (~'is (~'= ~intended-output ~test-form)))))))")


(defun write-command-to-test (command-output command-contents)
  (projectile-toggle-between-implementation-and-test)
  (setq current-test-buffer1 (current-buffer))
    (goto-char (point-max))
    (cider-interactive-eval
     (concat "(do " create-cider-test-macro "\n"
	     "(require 'clojure.pprint)\n"
	     "(with-out-str (clojure.pprint/pprint (macroexpand-1 '(convert-to-test "
	     command-output " "
	     command-contents ")))))")
     (lambda (value)
       (with-current-buffer current-test-buffer1
	 (when (nrepl-dict-get value "value")
	   (progn
	     (insert "\n\n")
	     (setq output12 (nrepl-dict-get value "value"))
	     (insert (read (nrepl-dict-get value "value")))))))
     nil
     (cider--nrepl-pr-request-map)))


(defun cider-write-region-to-test (start end)
  "Creates a unit test out of the given selected region."
  (interactive "r")
  (goto-char end)
  (let ((curr-selected (buffer-substring start end))
	(last-sexp (cider-last-sexp))
	(current-buffer2 (current-buffer)))
    (cider-interactive-eval
     last-sexp
     (lambda (value)
       (with-current-buffer current-buffer2
       (when (nrepl-dict-get value "value")
		       (write-command-to-test
			(nrepl-dict-get value "value")
			curr-selected))))
     nil
     (cider--nrepl-pr-request-map))))

;; (setq debug-on-error t)
