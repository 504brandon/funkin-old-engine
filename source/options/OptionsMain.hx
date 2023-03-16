package options;

#if sys
import sys.FileSystem;
#end
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class OptionsMain extends MusicBeatState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	#if windows
    var menuItemsTemp:Array<String> = ['Apperence', 'GamePlay', 'Erase All Data'];
	var menuItems:Array<String> = ['Apperence', 'GamePlay', 'Erase All Data'];
	#else
	var menuItemsTemp:Array<String> = ['Apperence', 'GamePlay'];
	var menuItems:Array<String> = ['Apperence', 'GamePlay'];
	#end
    var apperenceOptions:Array<String> = ['Opponent strums glow beta', 'Animated Icons'];
    var gameplayOptions:Array<String> = ['Botplay', 'Ghost Tapping'];
	var curSelected:Int = 0;

    var detailsText:FlxText;

	override function create() 
	{
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

	private function regenMenu():Void
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var optionsText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			optionsText.isMenuItem = true;
			optionsText.targetY = i;
			grpMenuShit.add(optionsText);
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

        var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
                case 'Apperence':
					detailsText.text = '';

                    if (FlxG.keys.justPressed.ENTER){
                        menuItems = apperenceOptions;
                        regenMenu();
                    }
                case 'GamePlay':
					detailsText.text = '';

                    if (FlxG.keys.justPressed.ENTER){
                        menuItems = gameplayOptions;
                        regenMenu();
                    }
				#if windows
				case 'Erase All Data':
					detailsText.text = 'Erases all of your save data. WARNING THIS IS UNDOABLE!!!';

					if (FlxG.keys.justPressed.ENTER){
						FlxG.save.erase();
						FlxG.save.destroy();
						FlxG.game.stage.window.alert('all data has been wiped');
						FlxG.resetState();
					}
				#end
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

            if (FlxG.keys.justPressed.ENTER && daSelected != 'Erase All Data')
                OptionsConfigs.saveOptions();
		}

        if (FlxG.keys.justPressed.ESCAPE){
            if (menuItems == gameplayOptions || menuItems == apperenceOptions){
                menuItems = menuItemsTemp;
                regenMenu();
            }
            else
                FlxG.switchState(new MainMenuState());
        }

		if (FlxG.keys.justPressed.J)
		{
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}