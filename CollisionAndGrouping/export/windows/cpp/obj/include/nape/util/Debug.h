#ifndef INCLUDED_nape_util_Debug
#define INCLUDED_nape_util_Debug

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
HX_DECLARE_CLASS2(nape,util,Debug)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,Shape)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS2(zpp_nape,util,ZPP_Debug)
namespace nape{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  Debug_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Debug_obj OBJ_;
		Debug_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Debug_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Debug_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Debug"); }

		::zpp_nape::util::ZPP_Debug zpp_inner;
		bool drawCollisionArbiters;
		bool drawFluidArbiters;
		bool drawSensorArbiters;
		bool drawBodies;
		bool drawBodyDetail;
		bool drawShapeDetail;
		bool drawShapeAngleIndicators;
		bool drawConstraints;
		virtual int get_bgColour( );
		Dynamic get_bgColour_dyn();

		virtual int set_bgColour( int bgColour);
		Dynamic set_bgColour_dyn();

		Dynamic colour;
		Dynamic &colour_dyn() { return colour;}
		virtual ::openfl::_v2::display::DisplayObject get_display( );
		Dynamic get_display_dyn();

		bool cullingEnabled;
		virtual ::nape::geom::Mat23 get_transform( );
		Dynamic get_transform_dyn();

		virtual ::nape::geom::Mat23 set_transform( ::nape::geom::Mat23 transform);
		Dynamic set_transform_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void flush( );
		Dynamic flush_dyn();

		virtual Void draw( Dynamic object);
		Dynamic draw_dyn();

		virtual Void drawLine( ::nape::geom::Vec2 start,::nape::geom::Vec2 end,int colour);
		Dynamic drawLine_dyn();

		virtual Void drawCurve( ::nape::geom::Vec2 start,::nape::geom::Vec2 control,::nape::geom::Vec2 end,int colour);
		Dynamic drawCurve_dyn();

		virtual Void drawCircle( ::nape::geom::Vec2 position,Float radius,int colour);
		Dynamic drawCircle_dyn();

		virtual Void drawAABB( ::nape::geom::AABB aabb,int colour);
		Dynamic drawAABB_dyn();

		virtual Void drawFilledTriangle( ::nape::geom::Vec2 p0,::nape::geom::Vec2 p1,::nape::geom::Vec2 p2,int colour);
		Dynamic drawFilledTriangle_dyn();

		virtual Void drawFilledCircle( ::nape::geom::Vec2 position,Float radius,int colour);
		Dynamic drawFilledCircle_dyn();

		virtual Void drawPolygon( Dynamic polygon,int colour);
		Dynamic drawPolygon_dyn();

		virtual Void drawFilledPolygon( Dynamic polygon,int colour);
		Dynamic drawFilledPolygon_dyn();

		virtual Void drawSpring( ::nape::geom::Vec2 start,::nape::geom::Vec2 end,int colour,hx::Null< int >  coils,hx::Null< Float >  radius);
		Dynamic drawSpring_dyn();

		static ::String version( );
		static Dynamic version_dyn();

		static Void clearObjectPools( );
		static Dynamic clearObjectPools_dyn();

		static ::openfl::_v2::display::Shape createGraphic( ::nape::phys::Body body);
		static Dynamic createGraphic_dyn();

};

} // end namespace nape
} // end namespace util

#endif /* INCLUDED_nape_util_Debug */ 
