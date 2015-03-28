#ifndef INCLUDED_flixel_tweens_misc_NumTween
#define INCLUDED_flixel_tweens_misc_NumTween

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/tweens/FlxTween.h>
HX_DECLARE_CLASS2(flixel,tweens,FlxTween)
HX_DECLARE_CLASS3(flixel,tweens,misc,NumTween)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tweens{
namespace misc{


class HXCPP_CLASS_ATTRIBUTES  NumTween_obj : public ::flixel::tweens::FlxTween_obj{
	public:
		typedef ::flixel::tweens::FlxTween_obj super;
		typedef NumTween_obj OBJ_;
		NumTween_obj();
		Void __construct(Dynamic Options);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< NumTween_obj > __new(Dynamic Options);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~NumTween_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("NumTween"); }

		Float value;
		Dynamic _tweenFunction;
		Dynamic &_tweenFunction_dyn() { return _tweenFunction;}
		Float _start;
		Float _range;
		virtual Void destroy( );

		virtual ::flixel::tweens::misc::NumTween tween( Float fromValue,Float toValue,Float duration,Dynamic tweenFunction);
		Dynamic tween_dyn();

		virtual Void update( Float elapsed);

};

} // end namespace flixel
} // end namespace tweens
} // end namespace misc

#endif /* INCLUDED_flixel_tweens_misc_NumTween */ 
