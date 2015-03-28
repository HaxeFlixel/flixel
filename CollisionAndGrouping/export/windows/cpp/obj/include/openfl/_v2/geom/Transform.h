#ifndef INCLUDED_openfl__v2_geom_Transform
#define INCLUDED_openfl__v2_geom_Transform

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,geom,ColorTransform)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
HX_DECLARE_CLASS3(openfl,_v2,geom,Transform)
HX_DECLARE_CLASS2(openfl,geom,Matrix3D)
namespace openfl{
namespace _v2{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Transform_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Transform_obj OBJ_;
		Transform_obj();
		Void __construct(::openfl::_v2::display::DisplayObject parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Transform_obj > __new(::openfl::_v2::display::DisplayObject parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Transform_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Transform"); }

		::openfl::_v2::geom::ColorTransform concatenatedColorTransform;
		::openfl::_v2::geom::Matrix concatenatedMatrix;
		::openfl::_v2::geom::Rectangle pixelBounds;
		bool __hasMatrix;
		bool __hasMatrix3D;
		::openfl::_v2::display::DisplayObject __parent;
		virtual ::openfl::_v2::geom::ColorTransform get_colorTransform( );
		Dynamic get_colorTransform_dyn();

		virtual ::openfl::_v2::geom::ColorTransform set_colorTransform( ::openfl::_v2::geom::ColorTransform value);
		Dynamic set_colorTransform_dyn();

		virtual ::openfl::_v2::geom::ColorTransform get_concatenatedColorTransform( );
		Dynamic get_concatenatedColorTransform_dyn();

		virtual ::openfl::_v2::geom::Matrix get_concatenatedMatrix( );
		Dynamic get_concatenatedMatrix_dyn();

		virtual ::openfl::_v2::geom::Matrix get_matrix( );
		Dynamic get_matrix_dyn();

		virtual ::openfl::_v2::geom::Matrix set_matrix( ::openfl::_v2::geom::Matrix value);
		Dynamic set_matrix_dyn();

		virtual ::openfl::geom::Matrix3D get_matrix3D( );
		Dynamic get_matrix3D_dyn();

		virtual ::openfl::geom::Matrix3D set_matrix3D( ::openfl::geom::Matrix3D value);
		Dynamic set_matrix3D_dyn();

		virtual ::openfl::_v2::geom::Rectangle get_pixelBounds( );
		Dynamic get_pixelBounds_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace geom

#endif /* INCLUDED_openfl__v2_geom_Transform */ 
