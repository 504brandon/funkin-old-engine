package extra;

import handlers.MusicBeatState;
import options.OptionsConfigs;
import states.TitleState;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

class NotifyFnfFlash extends MusicBeatState {
    var textCool:FlxText;

    var soundExt:String = '.mp3';

    override public function create() {

        #if (!web)
		TitleState.soundExt = '.ogg';
		#end
        
        FlxG.sound.playMusic('assets/music/fpsplusmusicthatsabanger.ogg');

        var bg = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xff252525;
		add(bg);

        textCool = new FlxText(0, 0, 0, 'Hey fnf has flashing lights\nIf you dont like those, press ESCAPE; otherwise, press ENTER.');
        textCool.scale.set(3.1, 3.1);
        textCool.screenCenter();
        add(textCool);
    }

    override public function update(elapsed:Float) {
        coolAlphaThing();

        if (FlxG.keys.justPressed.ENTER) {
            OptionsConfigs.flashingLights = true;
            FlxG.save.data.flashingLights = true;

            endThisShit();
        }
        else if (FlxG.keys.justPressed.ESCAPE) {
            OptionsConfigs.flashingLights = false;
            FlxG.save.data.flashingLights = false;

            endThisShit();
        }
    }

    function coolAlphaThing() {
        FlxTween.tween(textCool, {alpha: 0}, 0.8, {onComplete: function(tween) {
            FlxTween.tween(textCool, {alpha: 1}, 0.8);
        }});
    }

    function endThisShit() {
        FlxG.save.flush();

        FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt, 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);

        FlxG.switchState(new TitleState());
    }
}