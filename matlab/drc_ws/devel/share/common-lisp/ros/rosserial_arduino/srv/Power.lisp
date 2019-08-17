; Auto-generated. Do not edit!


(cl:in-package rosserial_arduino-srv)


;//! \htmlinclude Power-request.msg.html

(cl:defclass <Power-request> (roslisp-msg-protocol:ros-message)
  ((power
    :reader power
    :initarg :power
    :type cl:float
    :initform 0.0))
)

(cl:defclass Power-request (<Power-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Power-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Power-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name rosserial_arduino-srv:<Power-request> is deprecated: use rosserial_arduino-srv:Power-request instead.")))

(cl:ensure-generic-function 'power-val :lambda-list '(m))
(cl:defmethod power-val ((m <Power-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader rosserial_arduino-srv:power-val is deprecated.  Use rosserial_arduino-srv:power instead.")
  (power m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Power-request>) ostream)
  "Serializes a message object of type '<Power-request>"
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'power))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Power-request>) istream)
  "Deserializes a message object of type '<Power-request>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'power) (roslisp-utils:decode-single-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Power-request>)))
  "Returns string type for a service object of type '<Power-request>"
  "rosserial_arduino/PowerRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Power-request)))
  "Returns string type for a service object of type 'Power-request"
  "rosserial_arduino/PowerRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Power-request>)))
  "Returns md5sum for a message object of type '<Power-request>"
  "b75f3bcdec2dcafb6503e9b6316400b0")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Power-request)))
  "Returns md5sum for a message object of type 'Power-request"
  "b75f3bcdec2dcafb6503e9b6316400b0")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Power-request>)))
  "Returns full string definition for message of type '<Power-request>"
  (cl:format cl:nil "float32 power~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Power-request)))
  "Returns full string definition for message of type 'Power-request"
  (cl:format cl:nil "float32 power~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Power-request>))
  (cl:+ 0
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Power-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Power-request
    (cl:cons ':power (power msg))
))
;//! \htmlinclude Power-response.msg.html

(cl:defclass <Power-response> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass Power-response (<Power-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Power-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Power-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name rosserial_arduino-srv:<Power-response> is deprecated: use rosserial_arduino-srv:Power-response instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Power-response>) ostream)
  "Serializes a message object of type '<Power-response>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Power-response>) istream)
  "Deserializes a message object of type '<Power-response>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Power-response>)))
  "Returns string type for a service object of type '<Power-response>"
  "rosserial_arduino/PowerResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Power-response)))
  "Returns string type for a service object of type 'Power-response"
  "rosserial_arduino/PowerResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Power-response>)))
  "Returns md5sum for a message object of type '<Power-response>"
  "b75f3bcdec2dcafb6503e9b6316400b0")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Power-response)))
  "Returns md5sum for a message object of type 'Power-response"
  "b75f3bcdec2dcafb6503e9b6316400b0")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Power-response>)))
  "Returns full string definition for message of type '<Power-response>"
  (cl:format cl:nil "~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Power-response)))
  "Returns full string definition for message of type 'Power-response"
  (cl:format cl:nil "~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Power-response>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Power-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Power-response
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Power)))
  'Power-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Power)))
  'Power-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Power)))
  "Returns string type for a service object of type '<Power>"
  "rosserial_arduino/Power")