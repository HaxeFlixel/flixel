#ifndef INCLUDED_flixel_graphics_frames_FlxClippedFrames
#define INCLUDED_flixel_graphics_frames_FlxClippedFrames

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFramesCollection.h>
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxClippedFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxClippedFrames_obj : public ::flixel::graphics::frames::FlxFramesCollection_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFramesCollection_obj super;
		typedef FlxClippedFrames_obj OBJ_;
		FlxClippedFrames_obj();
		Void __construct(::flixel::graphics::frames::FlxFramesCollection original,::flixel::math::FlxRect clipRect);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxClippedFrames_obj > __new(::flixel::graphics::frames::FlxFramesCollection original,::flixel::math::FlxRect clipRect);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxClippedFrames_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxClippedFrames"); }

		::flixel::math::FlxRect clipRect;
		::flixel::graphics::frames::FlxFramesCollection original;
		virtual Void clipFrames( );
		Dynamic clipFrames_dyn();

		virtual bool equals( ::flixel::graphics::frames::FlxFramesCollection original,::flixel::math::FlxRect clipRect);
		Dynamic equals_dyn();

		virtual Void destroy( );

		static ::flixel::graphics::frames::FlxClippedFrames clip( ::flixel::graphics::frames::FlxFramesCollection frames,::flixel::math::FlxRect clipRect);
		static Dynamic clip_dyn();

		static ::flixel::graphics::frames::FlxClippedFrames findFrame( ::flixel::graphics::frames::FlxFramesCollection frames,::flixel::math::FlxRect clipRect);
		static Dynamic findFrame_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxClippedFrames */ 
