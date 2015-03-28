#ifndef INCLUDED_flixel_overlap_FlxPolygon
#define INCLUDED_flixel_overlap_FlxPolygon

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/overlap/IFlxHitbox.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,math,FlxVector)
HX_DECLARE_CLASS2(flixel,overlap,FlxCircle)
HX_DECLARE_CLASS2(flixel,overlap,FlxHitboxList)
HX_DECLARE_CLASS2(flixel,overlap,FlxOverlapData)
HX_DECLARE_CLASS2(flixel,overlap,FlxPolygon)
HX_DECLARE_CLASS2(flixel,overlap,FlxRay)
HX_DECLARE_CLASS2(flixel,overlap,FlxRayData)
HX_DECLARE_CLASS2(flixel,overlap,IFlxHitbox)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  FlxPolygon_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxPolygon_obj OBJ_;
		FlxPolygon_obj();
		Void __construct(::flixel::FlxSprite sprite,Array< ::Dynamic > vertices);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxPolygon_obj > __new(::flixel::FlxSprite sprite,Array< ::Dynamic > vertices);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxPolygon_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::overlap::IFlxHitbox_obj *()
			{ return new ::flixel::overlap::IFlxHitbox_delegate_< FlxPolygon_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxPolygon"); }

		::flixel::FlxSprite parent;
		Array< ::Dynamic > transformedVertices;
		::flixel::math::FlxRect transformedBoundingBox;
		Array< ::Dynamic > _vertices;
		Float _maxDistance;
		bool _updated;
		virtual bool test( ::flixel::overlap::IFlxHitbox hitbox,::flixel::overlap::FlxOverlapData overlapData);
		Dynamic test_dyn();

		virtual bool testCircle( ::flixel::overlap::FlxCircle circle,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData);
		Dynamic testCircle_dyn();

		virtual bool testPolygon( ::flixel::overlap::FlxPolygon polygon,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData);
		Dynamic testPolygon_dyn();

		virtual bool testHitboxList( ::flixel::overlap::FlxHitboxList hitboxList,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData);
		Dynamic testHitboxList_dyn();

		virtual bool testRay( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxRayData rayData);
		Dynamic testRay_dyn();

		virtual Void updateTransformed( );
		Dynamic updateTransformed_dyn();

		virtual Array< ::Dynamic > get_transformedVertices( );
		Dynamic get_transformedVertices_dyn();

		virtual ::flixel::math::FlxRect get_transformedBoundingBox( );
		Dynamic get_transformedBoundingBox_dyn();

};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_FlxPolygon */ 
