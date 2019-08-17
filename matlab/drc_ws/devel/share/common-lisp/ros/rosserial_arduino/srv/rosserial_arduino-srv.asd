
(cl:in-package :asdf)

(defsystem "rosserial_arduino-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "Power" :depends-on ("_package_Power"))
    (:file "_package_Power" :depends-on ("_package"))
    (:file "TurnAngle" :depends-on ("_package_TurnAngle"))
    (:file "_package_TurnAngle" :depends-on ("_package"))
  ))