package flixel.input.actions;

class VDFString
{
	public static function get():String
	{
		return '"In Game Actions"' + '\n' + '{' + '\n' + '	"actions"' + '\n' + '	{' + '\n' + '		"BattleControls"' + '\n' + '		{' + '\n'
			+ '			"title"					"#battle_title"' + '\n' + '			"Button"' + '\n' + '			{' + '\n' + '				"punch"				"#battle_punch"' + '\n'
			+ '				"kick"				"#battle_kick"' + '\n' + '				"jump"				"#battle_jump"' + '\n' + '			}' + '\n' + '			"StickPadGyro"' + '\n' + '			{' + '\n'
			+ '				"move"' + '\n' + '				{' + '\n' + '					"title"			"#battle_move"' + '\n' + '					"input_mode"	"joystick_move"' + '\n' + '				}' + '\n'
			+ '			}' + '\n' + '		}' + '\n' + '		' + '\n' + '		"MapControls"' + '\n' + '		{' + '\n' + '			"title"					"#map_title"' + '\n'
			+ '			"StickPadGyro"' + '\n' + '			{' + '\n' + '				"move_map"' + '\n' + '				{' + '\n' + '					"title"			"#map_move"' + '\n'
			+ '					"input_mode"	"absolute_mouse"' + '\n' + '				}' + '\n' + '				"scroll_map"' + '\n' + '				{' + '\n' + '					"title"			"#map_scroll"'
			+ '\n' + '					"input_mode"	"absolute_mouse"' + '\n' + '				}' + '\n' + '			}' + '\n' + '			"Button"' + '\n' + '			{' + '\n'
			+ '				"map_select"		"#map_select"' + '\n' + '				"map_exit"			"#map_exit"' + '\n' + '				"map_menu"			"#map_menu"' + '\n'
			+ '				"map_journal"		"#map_journal"' + '\n' + '			}' + '\n' + '		}' + '\n' + '		' + '\n' + '		"MenuControls"' + '\n' + '		{' + '\n'
			+ '			"title"					"#menu_title"' + '\n' + '			"StickPadGyro"' + '\n' + '			{' + '\n' + '				"menu_move"' + '\n' + '				{' + '\n'
			+ '					"title"			"#menu_move"' + '\n' + '					"input_mode"	"joystick_move"' + '\n' + '				}' + '\n' + '			}' + '\n' + '			"Button"' + '\n'
			+ '			{' + '\n' + '				"menu_up"			"#menu_up"' + '\n' + '				"menu_down"			"#menu_down"' + '\n' + '				"menu_left"			"#menu_left"' + '\n'
			+ '				"menu_right"		"#menu_right"' + '\n' + '				"menu_select"		"#menu_select"' + '\n' + '				"menu_cancel"		"#menu_cancel"' + '\n'
			+ '				"menu_thing_1"		"#menu_thing_1"' + '\n' + '				"menu_thing_2"		"#menu_thing_2"' + '\n' + '				"menu_thing_3"		"#menu_thing_3"' + '\n'
			+ '				"menu_menu"			"#menu_menu"' + '\n' + '			}' + '\n' + '		}' + '\n' + '	}' + '\n' + '	"localization"' + '\n' + '	{' + '\n' + '		"english"'
			+ '\n' + '		{' + '\n' + '			"battle_title"				"Battle controls"' + '\n' + '			"battle_punch"				"Punch"' + '\n' + '			"battle_kick"				"Kick"'
			+ '\n' + '			"battle_jump"				"Jump"' + '\n' + '			"battle_move"				"Move"' + '\n' + '			' + '\n' + '			"map_title"					"Map controls"' + '\n'
			+ '			"map_scroll"				"Scroll map"' + '\n' + '			"map_move"					"Move location"' + '\n' + '			"map_select"				"Select"' + '\n'
			+ '			"map_exit"					"Exit"' + '\n' + '			"map_menu"					"Options Menu"' + '\n' + '			"map_journal"				"Journal"' + '\n' + '			' + '\n'
			+ '			"menu_title"				"Menu controls"' + '\n' + '			"menu_move"					"Analog movement"' + '\n' + '			"menu_up"					"Cursor up"' + '\n'
			+ '			"menu_down"					"Cursor down"' + '\n' + '			"menu_left"					"Cursor left"' + '\n' + '			"menu_right"				"Cursor right"' + '\n'
			+ '			"menu_select"				"Select"' + '\n' + '			"menu_cancel"				"Cancel"' + '\n' + '			"menu_thing_1"				"Menu choice 1"' + '\n'
			+ '			"menu_thing_2"				"Menu choice 2"' + '\n' + '			"menu_thing_3"				"Menu choice 3"' + '\n' + '			"menu_menu"					"Menu"' + '\n' + '		}'
			+ '\n' + '	}' + '\n' + '}' + '\n';
	}
}
