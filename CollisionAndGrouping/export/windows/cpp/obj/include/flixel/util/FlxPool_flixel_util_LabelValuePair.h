#ifndef INCLUDED_flixel_util_FlxPool_flixel_util_LabelValuePair
#define INCLUDED_flixel_util_FlxPool_flixel_util_LabelValuePair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,util,FlxPool_flixel_util_LabelValuePair)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,LabelValuePair)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  FlxPool_flixel_util_LabelValuePair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxPool_flixel_util_LabelValuePair_obj OBJ_;
		FlxPool_flixel_util_LabelValuePair_obj();
		Void __construct(::Class classObj);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxPool_flixel_util_LabelValuePair_obj > __new(::Class classObj);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxPool_flixel_util_LabelValuePair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxPool_flixel_util_LabelValuePair"); }

		Array< ::Dynamic > _pool;
		::Class _class;
		int _count;
		virtual ::flixel::util::LabelValuePair get( );
		Dynamic get_dyn();

		virtual Void put( ::flixel::util::LabelValuePair obj);
		Dynamic put_dyn();

		virtual Void putUnsafe( ::flixel::util::LabelValuePair obj);
		Dynamic putUnsafe_dyn();

		virtual Void preAllocate( int numObjects);
		Dynamic preAllocate_dyn();

		virtual Array< ::Dynamic > clear( );
		Dynamic clear_dyn();

		virtual int get_length( );
		Dynamic get_length_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxPool_flixel_util_LabelValuePair */ 
