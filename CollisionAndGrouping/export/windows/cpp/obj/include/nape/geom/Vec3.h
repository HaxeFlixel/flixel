#ifndef INCLUDED_nape_geom_Vec3
#define INCLUDED_nape_geom_Vec3

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,geom,Vec3)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec3)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Vec3_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Vec3_obj OBJ_;
		Vec3_obj();
		Void __construct(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y,hx::Null< Float >  __o_z);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Vec3_obj > __new(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y,hx::Null< Float >  __o_z);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Vec3_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Vec3"); }

		::zpp_nape::geom::ZPP_Vec3 zpp_inner;
		::nape::geom::Vec3 zpp_pool;
		bool zpp_disp;
		virtual Float get_x( );
		Dynamic get_x_dyn();

		virtual Float set_x( Float x);
		Dynamic set_x_dyn();

		virtual Float get_y( );
		Dynamic get_y_dyn();

		virtual Float set_y( Float y);
		Dynamic set_y_dyn();

		virtual Float get_z( );
		Dynamic get_z_dyn();

		virtual Float set_z( Float z);
		Dynamic set_z_dyn();

		virtual Void dispose( );
		Dynamic dispose_dyn();

		virtual Float get_length( );
		Dynamic get_length_dyn();

		virtual Float set_length( Float length);
		Dynamic set_length_dyn();

		virtual Float lsq( );
		Dynamic lsq_dyn();

		virtual ::nape::geom::Vec3 set( ::nape::geom::Vec3 vector);
		Dynamic set_dyn();

		virtual ::nape::geom::Vec3 setxyz( Float x,Float y,Float z);
		Dynamic setxyz_dyn();

		virtual ::nape::geom::Vec2 xy( hx::Null< bool >  weak);
		Dynamic xy_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::geom::Vec3 get( hx::Null< Float >  x,hx::Null< Float >  y,hx::Null< Float >  z);
		static Dynamic get_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_Vec3 */ 
