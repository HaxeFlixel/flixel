#ifndef INCLUDED_zpp_nape_geom_ZPP_Vec3
#define INCLUDED_zpp_nape_geom_ZPP_Vec3

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec3)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_Vec3_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_Vec3_obj OBJ_;
		ZPP_Vec3_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_Vec3_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_Vec3_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ZPP_Vec3"); }

		::nape::geom::Vec3 outer;
		Float x;
		Float y;
		Float z;
		bool immutable;
		Dynamic _validate;
		Dynamic &_validate_dyn() { return _validate;}
		virtual Void validate( );
		Dynamic validate_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_Vec3 */ 
