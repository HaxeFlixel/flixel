#ifndef INCLUDED_flixel_input_FlxBaseKeyList
#define INCLUDED_flixel_input_FlxBaseKeyList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,input,FlxBaseKeyList)
HX_DECLARE_CLASS2(flixel,input,FlxKeyManager)
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace input{


class HXCPP_CLASS_ATTRIBUTES  FlxBaseKeyList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxBaseKeyList_obj OBJ_;
		FlxBaseKeyList_obj();
		Void __construct(int status,::flixel::input::FlxKeyManager keyManager);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBaseKeyList_obj > __new(int status,::flixel::input::FlxKeyManager keyManager);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBaseKeyList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxBaseKeyList"); }

		int status;
		::flixel::input::FlxKeyManager keyManager;
		virtual bool check( int keyCode);
		Dynamic check_dyn();

		virtual bool get_ANY( );
		Dynamic get_ANY_dyn();

};

} // end namespace flixel
} // end namespace input

#endif /* INCLUDED_flixel_input_FlxBaseKeyList */ 
