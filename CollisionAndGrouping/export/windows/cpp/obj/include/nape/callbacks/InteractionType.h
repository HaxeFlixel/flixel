#ifndef INCLUDED_nape_callbacks_InteractionType
#define INCLUDED_nape_callbacks_InteractionType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,callbacks,InteractionType)
namespace nape{
namespace callbacks{


class HXCPP_CLASS_ATTRIBUTES  InteractionType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef InteractionType_obj OBJ_;
		InteractionType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< InteractionType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~InteractionType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("InteractionType"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::callbacks::InteractionType get_COLLISION( );
		static Dynamic get_COLLISION_dyn();

		static ::nape::callbacks::InteractionType get_SENSOR( );
		static Dynamic get_SENSOR_dyn();

		static ::nape::callbacks::InteractionType get_FLUID( );
		static Dynamic get_FLUID_dyn();

		static ::nape::callbacks::InteractionType get_ANY( );
		static Dynamic get_ANY_dyn();

};

} // end namespace nape
} // end namespace callbacks

#endif /* INCLUDED_nape_callbacks_InteractionType */ 
