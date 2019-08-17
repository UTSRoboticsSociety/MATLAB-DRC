;; Auto-generated. Do not edit!


(when (boundp 'rosserial_arduino::TurnAngle)
  (if (not (find-package "ROSSERIAL_ARDUINO"))
    (make-package "ROSSERIAL_ARDUINO"))
  (shadow 'TurnAngle (find-package "ROSSERIAL_ARDUINO")))
(unless (find-package "ROSSERIAL_ARDUINO::TURNANGLE")
  (make-package "ROSSERIAL_ARDUINO::TURNANGLE"))
(unless (find-package "ROSSERIAL_ARDUINO::TURNANGLEREQUEST")
  (make-package "ROSSERIAL_ARDUINO::TURNANGLEREQUEST"))
(unless (find-package "ROSSERIAL_ARDUINO::TURNANGLERESPONSE")
  (make-package "ROSSERIAL_ARDUINO::TURNANGLERESPONSE"))

(in-package "ROS")





(defclass rosserial_arduino::TurnAngleRequest
  :super ros::object
  :slots (_angle ))

(defmethod rosserial_arduino::TurnAngleRequest
  (:init
   (&key
    ((:angle __angle) 0.0)
    )
   (send-super :init)
   (setq _angle (float __angle))
   self)
  (:angle
   (&optional __angle)
   (if __angle (setq _angle __angle)) _angle)
  (:serialization-length
   ()
   (+
    ;; float32 _angle
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float32 _angle
       (sys::poke _angle (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float32 _angle
     (setq _angle (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;;
   self)
  )

(defclass rosserial_arduino::TurnAngleResponse
  :super ros::object
  :slots ())

(defmethod rosserial_arduino::TurnAngleResponse
  (:init
   (&key
    )
   (send-super :init)
   self)
  (:serialization-length
   ()
   (+
    0
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;;
   self)
  )

(defclass rosserial_arduino::TurnAngle
  :super ros::object
  :slots ())

(setf (get rosserial_arduino::TurnAngle :md5sum-) "2d11dcdbe5a6f73dd324353dc52315ab")
(setf (get rosserial_arduino::TurnAngle :datatype-) "rosserial_arduino/TurnAngle")
(setf (get rosserial_arduino::TurnAngle :request) rosserial_arduino::TurnAngleRequest)
(setf (get rosserial_arduino::TurnAngle :response) rosserial_arduino::TurnAngleResponse)

(defmethod rosserial_arduino::TurnAngleRequest
  (:response () (instance rosserial_arduino::TurnAngleResponse :init)))

(setf (get rosserial_arduino::TurnAngleRequest :md5sum-) "2d11dcdbe5a6f73dd324353dc52315ab")
(setf (get rosserial_arduino::TurnAngleRequest :datatype-) "rosserial_arduino/TurnAngleRequest")
(setf (get rosserial_arduino::TurnAngleRequest :definition-)
      "float32 angle
---

")

(setf (get rosserial_arduino::TurnAngleResponse :md5sum-) "2d11dcdbe5a6f73dd324353dc52315ab")
(setf (get rosserial_arduino::TurnAngleResponse :datatype-) "rosserial_arduino/TurnAngleResponse")
(setf (get rosserial_arduino::TurnAngleResponse :definition-)
      "float32 angle
---

")



(provide :rosserial_arduino/TurnAngle "2d11dcdbe5a6f73dd324353dc52315ab")


