#ifndef INCLUDED_nape_geom_Vec2
#define INCLUDED_nape_geom_Vec2

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Vec2_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Vec2_obj OBJ_;
		Vec2_obj();
		Void __construct(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Vec2_obj > __new(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Vec2_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Vec2"); }

		::zpp_nape::geom::ZPP_Vec2 zpp_inner;
		::nape::geom::Vec2 zpp_pool;
		bool zpp_disp;
		virtual Void dispose( );
		Dynamic dispose_dyn();

		virtual ::nape::geom::Vec2 copy( hx::Null< bool >  weak);
		Dynamic copy_dyn();

		virtual ::openfl::_v2::geom::Point toPoint( ::openfl::_v2::geom::Point output);
		Dynamic toPoint_dyn();

		virtual Float get_x( );
		Dynamic get_x_dyn();

		virtual Float set_x( Float x);
		Dynamic set_x_dyn();

		virtual Float get_y( );
		Dynamic get_y_dyn();

		virtual Float set_y( Float y);
		Dynamic set_y_dyn();

		virtual Float get_length( );
		Dynamic get_length_dyn();

		virtual Float set_length( Float length);
		Dynamic set_length_dyn();

		virtual Float lsq( );
		Dynamic lsq_dyn();

		virtual ::nape::geom::Vec2 set( ::nape::geom::Vec2 vector);
		Dynamic set_dyn();

		virtual ::nape::geom::Vec2 setxy( Float x,Float y);
		Dynamic setxy_dyn();

		virtual Float get_angle( );
		Dynamic get_angle_dyn();

		virtual Float set_angle( Float angle);
		Dynamic set_angle_dyn();

		virtual ::nape::geom::Vec2 rotate( Float angle);
		Dynamic rotate_dyn();

		virtual ::nape::geom::Vec2 reflect( ::nape::geom::Vec2 vec,hx::Null< bool >  weak);
		Dynamic reflect_dyn();

		virtual ::nape::geom::Vec2 normalise( );
		Dynamic normalise_dyn();

		virtual ::nape::geom::Vec2 unit( hx::Null< bool >  weak);
		Dynamic unit_dyn();

		virtual ::nape::geom::Vec2 add( ::nape::geom::Vec2 vector,hx::Null< bool >  weak);
		Dynamic add_dyn();

		virtual ::nape::geom::Vec2 addMul( ::nape::geom::Vec2 vector,Float scalar,hx::Null< bool >  weak);
		Dynamic addMul_dyn();

		virtual ::nape::geom::Vec2 sub( ::nape::geom::Vec2 vector,hx::Null< bool >  weak);
		Dynamic sub_dyn();

		virtual ::nape::geom::Vec2 mul( Float scalar,hx::Null< bool >  weak);
		Dynamic mul_dyn();

		virtual ::nape::geom::Vec2 addeq( ::nape::geom::Vec2 vector);
		Dynamic addeq_dyn();

		virtual ::nape::geom::Vec2 subeq( ::nape::geom::Vec2 vector);
		Dynamic subeq_dyn();

		virtual ::nape::geom::Vec2 muleq( Float scalar);
		Dynamic muleq_dyn();

		virtual Float dot( ::nape::geom::Vec2 vector);
		Dynamic dot_dyn();

		virtual Float cross( ::nape::geom::Vec2 vector);
		Dynamic cross_dyn();

		virtual ::nape::geom::Vec2 perp( hx::Null< bool >  weak);
		Dynamic perp_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::geom::Vec2 weak( hx::Null< Float >  x,hx::Null< Float >  y);
		static Dynamic weak_dyn();

		static ::nape::geom::Vec2 get( hx::Null< Float >  x,hx::Null< Float >  y,hx::Null< bool >  weak);
		static Dynamic get_dyn();

		static ::nape::geom::Vec2 fromPoint( ::openfl::_v2::geom::Point point,hx::Null< bool >  weak);
		static Dynamic fromPoint_dyn();

		static ::nape::geom::Vec2 fromPolar( Float length,Float angle,hx::Null< bool >  weak);
		static Dynamic fromPolar_dyn();

		static Float dsq( ::nape::geom::Vec2 a,::nape::geom::Vec2 b);
		static Dynamic dsq_dyn();

		static Float distance( ::nape::geom::Vec2 a,::nape::geom::Vec2 b);
		static Dynamic distance_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_Vec2 */ 
