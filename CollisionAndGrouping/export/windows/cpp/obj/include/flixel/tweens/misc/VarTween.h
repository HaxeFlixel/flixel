#ifndef INCLUDED_flixel_tweens_misc_VarTween
#define INCLUDED_flixel_tweens_misc_VarTween

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/tweens/FlxTween.h>
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS3(flixel,tweens,misc,VarTween)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tweens{
namespace misc{


class HXCPP_CLASS_ATTRIBUTES  VarTween_obj : public ::flixel::tweens::FlxTween_obj{
	public:
		typedef ::flixel::tweens::FlxTween_obj super;
		typedef VarTween_obj OBJ_;
		VarTween_obj();
		Void __construct(Dynamic Options);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< VarTween_obj > __new(Dynamic Options);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~VarTween_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("VarTween"); }

		Dynamic _object;
		Dynamic _properties;
		Array< ::String > _vars;
		Array< Float > _startValues;
		Array< Float > _range;
		virtual Void destroy( );

		virtual ::flixel::tweens::misc::VarTween tween( Dynamic object,Dynamic properties,Float duration);
		Dynamic tween_dyn();

		virtual Void update( Float elapsed);

		virtual Void initializeVars( );
		Dynamic initializeVars_dyn();

};

} // end namespace flixel
} // end namespace tweens
} // end namespace misc

#endif /* INCLUDED_flixel_tweens_misc_VarTween */ 
