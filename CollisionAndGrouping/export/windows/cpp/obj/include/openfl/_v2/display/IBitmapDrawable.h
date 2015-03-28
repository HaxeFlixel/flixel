#ifndef INCLUDED_openfl__v2_display_IBitmapDrawable
#define INCLUDED_openfl__v2_display_IBitmapDrawable

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,geom,ColorTransform)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  IBitmapDrawable_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IBitmapDrawable_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void __drawToSurface( Dynamic surface,::openfl::_v2::geom::Matrix matrix,::openfl::_v2::geom::ColorTransform colorTransform,::String blendMode,::openfl::_v2::geom::Rectangle clipRect,bool smoothing)=0;
		Dynamic __drawToSurface_dyn();
};

#define DELEGATE_openfl__v2_display_IBitmapDrawable \
virtual Void __drawToSurface( Dynamic surface,::openfl::_v2::geom::Matrix matrix,::openfl::_v2::geom::ColorTransform colorTransform,::String blendMode,::openfl::_v2::geom::Rectangle clipRect,bool smoothing) { return mDelegate->__drawToSurface(surface,matrix,colorTransform,blendMode,clipRect,smoothing);}  \
virtual Dynamic __drawToSurface_dyn() { return mDelegate->__drawToSurface_dyn();}  \


template<typename IMPL>
class IBitmapDrawable_delegate_ : public IBitmapDrawable_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IBitmapDrawable_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_openfl__v2_display_IBitmapDrawable
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_IBitmapDrawable */ 
