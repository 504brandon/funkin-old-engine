package states;

import handlers.Character;
import handlers.MusicBeatState;
import handlers.CoolUtil;
import handlers.ui.Alphabet;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class CharSkin extends MusicBeatState {
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var alphaberfunni:Alphabet;

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

    static var char:Character;

	public function new() {
		super();

		menuItems = CoolUtil.loadText('assets/data/playableChars.txt');

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

        char = new Character(210, 0);
        add(char);

        char.flipX = !char.flipX;

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

            //will save selected char here
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

        char.changeCharacter(menuItems[curSelected]);

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
