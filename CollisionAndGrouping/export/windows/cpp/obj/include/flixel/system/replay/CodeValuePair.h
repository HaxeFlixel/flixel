#ifndef INCLUDED_flixel_system_replay_CodeValuePair
#define INCLUDED_flixel_system_replay_CodeValuePair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,replay,CodeValuePair)
namespace flixel{
namespace system{
namespace replay{


class HXCPP_CLASS_ATTRIBUTES  CodeValuePair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef CodeValuePair_obj OBJ_;
		CodeValuePair_obj();
		Void __construct(int code,int value);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< CodeValuePair_obj > __new(int code,int value);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~CodeValuePair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("CodeValuePair"); }

		int code;
		int value;
};

} // end namespace flixel
} // end namespace system
} // end namespace replay

#endif /* INCLUDED_flixel_system_replay_CodeValuePair */ 
