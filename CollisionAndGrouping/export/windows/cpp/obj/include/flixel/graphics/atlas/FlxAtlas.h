#ifndef INCLUDED_flixel_graphics_atlas_FlxAtlas
#define INCLUDED_flixel_graphics_atlas_FlxAtlas

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS3(flixel,graphics,atlas,FlxAtlas)
HX_DECLARE_CLASS3(flixel,graphics,atlas,FlxNode)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxAtlasFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxTileFrames)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace graphics{
namespace atlas{


class HXCPP_CLASS_ATTRIBUTES  FlxAtlas_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxAtlas_obj OBJ_;
		FlxAtlas_obj();
		Void __construct(::String name,hx::Null< bool >  __o_powerOfTwo,hx::Null< int >  __o_border,hx::Null< bool >  __o_rotate,::flixel::math::FlxPoint minSize,::flixel::math::FlxPoint maxSize);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxAtlas_obj > __new(::String name,hx::Null< bool >  __o_powerOfTwo,hx::Null< int >  __o_border,hx::Null< bool >  __o_rotate,::flixel::math::FlxPoint minSize,::flixel::math::FlxPoint maxSize);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxAtlas_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxAtlas_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxAtlas"); }

		::flixel::graphics::atlas::FlxNode root;
		::String name;
		::haxe::ds::StringMap nodes;
		int border;
		int width;
		int height;
		int minWidth;
		int minHeight;
		int maxWidth;
		int maxHeight;
		bool allowRotation;
		bool powerOfTwo;
		::openfl::_v2::display::BitmapData _bitmapData;
		Dynamic _tempStorage;
		virtual Void initRoot( );
		Dynamic initRoot_dyn();

		virtual ::flixel::graphics::atlas::FlxNode addNode( Dynamic Graphic,::String Key);
		Dynamic addNode_dyn();

		virtual Void wrapRoot( );
		Dynamic wrapRoot_dyn();

		virtual ::flixel::graphics::atlas::FlxNode tryInsert( ::openfl::_v2::display::BitmapData data,::String key);
		Dynamic tryInsert_dyn();

		virtual bool needToDivideHorizontally( ::flixel::graphics::atlas::FlxNode nodeToDivide,int insertWidth,int insertHeight);
		Dynamic needToDivideHorizontally_dyn();

		virtual ::flixel::graphics::atlas::FlxNode divideNode( ::flixel::graphics::atlas::FlxNode nodeToDivide,int insertWidth,int insertHeight,bool divideHorizontally,::openfl::_v2::display::BitmapData firstGrandChildData,::String firstGrandChildKey,hx::Null< bool >  firstGrandChildRotated);
		Dynamic divideNode_dyn();

		virtual ::flixel::graphics::atlas::FlxNode insertFirstNodeInRoot( ::openfl::_v2::display::BitmapData data,::String key);
		Dynamic insertFirstNodeInRoot_dyn();

		virtual ::flixel::graphics::atlas::FlxNode expand( ::openfl::_v2::display::BitmapData data,::String key);
		Dynamic expand_dyn();

		virtual Void expandRoot( Float newWidth,Float newHeight,bool divideHorizontally,hx::Null< bool >  decideHowToDivide);
		Dynamic expandRoot_dyn();

		virtual Void expandBitmapData( );
		Dynamic expandBitmapData_dyn();

		virtual int getNextPowerOf2( Float number);
		Dynamic getNextPowerOf2_dyn();

		virtual ::flixel::graphics::frames::FlxTileFrames addNodeWithSpacings( Dynamic Graphic,::String Key,::flixel::math::FlxPoint tileSize,::flixel::math::FlxPoint tileSpacing,::flixel::math::FlxRect region);
		Dynamic addNodeWithSpacings_dyn();

		virtual ::flixel::graphics::frames::FlxAtlasFrames getAtlasFrames( );
		Dynamic getAtlasFrames_dyn();

		virtual Void addNodeToAtlasFrames( ::flixel::graphics::atlas::FlxNode node);
		Dynamic addNodeToAtlasFrames_dyn();

		virtual bool hasNodeWithName( ::String nodeName);
		Dynamic hasNodeWithName_dyn();

		virtual ::flixel::graphics::atlas::FlxNode getNode( ::String key);
		Dynamic getNode_dyn();

		virtual ::flixel::graphics::atlas::FlxAtlas addNodes( Array< ::Dynamic > bitmaps,Array< ::String > keys);
		Dynamic addNodes_dyn();

		virtual Void addFromAtlasObjects( Dynamic objects);
		Dynamic addFromAtlasObjects_dyn();

		virtual int bitmapSorter( Dynamic obj1,Dynamic obj2);
		Dynamic bitmapSorter_dyn();

		virtual ::flixel::graphics::atlas::FlxAtlas createQueue( );
		Dynamic createQueue_dyn();

		virtual ::flixel::graphics::atlas::FlxAtlas addToQueue( ::openfl::_v2::display::BitmapData data,::String key);
		Dynamic addToQueue_dyn();

		virtual ::flixel::graphics::atlas::FlxAtlas generateFromQueue( );
		Dynamic generateFromQueue_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual ::String getLibGdxData( );
		Dynamic getLibGdxData_dyn();

		virtual Void deleteSubtree( ::flixel::graphics::atlas::FlxNode node);
		Dynamic deleteSubtree_dyn();

		virtual ::flixel::graphics::atlas::FlxNode findNodeToInsert( int insertWidth,int insertHeight);
		Dynamic findNodeToInsert_dyn();

		virtual ::openfl::_v2::display::BitmapData get_bitmapData( );
		Dynamic get_bitmapData_dyn();

		virtual ::openfl::_v2::display::BitmapData set_bitmapData( ::openfl::_v2::display::BitmapData value);
		Dynamic set_bitmapData_dyn();

		virtual int set_minWidth( int value);
		Dynamic set_minWidth_dyn();

		virtual int set_minHeight( int value);
		Dynamic set_minHeight_dyn();

		virtual int get_width( );
		Dynamic get_width_dyn();

		virtual int set_width( int value);
		Dynamic set_width_dyn();

		virtual int get_height( );
		Dynamic get_height_dyn();

		virtual int set_height( int value);
		Dynamic set_height_dyn();

		virtual int set_maxWidth( int value);
		Dynamic set_maxWidth_dyn();

		virtual int set_maxHeight( int value);
		Dynamic set_maxHeight_dyn();

		virtual bool set_powerOfTwo( bool value);
		Dynamic set_powerOfTwo_dyn();

		static ::flixel::math::FlxPoint defaultMinSize;
		static ::flixel::math::FlxPoint defaultMaxSize;
};

} // end namespace flixel
} // end namespace graphics
} // end namespace atlas

#endif /* INCLUDED_flixel_graphics_atlas_FlxAtlas */ 
