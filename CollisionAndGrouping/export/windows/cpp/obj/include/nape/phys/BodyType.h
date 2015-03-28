#ifndef INCLUDED_nape_phys_BodyType
#define INCLUDED_nape_phys_BodyType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,phys,BodyType)
namespace nape{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  BodyType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BodyType_obj OBJ_;
		BodyType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BodyType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BodyType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("BodyType"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::phys::BodyType get_STATIC( );
		static Dynamic get_STATIC_dyn();

		static ::nape::phys::BodyType get_DYNAMIC( );
		static Dynamic get_DYNAMIC_dyn();

		static ::nape::phys::BodyType get_KINEMATIC( );
		static Dynamic get_KINEMATIC_dyn();

};

} // end namespace nape
} // end namespace phys

#endif /* INCLUDED_nape_phys_BodyType */ 
