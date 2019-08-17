;; Auto-generated. Do not edit!


(when (boundp 'realsense_camera::get_rgb_uv)
  (if (not (find-package "REALSENSE_CAMERA"))
    (make-package "REALSENSE_CAMERA"))
  (shadow 'get_rgb_uv (find-package "REALSENSE_CAMERA")))
(unless (find-package "REALSENSE_CAMERA::GET_RGB_UV")
  (make-package "REALSENSE_CAMERA::GET_RGB_UV"))
(unless (find-package "REALSENSE_CAMERA::GET_RGB_UVREQUEST")
  (make-package "REALSENSE_CAMERA::GET_RGB_UVREQUEST"))
(unless (find-package "REALSENSE_CAMERA::GET_RGB_UVRESPONSE")
  (make-package "REALSENSE_CAMERA::GET_RGB_UVRESPONSE"))

(in-package "ROS")





(defclass realsense_camera::get_rgb_uvRequest
  :super ros::object
  :slots (_x_min_depth _x_min_xy _y_min_depth _y_min_xy _x_max_depth _x_max_xy _y_max_depth _y_max_xy ))

(defmethod realsense_camera::get_rgb_uvRequest
  (:init
   (&key
    ((:x_min_depth __x_min_depth) 0)
    ((:x_min_xy __x_min_xy) 0)
    ((:y_min_depth __y_min_depth) 0)
    ((:y_min_xy __y_min_xy) 0)
    ((:x_max_depth __x_max_depth) 0)
    ((:x_max_xy __x_max_xy) 0)
    ((:y_max_depth __y_max_depth) 0)
    ((:y_max_xy __y_max_xy) 0)
    )
   (send-super :init)
   (setq _x_min_depth (round __x_min_depth))
   (setq _x_min_xy (round __x_min_xy))
   (setq _y_min_depth (round __y_min_depth))
   (setq _y_min_xy (round __y_min_xy))
   (setq _x_max_depth (round __x_max_depth))
   (setq _x_max_xy (round __x_max_xy))
   (setq _y_max_depth (round __y_max_depth))
   (setq _y_max_xy (round __y_max_xy))
   self)
  (:x_min_depth
   (&optional __x_min_depth)
   (if __x_min_depth (setq _x_min_depth __x_min_depth)) _x_min_depth)
  (:x_min_xy
   (&optional __x_min_xy)
   (if __x_min_xy (setq _x_min_xy __x_min_xy)) _x_min_xy)
  (:y_min_depth
   (&optional __y_min_depth)
   (if __y_min_depth (setq _y_min_depth __y_min_depth)) _y_min_depth)
  (:y_min_xy
   (&optional __y_min_xy)
   (if __y_min_xy (setq _y_min_xy __y_min_xy)) _y_min_xy)
  (:x_max_depth
   (&optional __x_max_depth)
   (if __x_max_depth (setq _x_max_depth __x_max_depth)) _x_max_depth)
  (:x_max_xy
   (&optional __x_max_xy)
   (if __x_max_xy (setq _x_max_xy __x_max_xy)) _x_max_xy)
  (:y_max_depth
   (&optional __y_max_depth)
   (if __y_max_depth (setq _y_max_depth __y_max_depth)) _y_max_depth)
  (:y_max_xy
   (&optional __y_max_xy)
   (if __y_max_xy (setq _y_max_xy __y_max_xy)) _y_max_xy)
  (:serialization-length
   ()
   (+
    ;; int32 _x_min_depth
    4
    ;; int32 _x_min_xy
    4
    ;; int32 _y_min_depth
    4
    ;; int32 _y_min_xy
    4
    ;; int32 _x_max_depth
    4
    ;; int32 _x_max_xy
    4
    ;; int32 _y_max_depth
    4
    ;; int32 _y_max_xy
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; int32 _x_min_depth
       (write-long _x_min_depth s)
     ;; int32 _x_min_xy
       (write-long _x_min_xy s)
     ;; int32 _y_min_depth
       (write-long _y_min_depth s)
     ;; int32 _y_min_xy
       (write-long _y_min_xy s)
     ;; int32 _x_max_depth
       (write-long _x_max_depth s)
     ;; int32 _x_max_xy
       (write-long _x_max_xy s)
     ;; int32 _y_max_depth
       (write-long _y_max_depth s)
     ;; int32 _y_max_xy
       (write-long _y_max_xy s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; int32 _x_min_depth
     (setq _x_min_depth (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _x_min_xy
     (setq _x_min_xy (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_min_depth
     (setq _y_min_depth (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_min_xy
     (setq _y_min_xy (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _x_max_depth
     (setq _x_max_depth (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _x_max_xy
     (setq _x_max_xy (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_max_depth
     (setq _y_max_depth (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_max_xy
     (setq _y_max_xy (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(defclass realsense_camera::get_rgb_uvResponse
  :super ros::object
  :slots (_x_min_uv _y_min_uv _x_max_uv _y_max_uv ))

(defmethod realsense_camera::get_rgb_uvResponse
  (:init
   (&key
    ((:x_min_uv __x_min_uv) 0)
    ((:y_min_uv __y_min_uv) 0)
    ((:x_max_uv __x_max_uv) 0)
    ((:y_max_uv __y_max_uv) 0)
    )
   (send-super :init)
   (setq _x_min_uv (round __x_min_uv))
   (setq _y_min_uv (round __y_min_uv))
   (setq _x_max_uv (round __x_max_uv))
   (setq _y_max_uv (round __y_max_uv))
   self)
  (:x_min_uv
   (&optional __x_min_uv)
   (if __x_min_uv (setq _x_min_uv __x_min_uv)) _x_min_uv)
  (:y_min_uv
   (&optional __y_min_uv)
   (if __y_min_uv (setq _y_min_uv __y_min_uv)) _y_min_uv)
  (:x_max_uv
   (&optional __x_max_uv)
   (if __x_max_uv (setq _x_max_uv __x_max_uv)) _x_max_uv)
  (:y_max_uv
   (&optional __y_max_uv)
   (if __y_max_uv (setq _y_max_uv __y_max_uv)) _y_max_uv)
  (:serialization-length
   ()
   (+
    ;; int32 _x_min_uv
    4
    ;; int32 _y_min_uv
    4
    ;; int32 _x_max_uv
    4
    ;; int32 _y_max_uv
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; int32 _x_min_uv
       (write-long _x_min_uv s)
     ;; int32 _y_min_uv
       (write-long _y_min_uv s)
     ;; int32 _x_max_uv
       (write-long _x_max_uv s)
     ;; int32 _y_max_uv
       (write-long _y_max_uv s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; int32 _x_min_uv
     (setq _x_min_uv (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_min_uv
     (setq _y_min_uv (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _x_max_uv
     (setq _x_max_uv (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _y_max_uv
     (setq _y_max_uv (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(defclass realsense_camera::get_rgb_uv
  :super ros::object
  :slots ())

(setf (get realsense_camera::get_rgb_uv :md5sum-) "0eb5e9c6325d1b134d64fc42997917cc")
(setf (get realsense_camera::get_rgb_uv :datatype-) "realsense_camera/get_rgb_uv")
(setf (get realsense_camera::get_rgb_uv :request) realsense_camera::get_rgb_uvRequest)
(setf (get realsense_camera::get_rgb_uv :response) realsense_camera::get_rgb_uvResponse)

(defmethod realsense_camera::get_rgb_uvRequest
  (:response () (instance realsense_camera::get_rgb_uvResponse :init)))

(setf (get realsense_camera::get_rgb_uvRequest :md5sum-) "0eb5e9c6325d1b134d64fc42997917cc")
(setf (get realsense_camera::get_rgb_uvRequest :datatype-) "realsense_camera/get_rgb_uvRequest")
(setf (get realsense_camera::get_rgb_uvRequest :definition-)
      "int32 x_min_depth
int32 x_min_xy
int32 y_min_depth
int32 y_min_xy
int32 x_max_depth
int32 x_max_xy
int32 y_max_depth
int32 y_max_xy
---
int32 x_min_uv
int32 y_min_uv
int32 x_max_uv
int32 y_max_uv
")

(setf (get realsense_camera::get_rgb_uvResponse :md5sum-) "0eb5e9c6325d1b134d64fc42997917cc")
(setf (get realsense_camera::get_rgb_uvResponse :datatype-) "realsense_camera/get_rgb_uvResponse")
(setf (get realsense_camera::get_rgb_uvResponse :definition-)
      "int32 x_min_depth
int32 x_min_xy
int32 y_min_depth
int32 y_min_xy
int32 x_max_depth
int32 x_max_xy
int32 y_max_depth
int32 y_max_xy
---
int32 x_min_uv
int32 y_min_uv
int32 x_max_uv
int32 y_max_uv
")



(provide :realsense_camera/get_rgb_uv "0eb5e9c6325d1b134d64fc42997917cc")


