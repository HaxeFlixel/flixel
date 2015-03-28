#ifndef INCLUDED_openfl_geom_Matrix3D
#define INCLUDED_openfl_geom_Matrix3D

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,geom,Matrix3D)
HX_DECLARE_CLASS2(openfl,geom,Orientation3D)
HX_DECLARE_CLASS2(openfl,geom,Vector3D)
namespace openfl{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Matrix3D_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Matrix3D_obj OBJ_;
		Matrix3D_obj();
		Void __construct(Array< Float > v);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Matrix3D_obj > __new(Array< Float > v);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Matrix3D_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Matrix3D"); }

		Float determinant;
		Array< Float > rawData;
		virtual Void append( ::openfl::geom::Matrix3D lhs);
		Dynamic append_dyn();

		virtual Void appendRotation( Float degrees,::openfl::geom::Vector3D axis,::openfl::geom::Vector3D pivotPoint);
		Dynamic appendRotation_dyn();

		virtual Void appendScale( Float xScale,Float yScale,Float zScale);
		Dynamic appendScale_dyn();

		virtual Void appendTranslation( Float x,Float y,Float z);
		Dynamic appendTranslation_dyn();

		virtual ::openfl::geom::Matrix3D clone( );
		Dynamic clone_dyn();

		virtual Void copyColumnFrom( int column,::openfl::geom::Vector3D vector3D);
		Dynamic copyColumnFrom_dyn();

		virtual Void copyColumnTo( int column,::openfl::geom::Vector3D vector3D);
		Dynamic copyColumnTo_dyn();

		virtual Void copyFrom( ::openfl::geom::Matrix3D other);
		Dynamic copyFrom_dyn();

		virtual Void copyRawDataFrom( Array< Float > vector,hx::Null< int >  index,hx::Null< bool >  transpose);
		Dynamic copyRawDataFrom_dyn();

		virtual Void copyRawDataTo( Array< Float > vector,hx::Null< int >  index,hx::Null< bool >  transpose);
		Dynamic copyRawDataTo_dyn();

		virtual Void copyRowFrom( int row,::openfl::geom::Vector3D vector3D);
		Dynamic copyRowFrom_dyn();

		virtual Void copyRowTo( int row,::openfl::geom::Vector3D vector3D);
		Dynamic copyRowTo_dyn();

		virtual Void copyToMatrix3D( ::openfl::geom::Matrix3D other);
		Dynamic copyToMatrix3D_dyn();

		virtual Array< ::Dynamic > decompose( ::openfl::geom::Orientation3D orientationStyle);
		Dynamic decompose_dyn();

		virtual ::openfl::geom::Vector3D deltaTransformVector( ::openfl::geom::Vector3D v);
		Dynamic deltaTransformVector_dyn();

		virtual Void identity( );
		Dynamic identity_dyn();

		virtual Void interpolateTo( ::openfl::geom::Matrix3D toMat,Float percent);
		Dynamic interpolateTo_dyn();

		virtual bool invert( );
		Dynamic invert_dyn();

		virtual Void pointAt( ::openfl::geom::Vector3D pos,::openfl::geom::Vector3D at,::openfl::geom::Vector3D up);
		Dynamic pointAt_dyn();

		virtual Void prepend( ::openfl::geom::Matrix3D rhs);
		Dynamic prepend_dyn();

		virtual Void prependRotation( Float degrees,::openfl::geom::Vector3D axis,::openfl::geom::Vector3D pivotPoint);
		Dynamic prependRotation_dyn();

		virtual Void prependScale( Float xScale,Float yScale,Float zScale);
		Dynamic prependScale_dyn();

		virtual Void prependTranslation( Float x,Float y,Float z);
		Dynamic prependTranslation_dyn();

		virtual bool recompose( Array< ::Dynamic > components,::openfl::geom::Orientation3D orientationStyle);
		Dynamic recompose_dyn();

		virtual ::openfl::geom::Vector3D transformVector( ::openfl::geom::Vector3D v);
		Dynamic transformVector_dyn();

		virtual Void transformVectors( Array< Float > vin,Array< Float > vout);
		Dynamic transformVectors_dyn();

		virtual Void transpose( );
		Dynamic transpose_dyn();

		virtual Float get_determinant( );
		Dynamic get_determinant_dyn();

		virtual ::openfl::geom::Vector3D get_position( );
		Dynamic get_position_dyn();

		virtual ::openfl::geom::Vector3D set_position( ::openfl::geom::Vector3D val);
		Dynamic set_position_dyn();

		static ::openfl::geom::Matrix3D create2D( Float x,Float y,hx::Null< Float >  scale,hx::Null< Float >  rotation);
		static Dynamic create2D_dyn();

		static ::openfl::geom::Matrix3D createABCD( Float a,Float b,Float c,Float d,Float tx,Float ty);
		static Dynamic createABCD_dyn();

		static ::openfl::geom::Matrix3D createOrtho( Float x0,Float x1,Float y0,Float y1,Float zNear,Float zFar);
		static Dynamic createOrtho_dyn();

		static ::openfl::geom::Matrix3D interpolate( ::openfl::geom::Matrix3D thisMat,::openfl::geom::Matrix3D toMat,Float percent);
		static Dynamic interpolate_dyn();

		static ::openfl::geom::Matrix3D getAxisRotation( Float x,Float y,Float z,Float degrees);
		static Dynamic getAxisRotation_dyn();

};

} // end namespace openfl
} // end namespace geom

#endif /* INCLUDED_openfl_geom_Matrix3D */ 
