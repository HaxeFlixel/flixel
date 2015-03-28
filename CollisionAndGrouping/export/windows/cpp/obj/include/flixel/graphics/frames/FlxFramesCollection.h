#ifndef INCLUDED_flixel_graphics_frames_FlxFramesCollection
#define INCLUDED_flixel_graphics_frames_FlxFramesCollection

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxEmptyFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrameCollectionType)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
namespace flixel{
namespace graphics{
namespace frames{


class HXCPP_CLASS_ATTRIBUTES  FlxFramesCollection_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxFramesCollection_obj OBJ_;
		FlxFramesCollection_obj();
		Void __construct(::flixel::graphics::FlxGraphic parent,::flixel::graphics::frames::FlxFrameCollectionType type);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxFramesCollection_obj > __new(::flixel::graphics::FlxGraphic parent,::flixel::graphics::frames::FlxFrameCollectionType type);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxFramesCollection_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxFramesCollection_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxFramesCollection"); }

		Array< ::Dynamic > frames;
		::haxe::ds::StringMap framesHash;
		::flixel::graphics::FlxGraphic parent;
		::flixel::graphics::frames::FlxFrameCollectionType type;
		virtual ::flixel::graphics::frames::FlxFrame getByName( ::String name);
		Dynamic getByName_dyn();

		virtual ::flixel::graphics::frames::FlxFrame getByIndex( int index);
		Dynamic getByIndex_dyn();

		virtual int getIndexByName( ::String name);
		Dynamic getIndexByName_dyn();

		virtual int getFrameIndex( ::flixel::graphics::frames::FlxFrame frame);
		Dynamic getFrameIndex_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual ::flixel::graphics::frames::FlxEmptyFrame addEmptyFrame( ::flixel::math::FlxRect size);
		Dynamic addEmptyFrame_dyn();

		virtual ::flixel::graphics::frames::FlxFrame addSpriteSheetFrame( ::flixel::math::FlxRect region);
		Dynamic addSpriteSheetFrame_dyn();

		virtual ::flixel::graphics::frames::FlxFrame addAtlasFrame( ::flixel::math::FlxRect frame,::flixel::math::FlxPoint sourceSize,::flixel::math::FlxPoint offset,::String name,hx::Null< int >  angle);
		Dynamic addAtlasFrame_dyn();

		virtual Void destroyBitmaps( );
		Dynamic destroyBitmaps_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

		virtual int get_numFrames( );
		Dynamic get_numFrames_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames

#endif /* INCLUDED_flixel_graphics_frames_FlxFramesCollection */ 
