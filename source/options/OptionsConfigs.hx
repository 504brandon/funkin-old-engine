package options;

import flixel.FlxG;

class OptionsConfigs
{
	public static var botplay:Bool = false;
	public static var ghostTapping:Bool = true;
    public static var dadGlow:Bool = false;
	public static var iconAnimed:Bool = true;

	public static function saveOptions() {
		FlxG.save.data.bot = botplay;
		FlxG.save.data.ghost = ghostTapping;
        FlxG.save.data.opglow = dadGlow;
		FlxG.save.data.animIcon = iconAnimed;
        FlxG.save.flush();
	}

	public static function loadOptions() {
		if (FlxG.save.data.bot != null) 
		    botplay = FlxG.save.data.bot;
        if (FlxG.save.data.ghost != null)
		    ghostTapping = FlxG.save.data.ghost;
        if (FlxG.save.data.opglow)
            dadGlow = FlxG.save.data.opglow;
		if (FlxG.save.data.animIcon)
            iconAnimed = FlxG.save.data.animIcon;
        FlxG.save.flush();
	}
}