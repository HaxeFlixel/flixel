#ifndef INCLUDED_flixel_system_debug_TrackerProfile
#define INCLUDED_flixel_system_debug_TrackerProfile

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,TrackerProfile)
namespace flixel{
namespace system{
namespace debug{


class HXCPP_CLASS_ATTRIBUTES  TrackerProfile_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef TrackerProfile_obj OBJ_;
		TrackerProfile_obj();
		Void __construct(::Class ObjectClass,Array< ::String > Variables,Array< ::Dynamic > Extensions);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< TrackerProfile_obj > __new(::Class ObjectClass,Array< ::String > Variables,Array< ::Dynamic > Extensions);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~TrackerProfile_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("TrackerProfile"); }

		::Class objectClass;
		Array< ::String > variables;
		Array< ::Dynamic > extensions;
		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_TrackerProfile */ 
