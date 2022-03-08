(require 'find-root)

(defun save-hook ()
  (interactive)
  (cond
   ;; python のテストファイルの場合テストする
   ((eq major-mode 'python-mode)
    (compile
     ;; (format "cd %s && flake8 %s && python -m test.run %s" (find-root (buffer-file-name)) (buffer-file-name) (buffer-file-name))))
     (format "cd %s && LOG_LEVEL=INFO ./test/run %s" (find-root (buffer-file-name)) (buffer-file-name) )))

   ((eq major-mode 'js2-mode)
    (compile
     (format "npm run test")))

   ((eq major-mode 'typescript-mode)
    (compile
     (format "cd %s && ./run_front_test --watchAll=false %s" (find-root (buffer-file-name)) (buffer-file-name) )))

   ((eq major-mode 'web-mode)
    (compile
     (format "cd %s && ./run_front_test --watchAll=false %s" (find-root (buffer-file-name)) (buffer-file-name) )))
   ))

(provide 'save-hook)
