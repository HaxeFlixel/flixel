#ifndef INCLUDED_openfl__v2_utils_Float32Array
#define INCLUDED_openfl__v2_utils_Float32Array

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/utils/ArrayBufferView.h>
HX_DECLARE_CLASS3(openfl,_v2,utils,ArrayBufferView)
HX_DECLARE_CLASS3(openfl,_v2,utils,Float32Array)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS2(openfl,geom,Matrix3D)
namespace openfl{
namespace _v2{
namespace utils{


class HXCPP_CLASS_ATTRIBUTES  Float32Array_obj : public ::openfl::_v2::utils::ArrayBufferView_obj{
	public:
		typedef ::openfl::_v2::utils::ArrayBufferView_obj super;
		typedef Float32Array_obj OBJ_;
		Float32Array_obj();
		Void __construct(Dynamic bufferOrArray,hx::Null< int >  __o_start,Dynamic elements);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Float32Array_obj > __new(Dynamic bufferOrArray,hx::Null< int >  __o_start,Dynamic elements);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Float32Array_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Float32Array"); }

		typedef Float __array_access;
		int BYTES_PER_ELEMENT;
		int length;
		virtual Void __setLength( int nbFloat);
		Dynamic __setLength_dyn();

		virtual Float __get( int index);
		Dynamic __get_dyn();

		virtual Void __set( int index,Float value);
		Dynamic __set_dyn();

		static int SBYTES_PER_ELEMENT;
		static ::openfl::_v2::utils::Float32Array fromMatrix( ::openfl::geom::Matrix3D matrix);
		static Dynamic fromMatrix_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace utils

#endif /* INCLUDED_openfl__v2_utils_Float32Array */ 
