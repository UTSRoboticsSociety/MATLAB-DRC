// Auto-generated. Do not edit!

// (in-package realsense_camera.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------


//-----------------------------------------------------------

class get_rgb_uvRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.x_min_depth = null;
      this.x_min_xy = null;
      this.y_min_depth = null;
      this.y_min_xy = null;
      this.x_max_depth = null;
      this.x_max_xy = null;
      this.y_max_depth = null;
      this.y_max_xy = null;
    }
    else {
      if (initObj.hasOwnProperty('x_min_depth')) {
        this.x_min_depth = initObj.x_min_depth
      }
      else {
        this.x_min_depth = 0;
      }
      if (initObj.hasOwnProperty('x_min_xy')) {
        this.x_min_xy = initObj.x_min_xy
      }
      else {
        this.x_min_xy = 0;
      }
      if (initObj.hasOwnProperty('y_min_depth')) {
        this.y_min_depth = initObj.y_min_depth
      }
      else {
        this.y_min_depth = 0;
      }
      if (initObj.hasOwnProperty('y_min_xy')) {
        this.y_min_xy = initObj.y_min_xy
      }
      else {
        this.y_min_xy = 0;
      }
      if (initObj.hasOwnProperty('x_max_depth')) {
        this.x_max_depth = initObj.x_max_depth
      }
      else {
        this.x_max_depth = 0;
      }
      if (initObj.hasOwnProperty('x_max_xy')) {
        this.x_max_xy = initObj.x_max_xy
      }
      else {
        this.x_max_xy = 0;
      }
      if (initObj.hasOwnProperty('y_max_depth')) {
        this.y_max_depth = initObj.y_max_depth
      }
      else {
        this.y_max_depth = 0;
      }
      if (initObj.hasOwnProperty('y_max_xy')) {
        this.y_max_xy = initObj.y_max_xy
      }
      else {
        this.y_max_xy = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type get_rgb_uvRequest
    // Serialize message field [x_min_depth]
    bufferOffset = _serializer.int32(obj.x_min_depth, buffer, bufferOffset);
    // Serialize message field [x_min_xy]
    bufferOffset = _serializer.int32(obj.x_min_xy, buffer, bufferOffset);
    // Serialize message field [y_min_depth]
    bufferOffset = _serializer.int32(obj.y_min_depth, buffer, bufferOffset);
    // Serialize message field [y_min_xy]
    bufferOffset = _serializer.int32(obj.y_min_xy, buffer, bufferOffset);
    // Serialize message field [x_max_depth]
    bufferOffset = _serializer.int32(obj.x_max_depth, buffer, bufferOffset);
    // Serialize message field [x_max_xy]
    bufferOffset = _serializer.int32(obj.x_max_xy, buffer, bufferOffset);
    // Serialize message field [y_max_depth]
    bufferOffset = _serializer.int32(obj.y_max_depth, buffer, bufferOffset);
    // Serialize message field [y_max_xy]
    bufferOffset = _serializer.int32(obj.y_max_xy, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type get_rgb_uvRequest
    let len;
    let data = new get_rgb_uvRequest(null);
    // Deserialize message field [x_min_depth]
    data.x_min_depth = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [x_min_xy]
    data.x_min_xy = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_min_depth]
    data.y_min_depth = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_min_xy]
    data.y_min_xy = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [x_max_depth]
    data.x_max_depth = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [x_max_xy]
    data.x_max_xy = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_max_depth]
    data.y_max_depth = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_max_xy]
    data.y_max_xy = _deserializer.int32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 32;
  }

  static datatype() {
    // Returns string type for a service object
    return 'realsense_camera/get_rgb_uvRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'a92ee70ae3aa698002080ad29e31d017';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    int32 x_min_depth
    int32 x_min_xy
    int32 y_min_depth
    int32 y_min_xy
    int32 x_max_depth
    int32 x_max_xy
    int32 y_max_depth
    int32 y_max_xy
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new get_rgb_uvRequest(null);
    if (msg.x_min_depth !== undefined) {
      resolved.x_min_depth = msg.x_min_depth;
    }
    else {
      resolved.x_min_depth = 0
    }

    if (msg.x_min_xy !== undefined) {
      resolved.x_min_xy = msg.x_min_xy;
    }
    else {
      resolved.x_min_xy = 0
    }

    if (msg.y_min_depth !== undefined) {
      resolved.y_min_depth = msg.y_min_depth;
    }
    else {
      resolved.y_min_depth = 0
    }

    if (msg.y_min_xy !== undefined) {
      resolved.y_min_xy = msg.y_min_xy;
    }
    else {
      resolved.y_min_xy = 0
    }

    if (msg.x_max_depth !== undefined) {
      resolved.x_max_depth = msg.x_max_depth;
    }
    else {
      resolved.x_max_depth = 0
    }

    if (msg.x_max_xy !== undefined) {
      resolved.x_max_xy = msg.x_max_xy;
    }
    else {
      resolved.x_max_xy = 0
    }

    if (msg.y_max_depth !== undefined) {
      resolved.y_max_depth = msg.y_max_depth;
    }
    else {
      resolved.y_max_depth = 0
    }

    if (msg.y_max_xy !== undefined) {
      resolved.y_max_xy = msg.y_max_xy;
    }
    else {
      resolved.y_max_xy = 0
    }

    return resolved;
    }
};

class get_rgb_uvResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.x_min_uv = null;
      this.y_min_uv = null;
      this.x_max_uv = null;
      this.y_max_uv = null;
    }
    else {
      if (initObj.hasOwnProperty('x_min_uv')) {
        this.x_min_uv = initObj.x_min_uv
      }
      else {
        this.x_min_uv = 0;
      }
      if (initObj.hasOwnProperty('y_min_uv')) {
        this.y_min_uv = initObj.y_min_uv
      }
      else {
        this.y_min_uv = 0;
      }
      if (initObj.hasOwnProperty('x_max_uv')) {
        this.x_max_uv = initObj.x_max_uv
      }
      else {
        this.x_max_uv = 0;
      }
      if (initObj.hasOwnProperty('y_max_uv')) {
        this.y_max_uv = initObj.y_max_uv
      }
      else {
        this.y_max_uv = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type get_rgb_uvResponse
    // Serialize message field [x_min_uv]
    bufferOffset = _serializer.int32(obj.x_min_uv, buffer, bufferOffset);
    // Serialize message field [y_min_uv]
    bufferOffset = _serializer.int32(obj.y_min_uv, buffer, bufferOffset);
    // Serialize message field [x_max_uv]
    bufferOffset = _serializer.int32(obj.x_max_uv, buffer, bufferOffset);
    // Serialize message field [y_max_uv]
    bufferOffset = _serializer.int32(obj.y_max_uv, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type get_rgb_uvResponse
    let len;
    let data = new get_rgb_uvResponse(null);
    // Deserialize message field [x_min_uv]
    data.x_min_uv = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_min_uv]
    data.y_min_uv = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [x_max_uv]
    data.x_max_uv = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [y_max_uv]
    data.y_max_uv = _deserializer.int32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 16;
  }

  static datatype() {
    // Returns string type for a service object
    return 'realsense_camera/get_rgb_uvResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '36c20a9a661d32cf44ffca6c6be7e4a2';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    int32 x_min_uv
    int32 y_min_uv
    int32 x_max_uv
    int32 y_max_uv
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new get_rgb_uvResponse(null);
    if (msg.x_min_uv !== undefined) {
      resolved.x_min_uv = msg.x_min_uv;
    }
    else {
      resolved.x_min_uv = 0
    }

    if (msg.y_min_uv !== undefined) {
      resolved.y_min_uv = msg.y_min_uv;
    }
    else {
      resolved.y_min_uv = 0
    }

    if (msg.x_max_uv !== undefined) {
      resolved.x_max_uv = msg.x_max_uv;
    }
    else {
      resolved.x_max_uv = 0
    }

    if (msg.y_max_uv !== undefined) {
      resolved.y_max_uv = msg.y_max_uv;
    }
    else {
      resolved.y_max_uv = 0
    }

    return resolved;
    }
};

module.exports = {
  Request: get_rgb_uvRequest,
  Response: get_rgb_uvResponse,
  md5sum() { return '0eb5e9c6325d1b134d64fc42997917cc'; },
  datatype() { return 'realsense_camera/get_rgb_uv'; }
};
