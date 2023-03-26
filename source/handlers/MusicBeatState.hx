package handlers;

#if !web
import states.TitleState;
#end
import extra.PlayerSettings;
import handlers.Controls;
import handlers.Conductor;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState {
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		#if !web
		TitleState.soundExt = '.ogg';
		#end

		super.create();
	}

	override function update(elapsed:Float) {
		everyStep();

		updateCurStep();
		curBeat = Math.round(curStep / 4);

		super.update(elapsed);

		#if sys
		FlxG.drawFramerate = options.OptionsConfigs.fps;
		#end
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void {
		if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset) {
			if (Conductor.songPosition > lastStep + Conductor.stepCrochet) {
				stepHit();
			}
		}
	}

	private function updateCurStep():Void {
		curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		totalSteps += 1;
		lastStep += Conductor.stepCrochet;

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {
		lastBeat += Conductor.crochet;
		totalBeats += 1;
	}
}
