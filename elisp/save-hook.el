(require 'find-root)

(defun save-hook ()
  (interactive)
  (cond
   ;; python のテストファイルの場合テストする
   ((eq major-mode 'python-mode)
    (compile
     ;; (format "cd %s && flake8 %s && python -m test.run %s" (find-root (buffer-file-name)) (buffer-file-name) (buffer-file-name))))
     (format "cd %s && ./test/run %s" (find-root (buffer-file-name)) (buffer-file-name) )))
   ))

(provide 'save-hook)
