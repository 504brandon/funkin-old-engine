package options;

import handlers.MusicBeatState;
import handlers.ui.Alphabet;
import states.TitleState;
import states.MainMenuState;
#if sys
import sys.FileSystem;
#end
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class OptionsMain extends MusicBeatState {
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	#if sys
	var menuItemsTemp:Array<String> = [
		'Apperence',
		'GamePlay',
		'Modifiers',
		'Erase All Data'
	];
	var menuItems:Array<String> = [
		'Apperence',
		'GamePlay',
		'Modifiers',
		'Erase All Data'
	];
	var apperenceOptions:Array<String> = [
		'Flashing Lights',
		'Downscroll',
		'Middlescroll',
		'Opponent Strums Glow BETA',
		'Dave and Bambi Golden Apple Bump',
		'FrameRate'
	];
	#else
	var menuItemsTemp:Array<String> = ['Apperence', 'GamePlay'];
	var menuItems:Array<String> = ['Apperence', 'GamePlay'];
	var apperenceOptions:Array<String> = ['Opponent strums glow beta'];
	#end
	var gameplayOptions:Array<String> = [
		'BotPlay',
		'Ghost Tapping'
	];
	var modifierOptions:Array<String> = [
		'FC Mode',
		'Health Drain'
	];
	var curSelected:Int = 0;

	var detailsText:FlxText;

	override function create() {
		var bg = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xff252525;
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		detailsText = new FlxText(0, 680, 0, '');
		detailsText.setFormat('assets/fonts/vcr.tff', 25, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK, false);
		add(detailsText);

		regenMenu();
	}

	private function regenMenu():Void {
		while (grpMenuShit.members.length > 0) {
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length) {
			var optionsText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			optionsText.isMenuItem = true;
			optionsText.targetY = i;
			grpMenuShit.add(optionsText);
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP) {
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN) {
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];

		switch (daSelected) {
			case 'Apperence':
				detailsText.text = '';

				if (FlxG.keys.justPressed.ENTER) {
					menuItems = apperenceOptions;
					regenMenu();
				}
			case 'GamePlay':
				detailsText.text = '';

				if (FlxG.keys.justPressed.ENTER) {
					menuItems = gameplayOptions;
					regenMenu();
				}

			case 'Modifiers':
				detailsText.text = '';

				if (FlxG.keys.justPressed.ENTER) {
					menuItems = modifierOptions;
					regenMenu();
				}
			#if sys
			case 'Erase All Data':
				detailsText.text = 'Erases all of your save data. WARNING THIS IS UNDOABLE!!!';

				if (FlxG.keys.justPressed.ENTER) {
					FlxG.save.erase();
					FlxG.save.destroy();
					FlxG.game.stage.window.alert('all data has been wiped');
					FlxG.resetState();
				}
			case 'FrameRate':
				detailsText.text = 'Baisically how fast your game goes. ${OptionsConfigs.fps}';

				if (controls.LEFT_P) {
					OptionsConfigs.fps -= 5;

					if (FlxG.keys.pressed.SHIFT)
						OptionsConfigs.fps -= 5;

					OptionsConfigs.saveOptions();
				}

				if (controls.RIGHT_P) {
					OptionsConfigs.fps += 5;

					if (FlxG.keys.pressed.SHIFT)
						OptionsConfigs.fps += 5;

					OptionsConfigs.saveOptions();
				}

				if (OptionsConfigs.fps < 10)
					OptionsConfigs.fps = 10;

				if (OptionsConfigs.fps > 500)
					OptionsConfigs.fps = 500;
			#end
			case 'Flashing Lights':
				detailsText.text = 'if disabled, there wont be any flashing lights. ${OptionsConfigs.flashingLights}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.flashingLights = !OptionsConfigs.flashingLights;
			case 'Middlescroll':
				detailsText.text = 'Makes the arrows in the middle. ${OptionsConfigs.middlescroll}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.middlescroll = !OptionsConfigs.middlescroll;
			case 'Downscroll':
				detailsText.text = 'Makes ui down idk. ${OptionsConfigs.downscroll}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.downscroll = !OptionsConfigs.downscroll;
			case 'Dave and bambi bump':
				detailsText.text = 'Makes the icon bump look dave&bambi. ${OptionsConfigs.dbicon}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.dbicon = !OptionsConfigs.dbicon;
			case 'Botplay':
				detailsText.text = 'I mean what do you expect it plays the game for you. ${OptionsConfigs.botplay}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.botplay = !OptionsConfigs.botplay;
			case 'Ghost Tapping':
				detailsText.text = 'Makes it so you can press the notes without missing. ${OptionsConfigs.ghostTapping}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.ghostTapping = !OptionsConfigs.ghostTapping;
			case 'Opponent strums glow beta':
				detailsText.text = 'this is a beta option dont expext much... Opponent strums glow ${OptionsConfigs.dadGlow}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.dadGlow = !OptionsConfigs.dadGlow;
			case 'Animated Icons':
				detailsText.text = 'Icons that are animated like hypno are not animated. ${OptionsConfigs.iconAnimed}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.iconAnimed = !OptionsConfigs.iconAnimed;
			case 'Fc Mode':
				detailsText.text = 'Dont get a miss or you die of death. ${OptionsConfigs.fc}';

				if (FlxG.keys.justPressed.ENTER)
					OptionsConfigs.fc = !OptionsConfigs.fc;
		}

		if (FlxG.keys.justPressed.ENTER && daSelected != 'Erase All Data')
			OptionsConfigs.saveOptions();

		if (FlxG.keys.justPressed.ESCAPE) {
			if (menuItems == gameplayOptions || menuItems == apperenceOptions || menuItems == modifierOptions) {
				menuItems = menuItemsTemp;
				regenMenu();
			} else
				FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.J) {
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
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
