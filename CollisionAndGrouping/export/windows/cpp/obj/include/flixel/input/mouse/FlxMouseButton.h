#ifndef INCLUDED_flixel_input_mouse_FlxMouseButton
#define INCLUDED_flixel_input_mouse_FlxMouseButton

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/FlxInput.h>
#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,input,FlxInput)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS3(flixel,input,mouse,FlxMouseButton)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace input{
namespace mouse{


class HXCPP_CLASS_ATTRIBUTES  FlxMouseButton_obj : public ::flixel::input::FlxInput_obj{
	public:
		typedef ::flixel::input::FlxInput_obj super;
		typedef FlxMouseButton_obj OBJ_;
		FlxMouseButton_obj();
		Void __construct(int ID);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxMouseButton_obj > __new(int ID);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxMouseButton_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxMouseButton_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxMouseButton"); }

		::flixel::math::FlxPoint justPressedPosition;
		Float justPressedTimeInTicks;
		virtual Void update( );

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void onDown( Dynamic _);
		Dynamic onDown_dyn();

		virtual Void onUp( Dynamic _);
		Dynamic onUp_dyn();

		static ::flixel::input::mouse::FlxMouseButton getFromID( int id);
		static Dynamic getFromID_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace mouse

#endif /* INCLUDED_flixel_input_mouse_FlxMouseButton */ 
