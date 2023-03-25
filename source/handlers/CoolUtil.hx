package handlers;

import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.Assets;
import states.PlayState;

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

	public static function camLerpShit(lerp:Float):Float {
		return lerp * (FlxG.elapsed / (1 / 60));
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float):Float {
		return FlxMath.lerp(a, b, camLerpShit(ratio));
	}

	public static function loadMods() {
		#if sys
		polymod.Polymod.init({
			modRoot: "mods",
			dirs: sys.FileSystem.readDirectory('./mods'),
			errorCallback: (e) -> {
				trace(e.message);
			},
			frameworkParams: {
				assetLibraryPaths: [
					"songs" => "assets/songs",
					"images" => "assets/images",
					"data" => "assets/data",
					"fonts" => "assets/fonts",
					"sounds" => "assets/sounds",
					"music" => "assets/music",
				]
			}
		});
		#end
	}
}
