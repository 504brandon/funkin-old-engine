package states;

import handlers.ui.fps.FPS;
import handlers.MusicBeatState;
import handlers.ui.Alphabet;
import handlers.CoolUtil;
import handlers.Highscore;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class FreeplayState extends MusicBeatState {
	var songs:Array<String> = [''];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bg:FlxSprite;

	var diffs:Array<String>;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var songColors:Array<String> = ['0xff9271fd'];

	override function create() {
		CoolUtil.loadMods();

		if (FlxG.sound.music != null) {
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
		}

		songs = CoolUtil.loadTextLowercase('assets/data/freeplaySongList.txt');

		songColors = CoolUtil.loadText('assets/data/freeplayColorList.txt');

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		super.create();
	}

	var stupidTimer:Float = 0.0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		stupidTimer += (1.0 / FPS.currentFPS);

		if (stupidTimer > 1 / 60) {
			changeDaColor();
		}

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P && !FlxG.keys.pressed.SHIFT)
			changeDiff(1);

		if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}

		if (accepted) {
			CoolUtil.loadSong(songs[curSelected], diffs[curDifficulty], 0, false);

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		}
	}

	function changeDiff(change:Int = 0) {
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffs.length - 1;
		if (curDifficulty > diffs.length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected], diffs[curDifficulty]);

		diffText.text = diffs[curDifficulty].toUpperCase();
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;

		if (Assets.exists('assets/data/${songs[curSelected]}/diffs.txt'))
			diffs = CoolUtil.loadTextLowercase('assets/data/${songs[curSelected]}/diffs.txt');
		else
			diffs = ['easy', 'normal', 'hard'];

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected], diffs[curDifficulty]);

		var bullShit:Int = 0;

		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}

	function changeDaColor() {
		if (songColors[curSelected] != null)
			bg.color = FlxColor.interpolate(bg.color, FlxColor.fromString(songColors[curSelected]), 0.045);
	}
}
