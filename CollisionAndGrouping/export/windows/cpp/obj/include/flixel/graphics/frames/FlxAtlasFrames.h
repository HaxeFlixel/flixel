#ifndef INCLUDED_flixel_graphics_frames_FlxAtlasFrames
#define INCLUDED_flixel_graphics_frames_FlxAtlasFrames

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFramesCollection.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxAtlasFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxAtlasFrames_obj : public ::flixel::graphics::frames::FlxFramesCollection_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFramesCollection_obj super;
		typedef FlxAtlasFrames_obj OBJ_;
		FlxAtlasFrames_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxAtlasFrames_obj > __new(::flixel::graphics::FlxGraphic parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxAtlasFrames_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxAtlasFrames"); }

		static ::flixel::graphics::frames::FlxAtlasFrames fromTexturePackerJson( Dynamic Source,::String Description);
		static Dynamic fromTexturePackerJson_dyn();

		static Void texturePackerHelper( ::String FrameName,Dynamic FrameData,::flixel::graphics::frames::FlxAtlasFrames Frames);
		static Dynamic texturePackerHelper_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames fromLibGdx( Dynamic Source,::String Description);
		static Dynamic fromLibGdx_dyn();

		static Array< int > getDimensions( ::String line,Array< int > size);
		static Dynamic getDimensions_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames fromSparrow( Dynamic Source,::String Description);
		static Dynamic fromSparrow_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames fromTexturePackerXml( Dynamic Source,::String Description);
		static Dynamic fromTexturePackerXml_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames fromSpriteSheetPacker( Dynamic Source,::String Description);
		static Dynamic fromSpriteSheetPacker_dyn();

		static ::flixel::graphics::frames::FlxAtlasFrames findFrame( ::flixel::graphics::FlxGraphic graphic);
		static Dynamic findFrame_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxAtlasFrames */ 
