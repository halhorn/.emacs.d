(require 'find-root)

(defun save-hook ()
  (interactive)
  (cond
   ;; python のテストファイルの場合テストする
   ((and (eq major-mode 'python-mode) (string-match "/halucas/test/" (buffer-file-name)))
    (compile
     (format "cd %s && ./run_tests.sh %s" (find-root (buffer-file-name)) (buffer-file-name))))

   ;; python ファイルの場合：flake8 する
   ((eq major-mode 'python-mode)
    (compile
     (format "flake8 %s" (buffer-file-name))))
   ))

(provide 'save-hook)
