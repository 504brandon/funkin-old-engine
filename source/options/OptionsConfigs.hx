package options;

import flixel.FlxG;

class OptionsConfigs
{
	public static var botplay:Bool = false;
	public static var ghostTapping:Bool = true;
    public static var dadGlow:Bool = false;
	#if sys
	public static var fps:Int = 100;
	#end

	public static function saveOptions() {
		FlxG.save.data.bot = botplay;
		FlxG.save.data.ghost = ghostTapping;
        FlxG.save.data.opglow = dadGlow;
		#if sys
		FlxG.save.data.areyoulowquality = fps;
		#end

        FlxG.save.flush();
	}

	public static function loadOptions() {
		if (FlxG.save.data.bot != null) 
		    botplay = FlxG.save.data.bot;
        if (FlxG.save.data.ghost != null)
		    ghostTapping = FlxG.save.data.ghost;
        if (FlxG.save.data.opglow)
            dadGlow = FlxG.save.data.opglow;
		#if sys
		if (FlxG.save.data.areyoulowquality)
			fps = FlxG.save.data.areyoulowquality;
		#end

        FlxG.save.flush();
	}
}