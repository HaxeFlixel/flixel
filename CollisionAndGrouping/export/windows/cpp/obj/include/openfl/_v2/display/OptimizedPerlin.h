#ifndef INCLUDED_openfl__v2_display_OptimizedPerlin
#define INCLUDED_openfl__v2_display_OptimizedPerlin

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,OptimizedPerlin)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  OptimizedPerlin_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef OptimizedPerlin_obj OBJ_;
		OptimizedPerlin_obj();
		Void __construct(hx::Null< int >  __o_seed,hx::Null< int >  __o_numOctaves,hx::Null< Float >  __o_falloff);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< OptimizedPerlin_obj > __new(hx::Null< int >  __o_seed,hx::Null< int >  __o_numOctaves,hx::Null< Float >  __o_falloff);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~OptimizedPerlin_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("OptimizedPerlin"); }

		int octaves;
		Array< Float > aOctFreq;
		Array< Float > aOctPers;
		Float fPersMax;
		Float iXoffset;
		Float iYoffset;
		Float iZoffset;
		Float baseFactor;
		virtual Void fill( ::openfl::_v2::display::BitmapData bitmap,Float _x,Float _y,Float _z,Dynamic _);
		Dynamic fill_dyn();

		virtual Void octFreqPers( Float fPersistence);
		Dynamic octFreqPers_dyn();

		virtual Void seedOffset( int iSeed);
		Dynamic seedOffset_dyn();

		static Array< int > P;
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_OptimizedPerlin */ 
