#ifndef INCLUDED_nape_util_ShapeDebug
#define INCLUDED_nape_util_ShapeDebug

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <nape/util/Debug.h>
HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS2(nape,util,ShapeDebug)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Debug)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_ShapeDebug)
namespace nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  ShapeDebug_obj : public ::nape::util::Debug_obj{
	public:
		typedef ::nape::util::Debug_obj super;
		typedef ShapeDebug_obj OBJ_;
		ShapeDebug_obj();
		Void __construct(int width,int height,hx::Null< int >  __o_bgColour);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ShapeDebug_obj > __new(int width,int height,hx::Null< int >  __o_bgColour);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ShapeDebug_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("ShapeDebug"); }

		::zpp_nape::util::ZPP_ShapeDebug zpp_inner_zn;
		Float thickness;
		virtual Void clear( );

		virtual Void drawLine( ::nape::geom::Vec2 start,::nape::geom::Vec2 end,int colour);

		virtual Void drawCurve( ::nape::geom::Vec2 start,::nape::geom::Vec2 control,::nape::geom::Vec2 end,int colour);

		virtual Void drawCircle( ::nape::geom::Vec2 position,Float radius,int colour);

		virtual Void drawAABB( ::nape::geom::AABB aabb,int colour);

		virtual Void drawFilledTriangle( ::nape::geom::Vec2 p0,::nape::geom::Vec2 p1,::nape::geom::Vec2 p2,int colour);

		virtual Void drawFilledCircle( ::nape::geom::Vec2 position,Float radius,int colour);

		virtual Void drawPolygon( Dynamic polygon,int colour);

		virtual Void drawFilledPolygon( Dynamic polygon,int colour);

		virtual Void draw( Dynamic object);

		virtual Void drawSpring( ::nape::geom::Vec2 start,::nape::geom::Vec2 end,int colour,hx::Null< int >  coils,hx::Null< Float >  radius);

};

} // end namespace nape
} // end namespace util

#endif /* INCLUDED_nape_util_ShapeDebug */ 
