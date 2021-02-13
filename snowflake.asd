;;;; snowflake.asd

(asdf:defsystem #:snowflake
  :description "Generates a random snowflake via random walk."
  :author "Timo 'eXodiquas' Netzer <exodiquas@gmail.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("trivial-gamekit")
  :components ((:file "package")
               (:file "snowflake")))
