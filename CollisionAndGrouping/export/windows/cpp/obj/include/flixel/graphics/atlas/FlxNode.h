#ifndef INCLUDED_flixel_graphics_atlas_FlxNode
#define INCLUDED_flixel_graphics_atlas_FlxNode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS3(flixel,graphics,atlas,FlxAtlas)
HX_DECLARE_CLASS3(flixel,graphics,atlas,FlxNode)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxImageFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxTileFrames)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace graphics{
namespace atlas{


class HXCPP_CLASS_ATTRIBUTES  FlxNode_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxNode_obj OBJ_;
		FlxNode_obj();
		Void __construct(::flixel::math::FlxRect rect,::flixel::graphics::atlas::FlxAtlas atlas,hx::Null< bool >  __o_filled,::String __o_key,hx::Null< bool >  __o_rotated);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxNode_obj > __new(::flixel::math::FlxRect rect,::flixel::graphics::atlas::FlxAtlas atlas,hx::Null< bool >  __o_filled,::String __o_key,hx::Null< bool >  __o_rotated);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxNode_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxNode_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxNode"); }

		::flixel::graphics::atlas::FlxNode left;
		::flixel::graphics::atlas::FlxNode right;
		::flixel::math::FlxRect rect;
		::String key;
		bool filled;
		::flixel::graphics::atlas::FlxAtlas atlas;
		int x;
		int y;
		bool isEmpty;
		bool rotated;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual bool canPlace( int width,int height);
		Dynamic canPlace_dyn();

		virtual ::flixel::graphics::frames::FlxTileFrames getTileFrames( ::flixel::math::FlxPoint tileSize,::flixel::math::FlxPoint tileSpacing);
		Dynamic getTileFrames_dyn();

		virtual ::flixel::graphics::frames::FlxImageFrame getImageFrame( );
		Dynamic getImageFrame_dyn();

		virtual bool get_isEmpty( );
		Dynamic get_isEmpty_dyn();

		virtual int get_x( );
		Dynamic get_x_dyn();

		virtual int get_y( );
		Dynamic get_y_dyn();

		virtual int get_width( );
		Dynamic get_width_dyn();

		virtual int set_width( int value);
		Dynamic set_width_dyn();

		virtual int get_height( );
		Dynamic get_height_dyn();

		virtual int set_height( int value);
		Dynamic set_height_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace atlas

#endif /* INCLUDED_flixel_graphics_atlas_FlxNode */ 
