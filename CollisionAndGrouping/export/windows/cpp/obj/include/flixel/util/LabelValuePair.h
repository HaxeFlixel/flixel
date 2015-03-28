#ifndef INCLUDED_flixel_util_LabelValuePair
#define INCLUDED_flixel_util_LabelValuePair

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,util,FlxPool_flixel_util_LabelValuePair)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,LabelValuePair)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  LabelValuePair_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef LabelValuePair_obj OBJ_;
		LabelValuePair_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< LabelValuePair_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~LabelValuePair_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< LabelValuePair_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("LabelValuePair"); }

		::String label;
		Dynamic value;
		virtual ::flixel::util::LabelValuePair create( ::String label,Dynamic value);
		Dynamic create_dyn();

		virtual Void put( );
		Dynamic put_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		static ::flixel::util::FlxPool_flixel_util_LabelValuePair _pool;
		static ::flixel::util::LabelValuePair weak( ::String label,Dynamic value);
		static Dynamic weak_dyn();

};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_LabelValuePair */ 
