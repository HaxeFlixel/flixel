#ifndef INCLUDED_flixel_group_FlxTypedSpriteGroup
#define INCLUDED_flixel_group_FlxTypedSpriteGroup

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxSprite.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroupIterator)
HX_DECLARE_CLASS2(flixel,group,FlxTypedSpriteGroup)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,BlendMode)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace group{


class HXCPP_CLASS_ATTRIBUTES  FlxTypedSpriteGroup_obj : public ::flixel::FlxSprite_obj{
	public:
		typedef ::flixel::FlxSprite_obj super;
		typedef FlxTypedSpriteGroup_obj OBJ_;
		FlxTypedSpriteGroup_obj();
		Void __construct(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< int >  __o_MaxSize);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTypedSpriteGroup_obj > __new(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< int >  __o_MaxSize);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTypedSpriteGroup_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTypedSpriteGroup"); }

		virtual Void transformChildren_openfl__v2_display_BlendMode( Dynamic Function,::openfl::_v2::display::BlendMode Value);
		Dynamic transformChildren_openfl__v2_display_BlendMode_dyn();

		virtual Void transformChildren_Int( Dynamic Function,int Value);
		Dynamic transformChildren_Int_dyn();

		virtual Void transformChildren_Float( Dynamic Function,Float Value);
		Dynamic transformChildren_Float_dyn();

		virtual Void transformChildren_Bool( Dynamic Function,bool Value);
		Dynamic transformChildren_Bool_dyn();

		virtual Void transformChildren_Array_flixel_FlxCamera( Dynamic Function,Array< ::Dynamic > Value);
		Dynamic transformChildren_Array_flixel_FlxCamera_dyn();

		virtual Void multiTransformChildren_Float( Dynamic FunctionArray,Array< Float > ValueArray);
		Dynamic multiTransformChildren_Float_dyn();

		virtual Void transformChildren_flixel_math_FlxPoint( Dynamic Function,::flixel::math::FlxPoint Value);
		Dynamic transformChildren_flixel_math_FlxPoint_dyn();

		::flixel::group::FlxTypedGroup group;
		Dynamic members;
		int length;
		bool _skipTransformChildren;
		bool _isDrawnDebug;
		Array< ::Dynamic > _sprites;
		virtual Void initVars( );

		virtual Void destroy( );

		virtual ::flixel::FlxSprite clone( );

		virtual bool isOnScreen( ::flixel::FlxCamera Camera);

		virtual bool overlapsPoint( ::flixel::math::FlxPoint point,hx::Null< bool >  InScreenSpace,::flixel::FlxCamera Camera);

		virtual bool pixelsOverlapPoint( ::flixel::math::FlxPoint point,hx::Null< int >  Mask,::flixel::FlxCamera Camera);

		virtual Void update( Float elapsed);

		virtual Void draw( );

		virtual Array< ::Dynamic > replaceColor( int _tmp_Color,int _tmp_NewColor,hx::Null< bool >  FetchPositions);

		virtual Dynamic add( Dynamic Sprite);
		Dynamic add_dyn();

		virtual Dynamic recycle( ::Class ObjectClass,Dynamic ObjectFactory,hx::Null< bool >  Force);
		Dynamic recycle_dyn();

		virtual Dynamic remove( Dynamic Object,hx::Null< bool >  Splice);
		Dynamic remove_dyn();

		virtual Dynamic replace( Dynamic OldObject,Dynamic NewObject);
		Dynamic replace_dyn();

		virtual Void sort( Dynamic Function,hx::Null< int >  Order);
		Dynamic sort_dyn();

		virtual Dynamic getFirstAvailable( ::Class ObjectClass,hx::Null< bool >  Force);
		Dynamic getFirstAvailable_dyn();

		virtual int getFirstNull( );
		Dynamic getFirstNull_dyn();

		virtual Dynamic getFirstExisting( );
		Dynamic getFirstExisting_dyn();

		virtual Dynamic getFirstAlive( );
		Dynamic getFirstAlive_dyn();

		virtual Dynamic getFirstDead( );
		Dynamic getFirstDead_dyn();

		virtual int countLiving( );
		Dynamic countLiving_dyn();

		virtual int countDead( );
		Dynamic countDead_dyn();

		virtual Dynamic getRandom( hx::Null< int >  StartIndex,hx::Null< int >  Length);
		Dynamic getRandom_dyn();

		virtual ::flixel::group::FlxTypedGroupIterator iterator( Dynamic filter);
		Dynamic iterator_dyn();

		virtual Void forEach( Dynamic Function,hx::Null< bool >  Recurse);
		Dynamic forEach_dyn();

		virtual Void forEachAlive( Dynamic Function,hx::Null< bool >  Recurse);
		Dynamic forEachAlive_dyn();

		virtual Void forEachDead( Dynamic Function,hx::Null< bool >  Recurse);
		Dynamic forEachDead_dyn();

		virtual Void forEachExists( Dynamic Function,hx::Null< bool >  Recurse);
		Dynamic forEachExists_dyn();

		virtual Void forEachOfType( ::Class ObjectClass,Dynamic Function,hx::Null< bool >  Recurse);
		Dynamic forEachOfType_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void kill( );

		virtual Void revive( );

		virtual Void reset( Float X,Float Y);

		virtual Void setPosition( hx::Null< Float >  X,hx::Null< Float >  Y);

		virtual Array< ::Dynamic > set_cameras( Array< ::Dynamic > Value);

		virtual bool set_exists( bool Value);

		virtual bool set_visible( bool Value);

		virtual bool set_active( bool Value);

		virtual bool set_alive( bool Value);

		virtual Float set_x( Float Value);

		virtual Float set_y( Float Value);

		virtual Float set_angle( Float Value);

		virtual Float set_alpha( Float Value);

		virtual int set_facing( int Value);

		virtual bool set_flipX( bool Value);

		virtual bool set_flipY( bool Value);

		virtual bool set_moves( bool Value);

		virtual bool set_immovable( bool Value);

		virtual bool set_solid( bool Value);

		virtual int set_color( int _tmp_Value);

		virtual ::openfl::_v2::display::BlendMode set_blend( ::openfl::_v2::display::BlendMode Value);

		virtual bool set_pixelPerfectRender( bool Value);

		virtual Float set_width( Float Value);

		virtual Float get_width( );

		virtual Float set_height( Float Value);

		virtual Float get_height( );

		virtual int get_length( );
		Dynamic get_length_dyn();

		virtual int get_maxSize( );
		Dynamic get_maxSize_dyn();

		virtual int set_maxSize( int Size);
		Dynamic set_maxSize_dyn();

		virtual Dynamic get_members( );
		Dynamic get_members_dyn();

		virtual Void xTransform( ::flixel::FlxSprite Sprite,Float X);
		Dynamic xTransform_dyn();

		virtual Void yTransform( ::flixel::FlxSprite Sprite,Float Y);
		Dynamic yTransform_dyn();

		virtual Void angleTransform( ::flixel::FlxSprite Sprite,Float Angle);
		Dynamic angleTransform_dyn();

		virtual Void alphaTransform( ::flixel::FlxSprite Sprite,Float Alpha);
		Dynamic alphaTransform_dyn();

		virtual Void facingTransform( ::flixel::FlxSprite Sprite,int Facing);
		Dynamic facingTransform_dyn();

		virtual Void flipXTransform( ::flixel::FlxSprite Sprite,bool FlipX);
		Dynamic flipXTransform_dyn();

		virtual Void flipYTransform( ::flixel::FlxSprite Sprite,bool FlipY);
		Dynamic flipYTransform_dyn();

		virtual Void movesTransform( ::flixel::FlxSprite Sprite,bool Moves);
		Dynamic movesTransform_dyn();

		virtual Void pixelPerfectTransform( ::flixel::FlxSprite Sprite,bool PixelPerfect);
		Dynamic pixelPerfectTransform_dyn();

		virtual Void gColorTransform( ::flixel::FlxSprite Sprite,int Color);
		Dynamic gColorTransform_dyn();

		virtual Void blendTransform( ::flixel::FlxSprite Sprite,::openfl::_v2::display::BlendMode Blend);
		Dynamic blendTransform_dyn();

		virtual Void immovableTransform( ::flixel::FlxSprite Sprite,bool Immovable);
		Dynamic immovableTransform_dyn();

		virtual Void visibleTransform( ::flixel::FlxSprite Sprite,bool Visible);
		Dynamic visibleTransform_dyn();

		virtual Void activeTransform( ::flixel::FlxSprite Sprite,bool Active);
		Dynamic activeTransform_dyn();

		virtual Void solidTransform( ::flixel::FlxSprite Sprite,bool Solid);
		Dynamic solidTransform_dyn();

		virtual Void aliveTransform( ::flixel::FlxSprite Sprite,bool Alive);
		Dynamic aliveTransform_dyn();

		virtual Void existsTransform( ::flixel::FlxSprite Sprite,bool Exists);
		Dynamic existsTransform_dyn();

		virtual Void camerasTransform( ::flixel::FlxSprite Sprite,Array< ::Dynamic > Cameras);
		Dynamic camerasTransform_dyn();

		virtual Void offsetTransform( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint Offset);
		Dynamic offsetTransform_dyn();

		virtual Void originTransform( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint Origin);
		Dynamic originTransform_dyn();

		virtual Void scaleTransform( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint Scale);
		Dynamic scaleTransform_dyn();

		virtual Void scrollFactorTransform( ::flixel::FlxSprite Sprite,::flixel::math::FlxPoint ScrollFactor);
		Dynamic scrollFactorTransform_dyn();

		virtual Void offsetCallback( ::flixel::math::FlxPoint Offset);
		Dynamic offsetCallback_dyn();

		virtual Void originCallback( ::flixel::math::FlxPoint Origin);
		Dynamic originCallback_dyn();

		virtual Void scaleCallback( ::flixel::math::FlxPoint Scale);
		Dynamic scaleCallback_dyn();

		virtual Void scrollFactorCallback( ::flixel::math::FlxPoint ScrollFactor);
		Dynamic scrollFactorCallback_dyn();

		virtual ::flixel::FlxSprite loadGraphicFromSprite( ::flixel::FlxSprite Sprite);

		virtual ::flixel::FlxSprite loadGraphic( Dynamic Graphic,hx::Null< bool >  Animated,hx::Null< int >  Width,hx::Null< int >  Height,hx::Null< bool >  Unique,::String Key);

		virtual ::flixel::FlxSprite loadRotatedGraphic( Dynamic Graphic,hx::Null< int >  Rotations,hx::Null< int >  Frame,hx::Null< bool >  AntiAliasing,hx::Null< bool >  AutoBuffer,::String Key);

		virtual ::flixel::FlxSprite makeGraphic( int Width,int Height,hx::Null< int >  _tmp_Color,hx::Null< bool >  Unique,::String Key);

		virtual ::openfl::_v2::display::BitmapData set_pixels( ::openfl::_v2::display::BitmapData Value);

		virtual ::flixel::graphics::frames::FlxFrame set_frame( ::flixel::graphics::frames::FlxFrame Value);

		virtual ::openfl::_v2::display::BitmapData get_pixels( );

		virtual Void calcFrame( hx::Null< bool >  RunOnCpp);

		virtual Void resetHelpers( );

		virtual Void stamp( ::flixel::FlxSprite Brush,hx::Null< int >  X,hx::Null< int >  Y);

		virtual ::flixel::graphics::frames::FlxFramesCollection set_frames( ::flixel::graphics::frames::FlxFramesCollection Frames);

		virtual Void updateColorTransform( );

};

} // end namespace flixel
} // end namespace group

#endif /* INCLUDED_flixel_group_FlxTypedSpriteGroup */ 
