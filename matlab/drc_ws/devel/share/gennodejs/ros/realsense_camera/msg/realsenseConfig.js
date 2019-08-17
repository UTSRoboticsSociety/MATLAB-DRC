// Auto-generated. Do not edit!

// (in-package realsense_camera.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

class realsenseConfig {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.depth_raw_unit = null;
    }
    else {
      if (initObj.hasOwnProperty('depth_raw_unit')) {
        this.depth_raw_unit = initObj.depth_raw_unit
      }
      else {
        this.depth_raw_unit = 0.0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type realsenseConfig
    // Serialize message field [depth_raw_unit]
    bufferOffset = _serializer.float32(obj.depth_raw_unit, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type realsenseConfig
    let len;
    let data = new realsenseConfig(null);
    // Deserialize message field [depth_raw_unit]
    data.depth_raw_unit = _deserializer.float32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 4;
  }

  static datatype() {
    // Returns string type for a message object
    return 'realsense_camera/realsenseConfig';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '78f677fac7365df7ab1d8244f7e2fa95';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    
    float32 depth_raw_unit
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new realsenseConfig(null);
    if (msg.depth_raw_unit !== undefined) {
      resolved.depth_raw_unit = msg.depth_raw_unit;
    }
    else {
      resolved.depth_raw_unit = 0.0
    }

    return resolved;
    }
};

module.exports = realsenseConfig;
