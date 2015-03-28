#ifndef INCLUDED_flixel_phys_classic_FlxNewQuadTree
#define INCLUDED_flixel_phys_classic_FlxNewQuadTree

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/math/FlxRect.h>
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxLinkedListNew)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxNewQuadTree)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace phys{
namespace classic{


class HXCPP_CLASS_ATTRIBUTES  FlxNewQuadTree_obj : public ::flixel::math::FlxRect_obj{
	public:
		typedef ::flixel::math::FlxRect_obj super;
		typedef FlxNewQuadTree_obj OBJ_;
		FlxNewQuadTree_obj();
		Void __construct(Float X,Float Y,Float Width,Float Height,::flixel::phys::classic::FlxNewQuadTree Parent);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxNewQuadTree_obj > __new(Float X,Float Y,Float Width,Float Height,::flixel::phys::classic::FlxNewQuadTree Parent);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxNewQuadTree_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxNewQuadTree"); }

		bool exists;
		bool _canSubdivide;
		::flixel::phys::classic::FlxLinkedListNew _headA;
		::flixel::phys::classic::FlxLinkedListNew _tailA;
		::flixel::phys::classic::FlxLinkedListNew _headB;
		::flixel::phys::classic::FlxLinkedListNew _tailB;
		::flixel::phys::classic::FlxNewQuadTree _northWestTree;
		::flixel::phys::classic::FlxNewQuadTree _northEastTree;
		::flixel::phys::classic::FlxNewQuadTree _southEastTree;
		::flixel::phys::classic::FlxNewQuadTree _southWestTree;
		Float _leftEdge;
		Float _rightEdge;
		Float _topEdge;
		Float _bottomEdge;
		Float _halfWidth;
		Float _halfHeight;
		Float _midpointX;
		Float _midpointY;
		::flixel::phys::classic::FlxNewQuadTree next;
		virtual Void reset( Float X,Float Y,Float Width,Float Height,::flixel::phys::classic::FlxNewQuadTree Parent);
		Dynamic reset_dyn();

		virtual Void destroy( );

		virtual Void load( Array< ::Dynamic > ObjectOrGroup1,::flixel::phys::classic::FlxClassicBody ObjectOrGroup2,Dynamic NotifyCallback,Dynamic ProcessCallback);
		Dynamic load_dyn();

		virtual Void add( ::flixel::phys::classic::FlxClassicBody ObjectOrGroup,int list);
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
		static ::flixel::phys::classic::FlxClassicBody _object;
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
		static ::flixel::phys::classic::FlxLinkedListNew _iterator;
		static Float _objectHullX;
		static Float _objectHullY;
		static Float _objectHullWidth;
		static Float _objectHullHeight;
		static Float _checkObjectHullX;
		static Float _checkObjectHullY;
		static Float _checkObjectHullWidth;
		static Float _checkObjectHullHeight;
		static int _NUM_CACHED_QUAD_TREES;
		static ::flixel::phys::classic::FlxNewQuadTree _cachedTreesHead;
		static int numberOfQuadTrees;
		static ::flixel::phys::classic::FlxNewQuadTree recycle( Float X,Float Y,Float Width,Float Height,::flixel::phys::classic::FlxNewQuadTree Parent);
		static Dynamic recycle_dyn();

		static Void clearCache( );
		static Dynamic clearCache_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace classic

#endif /* INCLUDED_flixel_phys_classic_FlxNewQuadTree */ 
