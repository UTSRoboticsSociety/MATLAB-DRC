// Generated by gencpp from file realsense_camera/get_rgb_uvRequest.msg
// DO NOT EDIT!


#ifndef REALSENSE_CAMERA_MESSAGE_GET_RGB_UVREQUEST_H
#define REALSENSE_CAMERA_MESSAGE_GET_RGB_UVREQUEST_H


#include <string>
#include <vector>
#include <map>

#include <ros/types.h>
#include <ros/serialization.h>
#include <ros/builtin_message_traits.h>
#include <ros/message_operations.h>


namespace realsense_camera
{
template <class ContainerAllocator>
struct get_rgb_uvRequest_
{
  typedef get_rgb_uvRequest_<ContainerAllocator> Type;

  get_rgb_uvRequest_()
    : x_min_depth(0)
    , x_min_xy(0)
    , y_min_depth(0)
    , y_min_xy(0)
    , x_max_depth(0)
    , x_max_xy(0)
    , y_max_depth(0)
    , y_max_xy(0)  {
    }
  get_rgb_uvRequest_(const ContainerAllocator& _alloc)
    : x_min_depth(0)
    , x_min_xy(0)
    , y_min_depth(0)
    , y_min_xy(0)
    , x_max_depth(0)
    , x_max_xy(0)
    , y_max_depth(0)
    , y_max_xy(0)  {
  (void)_alloc;
    }



   typedef int32_t _x_min_depth_type;
  _x_min_depth_type x_min_depth;

   typedef int32_t _x_min_xy_type;
  _x_min_xy_type x_min_xy;

   typedef int32_t _y_min_depth_type;
  _y_min_depth_type y_min_depth;

   typedef int32_t _y_min_xy_type;
  _y_min_xy_type y_min_xy;

   typedef int32_t _x_max_depth_type;
  _x_max_depth_type x_max_depth;

   typedef int32_t _x_max_xy_type;
  _x_max_xy_type x_max_xy;

   typedef int32_t _y_max_depth_type;
  _y_max_depth_type y_max_depth;

   typedef int32_t _y_max_xy_type;
  _y_max_xy_type y_max_xy;





  typedef boost::shared_ptr< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> const> ConstPtr;

}; // struct get_rgb_uvRequest_

typedef ::realsense_camera::get_rgb_uvRequest_<std::allocator<void> > get_rgb_uvRequest;

typedef boost::shared_ptr< ::realsense_camera::get_rgb_uvRequest > get_rgb_uvRequestPtr;
typedef boost::shared_ptr< ::realsense_camera::get_rgb_uvRequest const> get_rgb_uvRequestConstPtr;

// constants requiring out of line definition



template<typename ContainerAllocator>
std::ostream& operator<<(std::ostream& s, const ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> & v)
{
ros::message_operations::Printer< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >::stream(s, "", v);
return s;
}

} // namespace realsense_camera

namespace ros
{
namespace message_traits
{



// BOOLTRAITS {'IsFixedSize': True, 'IsMessage': True, 'HasHeader': False}
// {'realsense_camera': ['/home/robosoc/drc_ws/src/realsense_camera/msg'], 'std_msgs': ['/opt/ros/melodic/share/std_msgs/cmake/../msg']}

// !!!!!!!!!!! ['__class__', '__delattr__', '__dict__', '__doc__', '__eq__', '__format__', '__getattribute__', '__hash__', '__init__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_parsed_fields', 'constants', 'fields', 'full_name', 'has_header', 'header_present', 'names', 'package', 'parsed_fields', 'short_name', 'text', 'types']




template <class ContainerAllocator>
struct IsFixedSize< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
  : TrueType
  { };

template <class ContainerAllocator>
struct IsFixedSize< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> const>
  : TrueType
  { };

template <class ContainerAllocator>
struct IsMessage< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
  : TrueType
  { };

template <class ContainerAllocator>
struct IsMessage< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> const>
  : TrueType
  { };

template <class ContainerAllocator>
struct HasHeader< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
  : FalseType
  { };

template <class ContainerAllocator>
struct HasHeader< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> const>
  : FalseType
  { };


template<class ContainerAllocator>
struct MD5Sum< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "a92ee70ae3aa698002080ad29e31d017";
  }

  static const char* value(const ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator>&) { return value(); }
  static const uint64_t static_value1 = 0xa92ee70ae3aa6980ULL;
  static const uint64_t static_value2 = 0x02080ad29e31d017ULL;
};

template<class ContainerAllocator>
struct DataType< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "realsense_camera/get_rgb_uvRequest";
  }

  static const char* value(const ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator>&) { return value(); }
};

template<class ContainerAllocator>
struct Definition< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "int32 x_min_depth\n"
"int32 x_min_xy\n"
"int32 y_min_depth\n"
"int32 y_min_xy\n"
"int32 x_max_depth\n"
"int32 x_max_xy\n"
"int32 y_max_depth\n"
"int32 y_max_xy\n"
;
  }

  static const char* value(const ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator>&) { return value(); }
};

} // namespace message_traits
} // namespace ros

namespace ros
{
namespace serialization
{

  template<class ContainerAllocator> struct Serializer< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
  {
    template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
    {
      stream.next(m.x_min_depth);
      stream.next(m.x_min_xy);
      stream.next(m.y_min_depth);
      stream.next(m.y_min_xy);
      stream.next(m.x_max_depth);
      stream.next(m.x_max_xy);
      stream.next(m.y_max_depth);
      stream.next(m.y_max_xy);
    }

    ROS_DECLARE_ALLINONE_SERIALIZER
  }; // struct get_rgb_uvRequest_

} // namespace serialization
} // namespace ros

namespace ros
{
namespace message_operations
{

template<class ContainerAllocator>
struct Printer< ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator> >
{
  template<typename Stream> static void stream(Stream& s, const std::string& indent, const ::realsense_camera::get_rgb_uvRequest_<ContainerAllocator>& v)
  {
    s << indent << "x_min_depth: ";
    Printer<int32_t>::stream(s, indent + "  ", v.x_min_depth);
    s << indent << "x_min_xy: ";
    Printer<int32_t>::stream(s, indent + "  ", v.x_min_xy);
    s << indent << "y_min_depth: ";
    Printer<int32_t>::stream(s, indent + "  ", v.y_min_depth);
    s << indent << "y_min_xy: ";
    Printer<int32_t>::stream(s, indent + "  ", v.y_min_xy);
    s << indent << "x_max_depth: ";
    Printer<int32_t>::stream(s, indent + "  ", v.x_max_depth);
    s << indent << "x_max_xy: ";
    Printer<int32_t>::stream(s, indent + "  ", v.x_max_xy);
    s << indent << "y_max_depth: ";
    Printer<int32_t>::stream(s, indent + "  ", v.y_max_depth);
    s << indent << "y_max_xy: ";
    Printer<int32_t>::stream(s, indent + "  ", v.y_max_xy);
  }
};

} // namespace message_operations
} // namespace ros

#endif // REALSENSE_CAMERA_MESSAGE_GET_RGB_UVREQUEST_H