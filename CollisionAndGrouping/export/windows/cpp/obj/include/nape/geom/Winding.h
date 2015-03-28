#ifndef INCLUDED_nape_geom_Winding
#define INCLUDED_nape_geom_Winding

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Winding)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Winding_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Winding_obj OBJ_;
		Winding_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Winding_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Winding_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Winding"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::geom::Winding get_UNDEFINED( );
		static Dynamic get_UNDEFINED_dyn();

		static ::nape::geom::Winding get_CLOCKWISE( );
		static Dynamic get_CLOCKWISE_dyn();

		static ::nape::geom::Winding get_ANTICLOCKWISE( );
		static Dynamic get_ANTICLOCKWISE_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_Winding */ 
