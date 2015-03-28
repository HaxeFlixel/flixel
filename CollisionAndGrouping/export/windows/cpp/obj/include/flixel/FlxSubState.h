#ifndef INCLUDED_flixel_FlxSubState
#define INCLUDED_flixel_FlxSubState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxState.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS1(flixel,FlxState)
HX_DECLARE_CLASS1(flixel,FlxSubState)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,system,FlxBGSprite)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  FlxSubState_obj : public ::flixel::FlxState_obj{
	public:
		typedef ::flixel::FlxState_obj super;
		typedef FlxSubState_obj OBJ_;
		FlxSubState_obj();
		Void __construct(hx::Null< int >  __o_BGColor);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSubState_obj > __new(hx::Null< int >  __o_BGColor);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSubState_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxSubState"); }

		Dynamic closeCallback;
		Dynamic &closeCallback_dyn() { return closeCallback;}
		::flixel::system::FlxBGSprite _bgSprite;
		::flixel::FlxState _parentState;
		int _bgColor;
		bool _created;
		virtual Void draw( );

		virtual Void destroy( );

		virtual Void close( );
		Dynamic close_dyn();

		virtual int get_bgColor( );

		virtual int set_bgColor( int _tmp_Value);

};

} // end namespace flixel

#endif /* INCLUDED_flixel_FlxSubState */ 
