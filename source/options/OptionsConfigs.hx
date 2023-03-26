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
	public static var dbicon:Bool = false;
	public static var firstload:Bool = true;
	public static var downscroll:Bool = false;
	public static var middlescroll:Bool = false;
	public static var flashingLights:Bool = true;

	inline public static function verNum():String {
		var ver:String;

		ver = lime.app.Application.current.meta.get('version');

		return ver;
	}

	public static function saveOptions() {
		FlxG.save.data.bot = botplay;
		FlxG.save.data.ghost = ghostTapping;
        FlxG.save.data.opglow = dadGlow;
		FlxG.save.data.animIcon = iconAnimed;
		#if sys
		FlxG.save.data.areyoulowquality = fps;
		#end
		FlxG.save.data.fc = fc;
		FlxG.save.data.daveandbambifanhere = dbicon;
		FlxG.save.data.firsttime = firstload;
		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.middlescroll = middlescroll;
		FlxG.save.data.flashingLights = flashingLights;

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
		fps = FlxG.save.data.areyoulowquality;
		#end
		if (FlxG.save.data.fc != null)
			fc = FlxG.save.data.fc;
		if (FlxG.save.data.daveandbambifanhere != null)
			dbicon = FlxG.save.data.daveandbambifanhere;
		if (FlxG.save.data.firsttime != null)
			firstload = FlxG.save.data.firsttime;
		if (FlxG.save.data.downscroll != null)
			downscroll = FlxG.save.data.downscroll;
		if (FlxG.save.data.middlescroll != null)
			middlescroll = FlxG.save.data.middlescroll;
		if (FlxG.save.data.flashingLights != null)
			flashingLights = FlxG.save.data.flashingLights;

        FlxG.save.flush();
	}
}