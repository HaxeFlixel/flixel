#ifndef INCLUDED_flixel_system_FlxQuadTree
#define INCLUDED_flixel_system_FlxQuadTree

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/math/FlxRect.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,system,FlxLinkedList)
HX_DECLARE_CLASS2(flixel,system,FlxQuadTree)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxQuadTree_obj : public ::flixel::math::FlxRect_obj{
	public:
		typedef ::flixel::math::FlxRect_obj super;
		typedef FlxQuadTree_obj OBJ_;
		FlxQuadTree_obj();
		Void __construct(Float X,Float Y,Float Width,Float Height,::flixel::system::FlxQuadTree Parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxQuadTree_obj > __new(Float X,Float Y,Float Width,Float Height,::flixel::system::FlxQuadTree Parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxQuadTree_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxQuadTree"); }

		bool exists;
		bool _canSubdivide;
		::flixel::system::FlxLinkedList _headA;
		::flixel::system::FlxLinkedList _tailA;
		::flixel::system::FlxLinkedList _headB;
		::flixel::system::FlxLinkedList _tailB;
		::flixel::system::FlxQuadTree _northWestTree;
		::flixel::system::FlxQuadTree _northEastTree;
		::flixel::system::FlxQuadTree _southEastTree;
		::flixel::system::FlxQuadTree _southWestTree;
		Float _leftEdge;
		Float _rightEdge;
		Float _topEdge;
		Float _bottomEdge;
		Float _halfWidth;
		Float _halfHeight;
		Float _midpointX;
		Float _midpointY;
		::flixel::system::FlxQuadTree next;
		virtual Void reset( Float X,Float Y,Float Width,Float Height,::flixel::system::FlxQuadTree Parent);
		Dynamic reset_dyn();

		virtual Void destroy( );

		virtual Void load( ::flixel::FlxBasic ObjectOrGroup1,::flixel::FlxBasic ObjectOrGroup2,Dynamic NotifyCallback,Dynamic ProcessCallback);
		Dynamic load_dyn();

		virtual Void add( ::flixel::FlxBasic ObjectOrGroup,int list);
		Dynamic add_dyn();

		virtual Void addObject( );
		Dynamic addObject_dyn();

		virtual Void addToList( );
		Dynamic addToList_dyn();

		virtual bool execute( );
		Dynamic execute_dyn();

		virtual bool overlapNode( );
		Dynamic overlapNode_dyn();

		static int A_LIST;
		static int B_LIST;
		static int divisions;
		static int _min;
		static ::flixel::FlxObject _object;
		static Float _objectLeftEdge;
		static Float _objectTopEdge;
		static Float _objectRightEdge;
		static Float _objectBottomEdge;
		static int _list;
		static bool _useBothLists;
		static Dynamic _processingCallback;
		static Dynamic &_processingCallback_dyn() { return _processingCallback;}
		static Dynamic _notifyCallback;
		static Dynamic &_notifyCallback_dyn() { return _notifyCallback;}
		static ::flixel::system::FlxLinkedList _iterator;
		static Float _objectHullX;
		static Float _objectHullY;
		static Float _objectHullWidth;
		static Float _objectHullHeight;
		static Float _checkObjectHullX;
		static Float _checkObjectHullY;
		static Float _checkObjectHullWidth;
		static Float _checkObjectHullHeight;
		static int _NUM_CACHED_QUAD_TREES;
		static ::flixel::system::FlxQuadTree _cachedTreesHead;
		static ::flixel::system::FlxQuadTree recycle( Float X,Float Y,Float Width,Float Height,::flixel::system::FlxQuadTree Parent);
		static Dynamic recycle_dyn();

		static Void clearCache( );
		static Dynamic clearCache_dyn();

};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxQuadTree */ 
