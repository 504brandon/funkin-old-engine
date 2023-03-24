package options;

import flixel.FlxG;

class OptionsConfigs
{
	public static var botplay:Bool = false;
	public static var ghostTapping:Bool = true;
    public static var dadGlow:Bool = false;
	public static var iconAnimed:Bool = true;
	#if sys
	public static var fps:Int = 100;
	#end
	public static var fc:Bool = false;

	public static function saveOptions() {
		FlxG.save.data.bot = botplay;
		FlxG.save.data.ghost = ghostTapping;
        FlxG.save.data.opglow = dadGlow;
		FlxG.save.data.animIcon = iconAnimed;
		#if sys
		FlxG.save.data.areyoulowquality = fps;
		#end
		FlxG.save.data.fc = fc;

        FlxG.save.flush();
	}

	public static function loadOptions() {
		if (FlxG.save.data.bot != null) 
		    botplay = FlxG.save.data.bot;
        if (FlxG.save.data.ghost != null)
		    ghostTapping = FlxG.save.data.ghost;
        if (FlxG.save.data.opglow != null)
            dadGlow = FlxG.save.data.opglow;
		if (FlxG.save.data.animIcon != null)
            iconAnimed = FlxG.save.data.animIcon;
		#if sys
		if (FlxG.save.data.areyoulowquality != null)
			fps = FlxG.save.data.areyoulowquality;
		#end
		if (FlxG.save.data.fc != null)
			fc = FlxG.save.data.fc;

        FlxG.save.flush();
	}
}