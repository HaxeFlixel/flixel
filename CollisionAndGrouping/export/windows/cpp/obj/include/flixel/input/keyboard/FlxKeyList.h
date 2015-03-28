#ifndef INCLUDED_flixel_input_keyboard_FlxKeyList
#define INCLUDED_flixel_input_keyboard_FlxKeyList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/input/FlxBaseKeyList.h>
HX_DECLARE_CLASS2(flixel,input,FlxBaseKeyList)
HX_DECLARE_CLASS2(flixel,input,FlxKeyManager)
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS3(flixel,input,keyboard,FlxKeyList)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace input{
namespace keyboard{


class HXCPP_CLASS_ATTRIBUTES  FlxKeyList_obj : public ::flixel::input::FlxBaseKeyList_obj{
	public:
		typedef ::flixel::input::FlxBaseKeyList_obj super;
		typedef FlxKeyList_obj OBJ_;
		FlxKeyList_obj();
		Void __construct(int status,::flixel::input::FlxKeyManager keyManager);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxKeyList_obj > __new(int status,::flixel::input::FlxKeyManager keyManager);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxKeyList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxKeyList"); }

		virtual bool get_A( );
		Dynamic get_A_dyn();

		virtual bool get_B( );
		Dynamic get_B_dyn();

		virtual bool get_C( );
		Dynamic get_C_dyn();

		virtual bool get_D( );
		Dynamic get_D_dyn();

		virtual bool get_E( );
		Dynamic get_E_dyn();

		virtual bool get_F( );
		Dynamic get_F_dyn();

		virtual bool get_G( );
		Dynamic get_G_dyn();

		virtual bool get_H( );
		Dynamic get_H_dyn();

		virtual bool get_I( );
		Dynamic get_I_dyn();

		virtual bool get_J( );
		Dynamic get_J_dyn();

		virtual bool get_K( );
		Dynamic get_K_dyn();

		virtual bool get_L( );
		Dynamic get_L_dyn();

		virtual bool get_M( );
		Dynamic get_M_dyn();

		virtual bool get_N( );
		Dynamic get_N_dyn();

		virtual bool get_O( );
		Dynamic get_O_dyn();

		virtual bool get_P( );
		Dynamic get_P_dyn();

		virtual bool get_Q( );
		Dynamic get_Q_dyn();

		virtual bool get_R( );
		Dynamic get_R_dyn();

		virtual bool get_S( );
		Dynamic get_S_dyn();

		virtual bool get_T( );
		Dynamic get_T_dyn();

		virtual bool get_U( );
		Dynamic get_U_dyn();

		virtual bool get_V( );
		Dynamic get_V_dyn();

		virtual bool get_W( );
		Dynamic get_W_dyn();

		virtual bool get_X( );
		Dynamic get_X_dyn();

		virtual bool get_Y( );
		Dynamic get_Y_dyn();

		virtual bool get_Z( );
		Dynamic get_Z_dyn();

		virtual bool get_ZERO( );
		Dynamic get_ZERO_dyn();

		virtual bool get_ONE( );
		Dynamic get_ONE_dyn();

		virtual bool get_TWO( );
		Dynamic get_TWO_dyn();

		virtual bool get_THREE( );
		Dynamic get_THREE_dyn();

		virtual bool get_FOUR( );
		Dynamic get_FOUR_dyn();

		virtual bool get_FIVE( );
		Dynamic get_FIVE_dyn();

		virtual bool get_SIX( );
		Dynamic get_SIX_dyn();

		virtual bool get_SEVEN( );
		Dynamic get_SEVEN_dyn();

		virtual bool get_EIGHT( );
		Dynamic get_EIGHT_dyn();

		virtual bool get_NINE( );
		Dynamic get_NINE_dyn();

		virtual bool get_PAGEUP( );
		Dynamic get_PAGEUP_dyn();

		virtual bool get_PAGEDOWN( );
		Dynamic get_PAGEDOWN_dyn();

		virtual bool get_HOME( );
		Dynamic get_HOME_dyn();

		virtual bool get_END( );
		Dynamic get_END_dyn();

		virtual bool get_INSERT( );
		Dynamic get_INSERT_dyn();

		virtual bool get_ESCAPE( );
		Dynamic get_ESCAPE_dyn();

		virtual bool get_MINUS( );
		Dynamic get_MINUS_dyn();

		virtual bool get_PLUS( );
		Dynamic get_PLUS_dyn();

		virtual bool get_DELETE( );
		Dynamic get_DELETE_dyn();

		virtual bool get_BACKSPACE( );
		Dynamic get_BACKSPACE_dyn();

		virtual bool get_LBRACKET( );
		Dynamic get_LBRACKET_dyn();

		virtual bool get_RBRACKET( );
		Dynamic get_RBRACKET_dyn();

		virtual bool get_BACKSLASH( );
		Dynamic get_BACKSLASH_dyn();

		virtual bool get_CAPSLOCK( );
		Dynamic get_CAPSLOCK_dyn();

		virtual bool get_SEMICOLON( );
		Dynamic get_SEMICOLON_dyn();

		virtual bool get_QUOTE( );
		Dynamic get_QUOTE_dyn();

		virtual bool get_ENTER( );
		Dynamic get_ENTER_dyn();

		virtual bool get_SHIFT( );
		Dynamic get_SHIFT_dyn();

		virtual bool get_COMMA( );
		Dynamic get_COMMA_dyn();

		virtual bool get_PERIOD( );
		Dynamic get_PERIOD_dyn();

		virtual bool get_SLASH( );
		Dynamic get_SLASH_dyn();

		virtual bool get_GRAVEACCENT( );
		Dynamic get_GRAVEACCENT_dyn();

		virtual bool get_CONTROL( );
		Dynamic get_CONTROL_dyn();

		virtual bool get_ALT( );
		Dynamic get_ALT_dyn();

		virtual bool get_SPACE( );
		Dynamic get_SPACE_dyn();

		virtual bool get_UP( );
		Dynamic get_UP_dyn();

		virtual bool get_DOWN( );
		Dynamic get_DOWN_dyn();

		virtual bool get_LEFT( );
		Dynamic get_LEFT_dyn();

		virtual bool get_RIGHT( );
		Dynamic get_RIGHT_dyn();

		virtual bool get_TAB( );
		Dynamic get_TAB_dyn();

		virtual bool get_PRINTSCREEN( );
		Dynamic get_PRINTSCREEN_dyn();

		virtual bool get_F1( );
		Dynamic get_F1_dyn();

		virtual bool get_F2( );
		Dynamic get_F2_dyn();

		virtual bool get_F3( );
		Dynamic get_F3_dyn();

		virtual bool get_F4( );
		Dynamic get_F4_dyn();

		virtual bool get_F5( );
		Dynamic get_F5_dyn();

		virtual bool get_F6( );
		Dynamic get_F6_dyn();

		virtual bool get_F7( );
		Dynamic get_F7_dyn();

		virtual bool get_F8( );
		Dynamic get_F8_dyn();

		virtual bool get_F9( );
		Dynamic get_F9_dyn();

		virtual bool get_F10( );
		Dynamic get_F10_dyn();

		virtual bool get_F11( );
		Dynamic get_F11_dyn();

		virtual bool get_F12( );
		Dynamic get_F12_dyn();

		virtual bool get_NUMPADONE( );
		Dynamic get_NUMPADONE_dyn();

		virtual bool get_NUMPADTWO( );
		Dynamic get_NUMPADTWO_dyn();

		virtual bool get_NUMPADTHREE( );
		Dynamic get_NUMPADTHREE_dyn();

		virtual bool get_NUMPADFOUR( );
		Dynamic get_NUMPADFOUR_dyn();

		virtual bool get_NUMPADFIVE( );
		Dynamic get_NUMPADFIVE_dyn();

		virtual bool get_NUMPADSIX( );
		Dynamic get_NUMPADSIX_dyn();

		virtual bool get_NUMPADSEVEN( );
		Dynamic get_NUMPADSEVEN_dyn();

		virtual bool get_NUMPADEIGHT( );
		Dynamic get_NUMPADEIGHT_dyn();

		virtual bool get_NUMPADNINE( );
		Dynamic get_NUMPADNINE_dyn();

		virtual bool get_NUMPADZERO( );
		Dynamic get_NUMPADZERO_dyn();

		virtual bool get_NUMPADMINUS( );
		Dynamic get_NUMPADMINUS_dyn();

		virtual bool get_NUMPADPLUS( );
		Dynamic get_NUMPADPLUS_dyn();

		virtual bool get_NUMPADPERIOD( );
		Dynamic get_NUMPADPERIOD_dyn();

		virtual bool get_NUMPADMULTIPLY( );
		Dynamic get_NUMPADMULTIPLY_dyn();

};

} // end namespace flixel
} // end namespace input
} // end namespace keyboard

#endif /* INCLUDED_flixel_input_keyboard_FlxKeyList */ 
