#ifndef INCLUDED_openfl__v2_display_DisplayObjectContainer
#define INCLUDED_openfl__v2_display_DisplayObjectContainer

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/InteractiveObject.h>
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObjectContainer)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,InteractiveObject)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  DisplayObjectContainer_obj : public ::openfl::_v2::display::InteractiveObject_obj{
	public:
		typedef ::openfl::_v2::display::InteractiveObject_obj super;
		typedef DisplayObjectContainer_obj OBJ_;
		DisplayObjectContainer_obj();
		Void __construct(Dynamic handle,::String type);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< DisplayObjectContainer_obj > __new(Dynamic handle,::String type);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~DisplayObjectContainer_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("DisplayObjectContainer"); }

		int numChildren;
		Array< ::Dynamic > __children;
		virtual ::openfl::_v2::display::DisplayObject addChild( ::openfl::_v2::display::DisplayObject child);
		Dynamic addChild_dyn();

		virtual ::openfl::_v2::display::DisplayObject addChildAt( ::openfl::_v2::display::DisplayObject child,int index);
		Dynamic addChildAt_dyn();

		virtual bool areInaccessibleObjectsUnderPoint( ::openfl::_v2::geom::Point point);
		Dynamic areInaccessibleObjectsUnderPoint_dyn();

		virtual bool contains( ::openfl::_v2::display::DisplayObject child);
		Dynamic contains_dyn();

		virtual ::openfl::_v2::display::DisplayObject getChildAt( int index);
		Dynamic getChildAt_dyn();

		virtual ::openfl::_v2::display::DisplayObject getChildByName( ::String name);
		Dynamic getChildByName_dyn();

		virtual int getChildIndex( ::openfl::_v2::display::DisplayObject child);
		Dynamic getChildIndex_dyn();

		virtual Array< ::Dynamic > getObjectsUnderPoint( ::openfl::_v2::geom::Point point);
		Dynamic getObjectsUnderPoint_dyn();

		virtual ::openfl::_v2::display::DisplayObject removeChild( ::openfl::_v2::display::DisplayObject child);
		Dynamic removeChild_dyn();

		virtual ::openfl::_v2::display::DisplayObject removeChildAt( int index);
		Dynamic removeChildAt_dyn();

		virtual Void removeChildren( hx::Null< int >  beginIndex,hx::Null< int >  endIndex);
		Dynamic removeChildren_dyn();

		virtual Void setChildIndex( ::openfl::_v2::display::DisplayObject child,int index);
		Dynamic setChildIndex_dyn();

		virtual Void swapChildren( ::openfl::_v2::display::DisplayObject child1,::openfl::_v2::display::DisplayObject child2);
		Dynamic swapChildren_dyn();

		virtual Void swapChildrenAt( int index1,int index2);
		Dynamic swapChildrenAt_dyn();

		virtual Void __addChild( ::openfl::_v2::display::DisplayObject child);
		Dynamic __addChild_dyn();

		virtual Void __broadcast( ::openfl::_v2::events::Event event);

		virtual bool __contains( ::openfl::_v2::display::DisplayObject child);

		virtual ::openfl::_v2::display::DisplayObject __findByID( int id);

		virtual int __getChildIndex( ::openfl::_v2::display::DisplayObject child);
		Dynamic __getChildIndex_dyn();

		virtual Void __getObjectsUnderPoint( ::openfl::_v2::geom::Point point,Array< ::Dynamic > result);

		virtual Void __onAdded( ::openfl::_v2::display::DisplayObject object,bool isOnStage);

		virtual Void __onRemoved( ::openfl::_v2::display::DisplayObject object,bool wasOnStage);

		virtual Void __removeChildFromArray( ::openfl::_v2::display::DisplayObject child);
		Dynamic __removeChildFromArray_dyn();

		virtual Void __setChildIndex( ::openfl::_v2::display::DisplayObject child,int index);
		Dynamic __setChildIndex_dyn();

		virtual Void __swapChildrenAt( int index1,int index2);
		Dynamic __swapChildrenAt_dyn();

		virtual bool get_mouseChildren( );
		Dynamic get_mouseChildren_dyn();

		virtual bool set_mouseChildren( bool value);
		Dynamic set_mouseChildren_dyn();

		virtual int get_numChildren( );
		Dynamic get_numChildren_dyn();

		virtual bool get_tabChildren( );
		Dynamic get_tabChildren_dyn();

		virtual bool set_tabChildren( bool value);
		Dynamic set_tabChildren_dyn();

		static Dynamic lime_create_display_object_container;
		static Dynamic &lime_create_display_object_container_dyn() { return lime_create_display_object_container;}
		static Dynamic lime_doc_add_child;
		static Dynamic &lime_doc_add_child_dyn() { return lime_doc_add_child;}
		static Dynamic lime_doc_remove_child;
		static Dynamic &lime_doc_remove_child_dyn() { return lime_doc_remove_child;}
		static Dynamic lime_doc_set_child_index;
		static Dynamic &lime_doc_set_child_index_dyn() { return lime_doc_set_child_index;}
		static Dynamic lime_doc_get_mouse_children;
		static Dynamic &lime_doc_get_mouse_children_dyn() { return lime_doc_get_mouse_children;}
		static Dynamic lime_doc_set_mouse_children;
		static Dynamic &lime_doc_set_mouse_children_dyn() { return lime_doc_set_mouse_children;}
		static Dynamic lime_doc_swap_children;
		static Dynamic &lime_doc_swap_children_dyn() { return lime_doc_swap_children;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_DisplayObjectContainer */ 
