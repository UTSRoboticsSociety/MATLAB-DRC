; Auto-generated. Do not edit!


(cl:in-package rosserial_arduino-srv)


;//! \htmlinclude TurnAngle-request.msg.html

(cl:defclass <TurnAngle-request> (roslisp-msg-protocol:ros-message)
  ((angle
    :reader angle
    :initarg :angle
    :type cl:float
    :initform 0.0))
)

(cl:defclass TurnAngle-request (<TurnAngle-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TurnAngle-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TurnAngle-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name rosserial_arduino-srv:<TurnAngle-request> is deprecated: use rosserial_arduino-srv:TurnAngle-request instead.")))

(cl:ensure-generic-function 'angle-val :lambda-list '(m))
(cl:defmethod angle-val ((m <TurnAngle-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader rosserial_arduino-srv:angle-val is deprecated.  Use rosserial_arduino-srv:angle instead.")
  (angle m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TurnAngle-request>) ostream)
  "Serializes a message object of type '<TurnAngle-request>"
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'angle))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TurnAngle-request>) istream)
  "Deserializes a message object of type '<TurnAngle-request>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'angle) (roslisp-utils:decode-single-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TurnAngle-request>)))
  "Returns string type for a service object of type '<TurnAngle-request>"
  "rosserial_arduino/TurnAngleRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TurnAngle-request)))
  "Returns string type for a service object of type 'TurnAngle-request"
  "rosserial_arduino/TurnAngleRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TurnAngle-request>)))
  "Returns md5sum for a message object of type '<TurnAngle-request>"
  "2d11dcdbe5a6f73dd324353dc52315ab")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TurnAngle-request)))
  "Returns md5sum for a message object of type 'TurnAngle-request"
  "2d11dcdbe5a6f73dd324353dc52315ab")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TurnAngle-request>)))
  "Returns full string definition for message of type '<TurnAngle-request>"
  (cl:format cl:nil "float32 angle~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TurnAngle-request)))
  "Returns full string definition for message of type 'TurnAngle-request"
  (cl:format cl:nil "float32 angle~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TurnAngle-request>))
  (cl:+ 0
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TurnAngle-request>))
  "Converts a ROS message object to a list"
  (cl:list 'TurnAngle-request
    (cl:cons ':angle (angle msg))
))
;//! \htmlinclude TurnAngle-response.msg.html

(cl:defclass <TurnAngle-response> (roslisp-msg-protocol:ros-message)
  ()
)

(cl:defclass TurnAngle-response (<TurnAngle-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TurnAngle-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TurnAngle-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name rosserial_arduino-srv:<TurnAngle-response> is deprecated: use rosserial_arduino-srv:TurnAngle-response instead.")))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TurnAngle-response>) ostream)
  "Serializes a message object of type '<TurnAngle-response>"
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TurnAngle-response>) istream)
  "Deserializes a message object of type '<TurnAngle-response>"
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TurnAngle-response>)))
  "Returns string type for a service object of type '<TurnAngle-response>"
  "rosserial_arduino/TurnAngleResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TurnAngle-response)))
  "Returns string type for a service object of type 'TurnAngle-response"
  "rosserial_arduino/TurnAngleResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TurnAngle-response>)))
  "Returns md5sum for a message object of type '<TurnAngle-response>"
  "2d11dcdbe5a6f73dd324353dc52315ab")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TurnAngle-response)))
  "Returns md5sum for a message object of type 'TurnAngle-response"
  "2d11dcdbe5a6f73dd324353dc52315ab")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TurnAngle-response>)))
  "Returns full string definition for message of type '<TurnAngle-response>"
  (cl:format cl:nil "~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TurnAngle-response)))
  "Returns full string definition for message of type 'TurnAngle-response"
  (cl:format cl:nil "~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TurnAngle-response>))
  (cl:+ 0
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TurnAngle-response>))
  "Converts a ROS message object to a list"
  (cl:list 'TurnAngle-response
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'TurnAngle)))
  'TurnAngle-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'TurnAngle)))
  'TurnAngle-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TurnAngle)))
  "Returns string type for a service object of type '<TurnAngle>"
  "rosserial_arduino/TurnAngle")