#ifndef INCLUDED_flixel_FlxState
#define INCLUDED_flixel_FlxState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/group/FlxTypedGroup.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxState)
HX_DECLARE_CLASS1(flixel,FlxSubState)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  FlxState_obj : public ::flixel::group::FlxTypedGroup_obj{
	public:
		typedef ::flixel::group::FlxTypedGroup_obj super;
		typedef FlxState_obj OBJ_;
		FlxState_obj();
		Void __construct(Dynamic MaxSize);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxState_obj > __new(Dynamic MaxSize);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxState_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxState"); }

		bool persistentUpdate;
		bool persistentDraw;
		bool destroySubStates;
		::flixel::FlxSubState subState;
		::flixel::FlxSubState _requestedSubState;
		bool _requestSubStateReset;
		virtual Void create( );
		Dynamic create_dyn();

		virtual Void draw( );

		virtual Void openSubState( ::flixel::FlxSubState SubState);
		Dynamic openSubState_dyn();

		virtual Void closeSubState( );
		Dynamic closeSubState_dyn();

		virtual Void resetSubState( );
		Dynamic resetSubState_dyn();

		virtual Void destroy( );

		virtual bool isTransitionNeeded( );
		Dynamic isTransitionNeeded_dyn();

		virtual Void transitionToState( ::flixel::FlxState State);
		Dynamic transitionToState_dyn();

		virtual Void onFocusLost( );
		Dynamic onFocusLost_dyn();

		virtual Void onFocus( );
		Dynamic onFocus_dyn();

		virtual Void onResize( int Width,int Height);
		Dynamic onResize_dyn();

		virtual Void tryUpdate( Float elapsed);
		Dynamic tryUpdate_dyn();

		virtual int get_bgColor( );
		Dynamic get_bgColor_dyn();

		virtual int set_bgColor( int Value);
		Dynamic set_bgColor_dyn();

};

} // end namespace flixel

#endif /* INCLUDED_flixel_FlxState */ 
