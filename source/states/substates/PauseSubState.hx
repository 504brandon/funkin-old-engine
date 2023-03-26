package states.substates;

import handlers.Controls.Control;
import handlers.MusicBeatSubstate;
import handlers.Highscore;
import handlers.ui.Alphabet;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
//import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
//import flixel.system.FlxSound;
import flixel.text.FlxText;
//import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var pauseOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var difficultyChoices:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	public function new(x:Float, y:Float) {
		super();

		menuItems = pauseOG;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat("assets/fonts/vcr.ttf", 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += PlayState.storyDifficulty.toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat("assets/fonts/vcr.ttf", 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var deathCounter:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		deathCounter.text = "Blue balled: " + PlayState.blueBalled;
		deathCounter.scrollFactor.set();
		deathCounter.setFormat("assets/fonts/vcr.ttf", 32);
		deathCounter.updateHitbox();
		add(deathCounter);

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathCounter.x = FlxG.width - (deathCounter.width + 20);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	private function regenMenu():Void {
		while (grpMenuShit.members.length > 0) {
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var upP = controls.UP_R;
		var downP = controls.DOWN_R;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case "Resume":
					close();
				case "EASY" | 'NORMAL' | "HARD":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), daSelected), PlayState.SONG.song.toLowerCase());

					PlayState.storyDifficulty = daSelected;

					FlxG.resetState();

				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'BACK':
					menuItems = pauseOG;
					regenMenu();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					PlayState.blueBalled = 0;

					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else
						FlxG.switchState(new FreeplayState());
			}
		}
	}

	override function destroy() {
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
