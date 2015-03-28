#ifndef INCLUDED_flixel_tweens_motion_Motion
#define INCLUDED_flixel_tweens_motion_Motion

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/tweens/FlxTween.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS3(flixel,tweens,motion,Motion)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tweens{
namespace motion{


class HXCPP_CLASS_ATTRIBUTES  Motion_obj : public ::flixel::tweens::FlxTween_obj{
	public:
		typedef ::flixel::tweens::FlxTween_obj super;
		typedef Motion_obj OBJ_;
		Motion_obj();
		Void __construct(Dynamic Options);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Motion_obj > __new(Dynamic Options);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Motion_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Motion"); }

		Float x;
		Float y;
		::flixel::FlxObject _object;
		bool _wasObjectImmovable;
		virtual Void destroy( );

		virtual ::flixel::tweens::motion::Motion setObject( ::flixel::FlxObject object);
		Dynamic setObject_dyn();

		virtual Void update( Float elapsed);

		virtual Void onEnd( );

		virtual Void postUpdate( );
		Dynamic postUpdate_dyn();

};

} // end namespace flixel
} // end namespace tweens
} // end namespace motion

#endif /* INCLUDED_flixel_tweens_motion_Motion */ 
