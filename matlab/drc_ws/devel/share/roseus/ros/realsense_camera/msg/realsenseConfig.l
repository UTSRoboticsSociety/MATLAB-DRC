;; Auto-generated. Do not edit!


(when (boundp 'realsense_camera::realsenseConfig)
  (if (not (find-package "REALSENSE_CAMERA"))
    (make-package "REALSENSE_CAMERA"))
  (shadow 'realsenseConfig (find-package "REALSENSE_CAMERA")))
(unless (find-package "REALSENSE_CAMERA::REALSENSECONFIG")
  (make-package "REALSENSE_CAMERA::REALSENSECONFIG"))

(in-package "ROS")
;;//! \htmlinclude realsenseConfig.msg.html


(defclass realsense_camera::realsenseConfig
  :super ros::object
  :slots (_depth_raw_unit ))

(defmethod realsense_camera::realsenseConfig
  (:init
   (&key
    ((:depth_raw_unit __depth_raw_unit) 0.0)
    )
   (send-super :init)
   (setq _depth_raw_unit (float __depth_raw_unit))
   self)
  (:depth_raw_unit
   (&optional __depth_raw_unit)
   (if __depth_raw_unit (setq _depth_raw_unit __depth_raw_unit)) _depth_raw_unit)
  (:serialization-length
   ()
   (+
    ;; float32 _depth_raw_unit
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float32 _depth_raw_unit
       (sys::poke _depth_raw_unit (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float32 _depth_raw_unit
     (setq _depth_raw_unit (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;;
   self)
  )

(setf (get realsense_camera::realsenseConfig :md5sum-) "78f677fac7365df7ab1d8244f7e2fa95")
(setf (get realsense_camera::realsenseConfig :datatype-) "realsense_camera/realsenseConfig")
(setf (get realsense_camera::realsenseConfig :definition-)
      "
float32 depth_raw_unit
")



(provide :realsense_camera/realsenseConfig "78f677fac7365df7ab1d8244f7e2fa95")


