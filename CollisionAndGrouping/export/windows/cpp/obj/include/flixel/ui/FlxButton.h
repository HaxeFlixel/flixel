#ifndef INCLUDED_flixel_ui_FlxButton
#define INCLUDED_flixel_ui_FlxButton

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/ui/FlxTypedButton.h>
#include <flixel/input/IFlxInput.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS2(flixel,ui,FlxButton)
HX_DECLARE_CLASS2(flixel,ui,FlxTypedButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace ui{


class HXCPP_CLASS_ATTRIBUTES  FlxButton_obj : public ::flixel::ui::FlxTypedButton_obj{
	public:
		typedef ::flixel::ui::FlxTypedButton_obj super;
		typedef FlxButton_obj OBJ_;
		FlxButton_obj();
		Void __construct(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,::String Text,Dynamic OnClick);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxButton_obj > __new(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,::String Text,Dynamic OnClick);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxButton_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		inline operator ::flixel::input::IFlxInput_obj *()
			{ return new ::flixel::input::IFlxInput_delegate_< FlxButton_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxButton"); }

		virtual Void resetHelpers( );

		virtual Void initLabel( ::String Text);
		Dynamic initLabel_dyn();

		virtual ::String get_text( );
		Dynamic get_text_dyn();

		virtual ::String set_text( ::String Text);
		Dynamic set_text_dyn();

		static int NORMAL;
		static int HIGHLIGHT;
		static int PRESSED;
};

} // end namespace flixel
} // end namespace ui

#endif /* INCLUDED_flixel_ui_FlxButton */ 
