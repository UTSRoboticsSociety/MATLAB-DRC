;; Auto-generated. Do not edit!


(when (boundp 'rosserial_arduino::Power)
  (if (not (find-package "ROSSERIAL_ARDUINO"))
    (make-package "ROSSERIAL_ARDUINO"))
  (shadow 'Power (find-package "ROSSERIAL_ARDUINO")))
(unless (find-package "ROSSERIAL_ARDUINO::POWER")
  (make-package "ROSSERIAL_ARDUINO::POWER"))
(unless (find-package "ROSSERIAL_ARDUINO::POWERREQUEST")
  (make-package "ROSSERIAL_ARDUINO::POWERREQUEST"))
(unless (find-package "ROSSERIAL_ARDUINO::POWERRESPONSE")
  (make-package "ROSSERIAL_ARDUINO::POWERRESPONSE"))

(in-package "ROS")





(defclass rosserial_arduino::PowerRequest
  :super ros::object
  :slots (_power ))

(defmethod rosserial_arduino::PowerRequest
  (:init
   (&key
    ((:power __power) 0.0)
    )
   (send-super :init)
   (setq _power (float __power))
   self)
  (:power
   (&optional __power)
   (if __power (setq _power __power)) _power)
  (:serialization-length
   ()
   (+
    ;; float32 _power
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float32 _power
       (sys::poke _power (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float32 _power
     (setq _power (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;;
   self)
  )

(defclass rosserial_arduino::PowerResponse
  :super ros::object
  :slots ())

(defmethod rosserial_arduino::PowerResponse
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

(defclass rosserial_arduino::Power
  :super ros::object
  :slots ())

(setf (get rosserial_arduino::Power :md5sum-) "b75f3bcdec2dcafb6503e9b6316400b0")
(setf (get rosserial_arduino::Power :datatype-) "rosserial_arduino/Power")
(setf (get rosserial_arduino::Power :request) rosserial_arduino::PowerRequest)
(setf (get rosserial_arduino::Power :response) rosserial_arduino::PowerResponse)

(defmethod rosserial_arduino::PowerRequest
  (:response () (instance rosserial_arduino::PowerResponse :init)))

(setf (get rosserial_arduino::PowerRequest :md5sum-) "b75f3bcdec2dcafb6503e9b6316400b0")
(setf (get rosserial_arduino::PowerRequest :datatype-) "rosserial_arduino/PowerRequest")
(setf (get rosserial_arduino::PowerRequest :definition-)
      "float32 power
---

")

(setf (get rosserial_arduino::PowerResponse :md5sum-) "b75f3bcdec2dcafb6503e9b6316400b0")
(setf (get rosserial_arduino::PowerResponse :datatype-) "rosserial_arduino/PowerResponse")
(setf (get rosserial_arduino::PowerResponse :definition-)
      "float32 power
---

")



(provide :rosserial_arduino/Power "b75f3bcdec2dcafb6503e9b6316400b0")


