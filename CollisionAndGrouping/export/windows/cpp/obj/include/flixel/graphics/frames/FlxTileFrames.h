#ifndef INCLUDED_flixel_graphics_frames_FlxTileFrames
#define INCLUDED_flixel_graphics_frames_FlxTileFrames

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/frames/FlxFramesCollection.h>
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxAtlasFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxTileFrames)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxTileFrames_obj : public ::flixel::graphics::frames::FlxFramesCollection_obj{
	public:
		typedef ::flixel::graphics::frames::FlxFramesCollection_obj super;
		typedef FlxTileFrames_obj OBJ_;
		FlxTileFrames_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTileFrames_obj > __new(::flixel::graphics::FlxGraphic parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTileFrames_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTileFrames"); }

		::flixel::graphics::frames::FlxFrame atlasFrame;
		::flixel::math::FlxRect region;
		::flixel::math::FlxPoint tileSize;
		::flixel::math::FlxPoint tileSpacing;
		int numRows;
		int numCols;
		virtual ::flixel::graphics::frames::FlxFrame getByTilePosition( int column,int row);
		Dynamic getByTilePosition_dyn();

		virtual bool equals( ::flixel::math::FlxPoint tileSize,::flixel::math::FlxRect region,::flixel::graphics::frames::FlxFrame atlasFrame,::flixel::math::FlxPoint tileSpacing);
		Dynamic equals_dyn();

		virtual Void destroy( );

		static ::flixel::graphics::frames::FlxTileFrames fromBitmapWithSpacings( Dynamic source,::flixel::math::FlxPoint tileSize,::flixel::math::FlxPoint tileSpacing,::flixel::math::FlxRect region);
		static Dynamic fromBitmapWithSpacings_dyn();

		static ::flixel::graphics::frames::FlxTileFrames fromFrame( ::flixel::graphics::frames::FlxFrame frame,::flixel::math::FlxPoint tileSize,::flixel::math::FlxPoint tileSpacing);
		static Dynamic fromFrame_dyn();

		static ::flixel::graphics::frames::FlxTileFrames fromFrames( Array< ::Dynamic > Frames);
		static Dynamic fromFrames_dyn();

		static ::flixel::graphics::frames::FlxTileFrames fromAtlasByPrefix( ::flixel::graphics::frames::FlxAtlasFrames Frames,::String Prefix);
		static Dynamic fromAtlasByPrefix_dyn();

		static ::flixel::graphics::frames::FlxTileFrames fromGraphic( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxPoint tileSize,::flixel::math::FlxRect region,::flixel::math::FlxPoint tileSpacing);
		static Dynamic fromGraphic_dyn();

		static ::flixel::graphics::frames::FlxTileFrames fromRectangle( Dynamic source,::flixel::math::FlxPoint tileSize,::flixel::math::FlxRect region,::flixel::math::FlxPoint tileSpacing);
		static Dynamic fromRectangle_dyn();

		static ::flixel::graphics::frames::FlxTileFrames findFrame( ::flixel::graphics::FlxGraphic graphic,::flixel::math::FlxPoint tileSize,::flixel::math::FlxRect region,::flixel::graphics::frames::FlxFrame atlasFrame,::flixel::math::FlxPoint tileSpacing);
		static Dynamic findFrame_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxTileFrames */ 
