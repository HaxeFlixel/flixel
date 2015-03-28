#ifndef INCLUDED_flixel_effects_particles_FlxTypedEmitter
#define INCLUDED_flixel_effects_particles_FlxTypedEmitter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/group/FlxTypedGroup.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS3(flixel,effects,particles,FlxEmitterMode)
HX_DECLARE_CLASS3(flixel,effects,particles,FlxTypedEmitter)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(flixel,util,helpers,FlxBounds)
HX_DECLARE_CLASS3(flixel,util,helpers,FlxPointRangeBounds)
HX_DECLARE_CLASS3(flixel,util,helpers,FlxRangeBounds)
HX_DECLARE_CLASS3(openfl,_v2,display,BlendMode)
namespace flixel{
namespace effects{
namespace particles{


class HXCPP_CLASS_ATTRIBUTES  FlxTypedEmitter_obj : public ::flixel::group::FlxTypedGroup_obj{
	public:
		typedef ::flixel::group::FlxTypedGroup_obj super;
		typedef FlxTypedEmitter_obj OBJ_;
		FlxTypedEmitter_obj();
		Void __construct(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< int >  __o_Size);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTypedEmitter_obj > __new(hx::Null< Float >  __o_X,hx::Null< Float >  __o_Y,hx::Null< int >  __o_Size);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTypedEmitter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTypedEmitter"); }

		::Class particleClass;
		bool emitting;
		Float frequency;
		::openfl::_v2::display::BlendMode blend;
		Float x;
		Float y;
		Float width;
		Float height;
		::flixel::effects::particles::FlxEmitterMode launchMode;
		bool keepScaleRatio;
		::flixel::util::helpers::FlxPointRangeBounds velocity;
		::flixel::util::helpers::FlxRangeBounds speed;
		::flixel::util::helpers::FlxRangeBounds angularAcceleration;
		::flixel::util::helpers::FlxRangeBounds angularDrag;
		::flixel::util::helpers::FlxRangeBounds angularVelocity;
		::flixel::util::helpers::FlxRangeBounds angle;
		bool ignoreAngularVelocity;
		::flixel::util::helpers::FlxBounds launchAngle;
		::flixel::util::helpers::FlxBounds lifespan;
		::flixel::util::helpers::FlxPointRangeBounds scale;
		::flixel::util::helpers::FlxRangeBounds alpha;
		::flixel::util::helpers::FlxRangeBounds color;
		::flixel::util::helpers::FlxPointRangeBounds drag;
		::flixel::util::helpers::FlxPointRangeBounds acceleration;
		::flixel::util::helpers::FlxRangeBounds elasticity;
		bool immovable;
		bool autoUpdateHitbox;
		int allowCollisions;
		int _quantity;
		bool _explode;
		Float _timer;
		int _counter;
		::flixel::math::FlxPoint _point;
		bool _waitForKill;
		virtual Void destroy( );

		virtual ::flixel::effects::particles::FlxTypedEmitter loadParticles( Dynamic Graphics,hx::Null< int >  Quantity,hx::Null< int >  bakedRotationAngles,hx::Null< bool >  Multiple,hx::Null< bool >  AutoBuffer);
		Dynamic loadParticles_dyn();

		virtual ::flixel::effects::particles::FlxTypedEmitter makeParticles( hx::Null< int >  Width,hx::Null< int >  Height,hx::Null< int >  Color,hx::Null< int >  Quantity);
		Dynamic makeParticles_dyn();

		virtual Void update( Float elapsed);

		virtual Void kill( );

		virtual ::flixel::effects::particles::FlxTypedEmitter start( hx::Null< bool >  Explode,hx::Null< Float >  Frequency,hx::Null< int >  Quantity);
		Dynamic start_dyn();

		virtual Void emitParticle( );
		Dynamic emitParticle_dyn();

		virtual Void focusOn( ::flixel::FlxObject Object);
		Dynamic focusOn_dyn();

		virtual Void setPosition( hx::Null< Float >  X,hx::Null< Float >  Y);
		Dynamic setPosition_dyn();

		virtual Void setSize( Float Width,Float Height);
		Dynamic setSize_dyn();

		virtual bool get_solid( );
		Dynamic get_solid_dyn();

		virtual bool set_solid( bool Solid);
		Dynamic set_solid_dyn();

};

} // end namespace flixel
} // end namespace effects
} // end namespace particles

#endif /* INCLUDED_flixel_effects_particles_FlxTypedEmitter */ 
