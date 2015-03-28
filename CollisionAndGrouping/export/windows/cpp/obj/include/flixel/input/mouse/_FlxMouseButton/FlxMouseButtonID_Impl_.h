#ifndef INCLUDED_flixel_input_mouse__FlxMouseButton_FlxMouseButtonID_Impl_
#define INCLUDED_flixel_input_mouse__FlxMouseButton_FlxMouseButtonID_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS4(flixel,input,mouse,_FlxMouseButton,FlxMouseButtonID_Impl_)
namespace flixel{
namespace input{
namespace mouse{
namespace _FlxMouseButton{


class HXCPP_CLASS_ATTRIBUTES  FlxMouseButtonID_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxMouseButtonID_Impl__obj OBJ_;
		FlxMouseButtonID_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMouseButtonID_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMouseButtonID_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxMouseButtonID_Impl_"); }

		static int LEFT;
		static int MIDDLE;
		static int RIGHT;
};

} // end namespace flixel
} // end namespace input
} // end namespace mouse
} // end namespace _FlxMouseButton

#endif /* INCLUDED_flixel_input_mouse__FlxMouseButton_FlxMouseButtonID_Impl_ */ 
