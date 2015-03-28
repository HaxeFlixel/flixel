#ifndef INCLUDED_flixel_system_replay_MouseRecord
#define INCLUDED_flixel_system_replay_MouseRecord

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,replay,MouseRecord)
namespace flixel{
namespace system{
namespace replay{


class HXCPP_CLASS_ATTRIBUTES  MouseRecord_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef MouseRecord_obj OBJ_;
		MouseRecord_obj();
		Void __construct(int x,int y,int button,int wheel);

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< MouseRecord_obj > __new(int x,int y,int button,int wheel);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~MouseRecord_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("MouseRecord"); }

		int x;
		int y;
		int button;
		int wheel;
};

} // end namespace flixel
} // end namespace system
} // end namespace replay

#endif /* INCLUDED_flixel_system_replay_MouseRecord */ 
