(defun find-root (path)
  (if (file-directory-p (concat path "/.git"))
      path
    (let ((path-components
           (reverse (cdr (reverse (split-string path "/"))))))
      (if (null path-components)
          nil
        (find-root
         (mapconcat 'identity path-components "/"))))))
(provide 'find-root)
