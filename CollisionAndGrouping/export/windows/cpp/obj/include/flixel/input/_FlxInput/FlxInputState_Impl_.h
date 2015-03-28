#ifndef INCLUDED_flixel_input__FlxInput_FlxInputState_Impl_
#define INCLUDED_flixel_input__FlxInput_FlxInputState_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,input,_FlxInput,FlxInputState_Impl_)
namespace flixel{
namespace input{
namespace _FlxInput{


class HXCPP_CLASS_ATTRIBUTES  FlxInputState_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxInputState_Impl__obj OBJ_;
		FlxInputState_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxInputState_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxInputState_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxInputState_Impl_"); }

		static int JUST_RELEASED;
		static int RELEASED;
		static int PRESSED;
		static int JUST_PRESSED;
};

} // end namespace flixel
} // end namespace input
} // end namespace _FlxInput

#endif /* INCLUDED_flixel_input__FlxInput_FlxInputState_Impl_ */ 
