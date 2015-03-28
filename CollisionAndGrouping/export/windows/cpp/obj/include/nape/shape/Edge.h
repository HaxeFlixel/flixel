#ifndef INCLUDED_nape_shape_Edge
#define INCLUDED_nape_shape_Edge

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,shape,Edge)
HX_DECLARE_CLASS2(nape,shape,Polygon)
HX_DECLARE_CLASS2(nape,shape,Shape)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Edge)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  Edge_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Edge_obj OBJ_;
		Edge_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Edge_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Edge_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Edge"); }

		::zpp_nape::shape::ZPP_Edge zpp_inner;
		virtual ::nape::shape::Polygon get_polygon( );
		Dynamic get_polygon_dyn();

		virtual ::nape::geom::Vec2 get_localNormal( );
		Dynamic get_localNormal_dyn();

		virtual ::nape::geom::Vec2 get_worldNormal( );
		Dynamic get_worldNormal_dyn();

		virtual Float get_length( );
		Dynamic get_length_dyn();

		virtual Float get_localProjection( );
		Dynamic get_localProjection_dyn();

		virtual Float get_worldProjection( );
		Dynamic get_worldProjection_dyn();

		virtual ::nape::geom::Vec2 get_localVertex1( );
		Dynamic get_localVertex1_dyn();

		virtual ::nape::geom::Vec2 get_localVertex2( );
		Dynamic get_localVertex2_dyn();

		virtual ::nape::geom::Vec2 get_worldVertex1( );
		Dynamic get_worldVertex1_dyn();

		virtual ::nape::geom::Vec2 get_worldVertex2( );
		Dynamic get_worldVertex2_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_Edge */ 
