package;

import flixel.FlxG;
import openfl.Assets;

using StringTools;

class CoolUtil {
	public static function truncateFloat(number:Float, precision:Int):Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function loadText(path:String):Array<String> {
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function loadTextLowercase(path:String):Array<String> {
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim().toLowerCase();
		}

		return daList;
	}

	public static function loadSong(song:String, diff:String, week:Int, isStory:Bool) {
		var poop:String = Highscore.formatSong(song.toLowerCase(), diff);
		PlayState.SONG = Song.loadFromJson(poop, song.toLowerCase());
		PlayState.isStoryMode = isStory;
		PlayState.storyDifficulty = diff;
		trace(poop);
		FlxG.switchState(new PlayState());
	}
}
