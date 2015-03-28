#ifndef INCLUDED_nape_geom_AABB
#define INCLUDED_nape_geom_AABB

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_AABB)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  AABB_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef AABB_obj OBJ_;
		AABB_obj();
		Void __construct(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y,hx::Null< Float >  __o_width,hx::Null< Float >  __o_height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< AABB_obj > __new(hx::Null< Float >  __o_x,hx::Null< Float >  __o_y,hx::Null< Float >  __o_width,hx::Null< Float >  __o_height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~AABB_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("AABB"); }

		::zpp_nape::geom::ZPP_AABB zpp_inner;
		virtual ::nape::geom::AABB copy( );
		Dynamic copy_dyn();

		virtual ::openfl::_v2::geom::Rectangle toRect( );
		Dynamic toRect_dyn();

		virtual ::nape::geom::Vec2 get_min( );
		Dynamic get_min_dyn();

		virtual ::nape::geom::Vec2 set_min( ::nape::geom::Vec2 min);
		Dynamic set_min_dyn();

		virtual ::nape::geom::Vec2 get_max( );
		Dynamic get_max_dyn();

		virtual ::nape::geom::Vec2 set_max( ::nape::geom::Vec2 max);
		Dynamic set_max_dyn();

		virtual Float get_x( );
		Dynamic get_x_dyn();

		virtual Float set_x( Float x);
		Dynamic set_x_dyn();

		virtual Float get_y( );
		Dynamic get_y_dyn();

		virtual Float set_y( Float y);
		Dynamic set_y_dyn();

		virtual Float get_width( );
		Dynamic get_width_dyn();

		virtual Float set_width( Float width);
		Dynamic set_width_dyn();

		virtual Float get_height( );
		Dynamic get_height_dyn();

		virtual Float set_height( Float height);
		Dynamic set_height_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::geom::AABB fromRect( ::openfl::_v2::geom::Rectangle rect);
		static Dynamic fromRect_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_AABB */ 
