#ifndef INCLUDED_nape_geom_Mat23
#define INCLUDED_nape_geom_Mat23

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,Mat23)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Mat23)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Mat23_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Mat23_obj OBJ_;
		Mat23_obj();
		Void __construct(hx::Null< Float >  __o_a,hx::Null< Float >  __o_b,hx::Null< Float >  __o_c,hx::Null< Float >  __o_d,hx::Null< Float >  __o_tx,hx::Null< Float >  __o_ty);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Mat23_obj > __new(hx::Null< Float >  __o_a,hx::Null< Float >  __o_b,hx::Null< Float >  __o_c,hx::Null< Float >  __o_d,hx::Null< Float >  __o_tx,hx::Null< Float >  __o_ty);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Mat23_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Mat23"); }

		::zpp_nape::geom::ZPP_Mat23 zpp_inner;
		virtual Float get_a( );
		Dynamic get_a_dyn();

		virtual Float set_a( Float a);
		Dynamic set_a_dyn();

		virtual Float get_b( );
		Dynamic get_b_dyn();

		virtual Float set_b( Float b);
		Dynamic set_b_dyn();

		virtual Float get_c( );
		Dynamic get_c_dyn();

		virtual Float set_c( Float c);
		Dynamic set_c_dyn();

		virtual Float get_d( );
		Dynamic get_d_dyn();

		virtual Float set_d( Float d);
		Dynamic set_d_dyn();

		virtual Float get_tx( );
		Dynamic get_tx_dyn();

		virtual Float set_tx( Float tx);
		Dynamic set_tx_dyn();

		virtual Float get_ty( );
		Dynamic get_ty_dyn();

		virtual Float set_ty( Float ty);
		Dynamic set_ty_dyn();

		virtual ::nape::geom::Mat23 copy( );
		Dynamic copy_dyn();

		virtual ::nape::geom::Mat23 set( ::nape::geom::Mat23 matrix);
		Dynamic set_dyn();

		virtual ::nape::geom::Mat23 setAs( hx::Null< Float >  a,hx::Null< Float >  b,hx::Null< Float >  c,hx::Null< Float >  d,hx::Null< Float >  tx,hx::Null< Float >  ty);
		Dynamic setAs_dyn();

		virtual ::nape::geom::Mat23 reset( );
		Dynamic reset_dyn();

		virtual ::openfl::_v2::geom::Matrix toMatrix( ::openfl::_v2::geom::Matrix output);
		Dynamic toMatrix_dyn();

		virtual Float get_determinant( );
		Dynamic get_determinant_dyn();

		virtual bool singular( );
		Dynamic singular_dyn();

		virtual ::nape::geom::Mat23 inverse( );
		Dynamic inverse_dyn();

		virtual ::nape::geom::Mat23 transpose( );
		Dynamic transpose_dyn();

		virtual ::nape::geom::Mat23 concat( ::nape::geom::Mat23 matrix);
		Dynamic concat_dyn();

		virtual ::nape::geom::Vec2 transform( ::nape::geom::Vec2 point,hx::Null< bool >  noTranslation,hx::Null< bool >  weak);
		Dynamic transform_dyn();

		virtual ::nape::geom::Vec2 inverseTransform( ::nape::geom::Vec2 point,hx::Null< bool >  noTranslation,hx::Null< bool >  weak);
		Dynamic inverseTransform_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual bool equiorthogonal( );
		Dynamic equiorthogonal_dyn();

		virtual bool orthogonal( );
		Dynamic orthogonal_dyn();

		virtual ::nape::geom::Mat23 equiorthogonalise( );
		Dynamic equiorthogonalise_dyn();

		virtual ::nape::geom::Mat23 orthogonalise( );
		Dynamic orthogonalise_dyn();

		static ::nape::geom::Mat23 fromMatrix( ::openfl::_v2::geom::Matrix matrix);
		static Dynamic fromMatrix_dyn();

		static ::nape::geom::Mat23 rotation( Float angle);
		static Dynamic rotation_dyn();

		static ::nape::geom::Mat23 translation( Float tx,Float ty);
		static Dynamic translation_dyn();

		static ::nape::geom::Mat23 scale( Float sx,Float sy);
		static Dynamic scale_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_Mat23 */ 
