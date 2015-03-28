#ifndef INCLUDED_PlayState
#define INCLUDED_PlayState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxState.h>
HX_DECLARE_CLASS0(PlayState)
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS1(flixel,FlxState)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,input,IFlxInput)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS3(flixel,phys,nape,FlxNapeSpace)
HX_DECLARE_CLASS2(flixel,text,FlxText)
HX_DECLARE_CLASS2(flixel,ui,FlxButton)
HX_DECLARE_CLASS2(flixel,ui,FlxTypedButton)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)


class HXCPP_CLASS_ATTRIBUTES  PlayState_obj : public ::flixel::FlxState_obj{
	public:
		typedef ::flixel::FlxState_obj super;
		typedef PlayState_obj OBJ_;
		PlayState_obj();
		Void __construct(Dynamic MaxSize);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< PlayState_obj > __new(Dynamic MaxSize);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~PlayState_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("PlayState"); }

		::flixel::text::FlxText _topText;
		::flixel::FlxSprite _elevator;
		::flixel::FlxSprite _crate;
		int _numCrates;
		::flixel::group::FlxTypedGroup _crateStormGroup;
		::flixel::group::FlxTypedGroup _crateStormGroup2;
		::flixel::group::FlxTypedGroup _crateStormMegaGroup;
		::flixel::FlxSprite _flixelRider;
		::flixel::ui::FlxButton _crateStorm;
		::flixel::ui::FlxButton _crateStormG1;
		::flixel::ui::FlxButton _crateStormG2;
		::flixel::ui::FlxButton _quitButton;
		::flixel::ui::FlxButton _flxRiderButton;
		::flixel::ui::FlxButton _groupCollision;
		bool _isCrateStormOn;
		bool _isFlxRiderOn;
		bool _collideGroups;
		bool _redGroup;
		bool _blueGroup;
		bool _rising;
		::flixel::phys::nape::FlxNapeSpace space;
		virtual Void create( );

		virtual Void update( Float elapsed);

		virtual Void onFlixelRider( );
		Dynamic onFlixelRider_dyn();

		virtual Void onCrateStorm( );
		Dynamic onCrateStorm_dyn();

		virtual Void onBlue( );
		Dynamic onBlue_dyn();

		virtual Void onRed( );
		Dynamic onRed_dyn();

		virtual Void onCollideGroups( );
		Dynamic onCollideGroups_dyn();

		static bool useNewSystem;
};


#endif /* INCLUDED_PlayState */ 
