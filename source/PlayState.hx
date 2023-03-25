package;

import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import options.OptionsConfigs;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:String;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var cpuStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songMisses:Int = 0;
	var songAccuracy:Float = 0.00;

	public static var campaignScore:Int = 0;

	var scoreText:FlxText;
	var timeText:FlxText;

	var songPositionBar:Float;

	#if sys
	var script:HScriptPooger;
	#end

	var oldTime:String;

	var missRateings:Array<String> = ['FC!!!', 'PRETTY GOOD!', 'Good', 'Ehh', 'Clear'];

	public static var blueBalled:Int = 0;

	override public function create() {
		CoolUtil.loadMods();

		#if sys
		script = new HScriptPooger('assets/data/${SONG.song.toLowerCase()}/scripth');
		if (!script.isBlank && script.expr != null) {
			script.interp.scriptObject = this;
			script.interp.execute(script.expr);
		}
		script.callFunction('create');
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('Tutorial');

		Conductor.changeBPM(SONG.bpm);

		if (OptionsConfigs.downscroll)
			SONG.speed = -SONG.speed;

		switch (SONG.song.toLowerCase()) {
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", "But This time you wont get past me."];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
		}

		if (SONG.song.toLowerCase() == 'spookeez' || SONG.song.toLowerCase() == 'monster' || SONG.song.toLowerCase() == 'south') {
			halloweenLevel = true;

			FlxG.camera.zoom = 0.93;

			var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/halloween_bg.png', 'assets/images/halloween_bg.xml');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

			isHalloween = true;
		} else {
			FlxG.camera.zoom = 0.87;

			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		gf.antialiasing = true;
		add(gf);

		dad = new Character(100, 100, SONG.player2);
		add(dad);

		if (dad.isGfChar) {
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x += dad.camX, dad.getGraphicMidpoint().y += dad.camY);

		switch (SONG.player2) {
			case "monster":
				dad.y += 100;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (OptionsConfigs.downscroll)
			strumLine.y = 582.02;

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		startingSong = true;

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/healthBar.png');
		if (OptionsConfigs.downscroll)
			healthBarBG.y = FlxG.height * 0.082;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (!OptionsConfigs.fc)
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.hpColor, boyfriend.hpColor);
		// healthBar
		if (!OptionsConfigs.fc)
			add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreText = new FlxText(0, 680);
		scoreText.setFormat('assets/fonts/vcr.tff', 25, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK, false);
		if (OptionsConfigs.downscroll)
			scoreText.y = 95.2;
		scoreText.screenCenter(X);
		add(scoreText);

		timeBarBG = new FlxSprite(0, 30).loadGraphic('assets/images/healthBar.png');
		if (OptionsConfigs.downscroll)
			timeBarBG.y = 687.4;
		timeBarBG.scale.set(0.5, 0.8);
		timeBarBG.screenCenter(X);
		timeBarBG.scrollFactor.set();
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPositionBar', 0, 90000);
		timeBar.scale.set(0.5, 0.8);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, dad.hpColor);
		add(timeBar);

		timeText = new FlxText(0, -3);
		timeText.setFormat('assets/fonts/vcr.tff', 25, dad.hpColor, CENTER, OUTLINE, FlxColor.BLACK, false);
		if (OptionsConfigs.downscroll)
			timeText.y = 654.1;
		timeText.screenCenter(X);
		add(timeText);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreText.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeText.cameras = [camHUD];
		doof.cameras = [camHUD];

		if (isStoryMode && storyWeek == 0 || storyWeek == 1)
			add(doof);
		else
			startCountdown();

		super.create();

		camHUD.alpha = 0;

		FlxTween.tween(camHUD, {alpha: 1}, 1.3);

		#if sys
		script.callFunction('createPost');
		#end

		#if mobile
		var mcontrols = new MobileControlsCool();
		add(mcontrols);
		#end
	}

	var startTimer:FlxTimer;

	function startCountdown():Void {
		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		#if sys
		script.callFunction('startCountdown', [swagCounter]);
		#end

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			switch (swagCounter) {
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/ready.png');
					ready.scrollFactor.set();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/set.png');
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/go.png');
					go.scrollFactor.set();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		#if sys
		script.callFunction('startSong');
		#end

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		startingSong = false;
		FlxG.sound.playMusic("assets/songs/" + SONG.song.toLowerCase() + "/Inst" + TitleState.soundExt, 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		timeBar.setRange(0, FlxG.sound.music.length - 1000);
		timeBar.numDivisions = 1000;

		oldTime = '${FlxStringUtil.formatTime((FlxG.sound.music.length - Math.max(Conductor.songPosition, 0)) / 1000, false)}';
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded("assets/songs/" + SONG.song.toLowerCase() + "/Voices" + TitleState.soundExt);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3) {
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress) {
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else {}
			}
			daBeats += 1;
		}

		trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var arrTex = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
			babyArrow.frames = arrTex;
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			if (OptionsConfigs.middlescroll)
				babyArrow.x -= 230;

			babyArrow.scrollFactor.set();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.antialiasing = true;

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			switch (player) {
				case 0:
					cpuStrums.forEach(function(spr:FlxSprite) {
						spr.centerOffsets();
						if (OptionsConfigs.middlescroll)
							spr.visible = false;
					});

					babyArrow.x += 20;
					cpuStrums.add(babyArrow);

				case 1:
					playerStrums.add(babyArrow);
			}

			switch (Math.abs(i)) {
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
			}
		}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	override public function update(elapsed:Float) {
		#if sys
		script.callFunction('update', [elapsed]);
		#end

		super.update(elapsed);

		if (FlxG.keys.pressed.ONE) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit) {
					daNote.kill();
					daNote.destroy();
				}
			});

			FlxG.sound.music.time += 200;
		}

		songPositionBar = Conductor.songPosition + 10;

		notes.forEachAlive(function(daNote:Note) {
			cpuStrums.forEach(function(spr:FlxSprite) {
				if (spr.animation.curAnim.name == 'confirm' && spr.animation.finished) {
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		});

		if (boyfriend.animation.finished && boyfriend.specialAnim)
			boyfriend.playAnim('idle');

		if (health > 2)
			health = 2;

		if (OptionsConfigs.fc) {
			health = 1;
			if (songMisses > 0)
				health = -465;
		}

		var formatMissRateings:String;

		if (songMisses == 0)
			formatMissRateings = missRateings[0];
		else if (songMisses > 0 && songMisses < 5)
			formatMissRateings = missRateings[1];
		else if (songMisses > 4 && songMisses < 10)
			formatMissRateings = missRateings[2];
		else if (songMisses > 9 && songMisses < 20)
			formatMissRateings = missRateings[3];
		else
			formatMissRateings = missRateings[4];

		if (OptionsConfigs.botplay)
			scoreText.text = 'BOTPLAY';
		else if (OptionsConfigs.fc)
			scoreText.text = 'Score: $songScore - Accuracy: ${CoolUtil.truncateFloat(songAccuracy, 2)}% - Combo: $combo - Rateing: $formatMissRateings';
		else
			scoreText.text = 'Score: $songScore - Misses: $songMisses - Health: ${CoolUtil.truncateFloat(health, 2)}% - Accuracy: ${CoolUtil.truncateFloat(songAccuracy, 2)}% - Combo: $combo - Rateing: $formatMissRateings';

		scoreText.screenCenter(X);
		scoreText.updateHitbox();

		if (!startingSong)
			timeText.text = SONG.song
				+ '\nTime: ${FlxStringUtil.formatTime((FlxG.sound.music.length - Math.max(Conductor.songPosition, 0)) / 1000, false)} / $oldTime';
		else
			timeText.text = ${SONG.song} + '\n Time: 0:00 / 0:00';

		timeText.screenCenter(X);
		timeText.updateHitbox();

		// trace("SONG POS: " + Conductor.songPosition);
		// FlxG.sound.music.pitch = 2;

		if (FlxG.keys.justPressed.ENTER && startedCountdown) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			var pauseSubState = new PauseSubState(boyfriend.getPosition().x, boyfriend.getPosition().y);
			openSubState(pauseSubState);
			pauseSubState.camera = camHUD;
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (!OptionsConfigs.fc) {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

			if (!openfl.Assets.exists('assets/images/${iconP1.char}.xml')) {
				if (healthBar.percent < 20) {
					iconP1.animation.curAnim.curFrame = 1;
					if (iconP2.width > 300)
						iconP2.animation.curAnim.curFrame = 2;
				}
			}

			if (!openfl.Assets.exists('assets/images/${iconP2.char}.xml')) {
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else
					iconP2.animation.curAnim.curFrame = 0;
			}

			if (healthBar.percent < 20) {
				if (iconP2.width > 300)
					iconP2.animation.curAnim.curFrame = 2;

				iconP1.animation.curAnim.curFrame = 1;
			} else if (healthBar.percent > 80) {
				if (iconP1.width > 300)
					iconP1.animation.curAnim.curFrame = 2;

				iconP2.animation.curAnim.curFrame = 1;
			} else {
				iconP1.animation.curAnim.curFrame = 0;
				iconP2.animation.curAnim.curFrame = 0;
			}
		} else {
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;

			iconP1.x = 614;
			iconP2.x = 516;
		}

		if (FlxG.keys.justPressed.EIGHT) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			var charmenu = new CharSelect(boyfriend.getPosition().x, boyfriend.getPosition().y);
			openSubState(charmenu);
			charmenu.camera = camHUD;
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			Conductor.songPosition = FlxG.sound.music.time;

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
			if (curBeat % 4 == 0) {
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection || SONG.noBfCam) {
				camFollow.setPosition(dad.getMidpoint().x += dad.camX, dad.getMidpoint().y += dad.camY);
				vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial') {
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && SONG.noBfCam != true) {
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				if (SONG.song.toLowerCase() == 'tutorial') {
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		FlxG.watch.addQuick("beatShit", totalBeats);

		if (SONG.song.toLowerCase() == 'Fresh') {
			switch (totalBeats) {
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (health <= 0) {
			blueBalled++;

			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, SONG.player1));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altThing:String;

					if (daNote.altNote) {
						altThing = '-alt';
						trace('alt note real');
					} else
						altThing = '';

					switch (Math.abs(daNote.noteData)) {
						case 2:
							dad.playAnim('singUP' + altThing, true, true);
						case 3:
							dad.playAnim('singRIGHT' + altThing, true, true);
						case 1:
							dad.playAnim('singDOWN' + altThing, true, true);
						case 0:
							dad.playAnim('singLEFT' + altThing, true, true);
					}

					if (OptionsConfigs.dadGlow) {
						cpuStrums.forEach(function(spr:FlxSprite) {
							if (Math.abs(daNote.noteData) == spr.ID) {
								spr.animation.play('confirm');
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
						});
					}

					#if sys
					script.callFunction('dadNoteHit', [daNote]);
					#end

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height && daNote.canBeHit || OptionsConfigs.downscroll && daNote.y > strumLine.y + 80) {
					noteMiss(daNote.noteData);

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		keyShit();

		#if sys
		script.callFunction('updatePost', [elapsed]);
		#end
	}

	function endSong():Void {
		#if sys
		script.callFunction('endSong');
		#end

		trace('SONG DONE' + isStoryMode);

		if (isStoryMode) {
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[1] = true;

				if (!OptionsConfigs.botplay)
					Highscore.saveWeekScore(storyWeek, campaignScore);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				if (storyDifficulty != 'normal')
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-' + storyDifficulty,
						PlayState.storyPlaylist[0].toLowerCase());
				else
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());

				FlxG.switchState(new PlayState());
			}
		} else {
			if (!OptionsConfigs.botplay)
				Highscore.saveScore(SONG.song, songScore);

			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, note:Note):Void {
		#if sys
		script.callFunction('popUpScore', [strumtime]);
		#end

		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9) {
			daRating = 'shit';
			score = 50;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.75) {
			daRating = 'bad';
			score = 100;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.2) {
			daRating = 'good';
			score = 200;
		}

		if (daRating == 'sick') {
			var splash:NoteSplash = new NoteSplash(note.x, note.y, note.noteData);
			add(splash);
			splash.cameras = [camHUD];
		}

		songScore += score;

		rating.loadGraphic('assets/images/' + daRating + ".png");
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = true;
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic('assets/images/combo.png');
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.antialiasing = true;
		comboSpr.velocity.y -= 150;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.updateHitbox();
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		// add(comboSpr);
		add(rating);

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;

		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/num' + Std.int(i) + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0) {
				add(numScore);
				add(comboSpr);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;

		#if sys
		script.callFunction('popUpScore', [strumtime]);
		#end
	}

	private function keyShit():Void {
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic || OptionsConfigs.botplay && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && holdArray.contains(true) && generatedMusic
					&& !OptionsConfigs.botplay)
					goodNoteHit(daNote);

				if (OptionsConfigs.botplay && generatedMusic && daNote.canBeHit)
					goodNoteHit(daNote);
			});
		}

		// PRESSES, check for note hits
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic) {
			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData
								&& Math.abs(daNote.strumTime - coolNote.strumTime) < 10) { // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData
								&& daNote.strumTime < coolNote.strumTime) { // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes) {
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (possibleNotes.length > 0) {
				for (shit in 0...pressArray.length) { // if a direction is hit that shouldn't be
					if (pressArray[shit] && !directionList.contains(shit) && !OptionsConfigs.ghostTapping)
						noteMiss(shit);
				}
				for (coolNote in possibleNotes) {
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			} else {
				for (shit in 0...pressArray.length)
					if (pressArray[shit] && !OptionsConfigs.ghostTapping)
						noteMiss(shit);
			}
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm') {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void {
		#if sys
		script.callFunction('noteMiss');
		#end

		if (!boyfriend.stunned) {
			health -= 0.06;
			if (combo > 5) {
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			songMisses++;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				boyfriend.stunned = false;
			});

			switch (direction) {
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
			}
		}
	}

	function badNoteCheck() {
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			if (gamepad.anyJustPressed(["DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT", X])) {
				leftP = true;
			}

			if (gamepad.anyJustPressed(["DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT", B])) {
				rightP = true;
			}

			if (gamepad.anyJustPressed(['DPAD_UP', "LEFT_STICK_DIGITAL_UP", Y])) {
				upP = true;
			}

			if (gamepad.anyJustPressed(["DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN", A])) {
				downP = true;
			}
		}

		if (leftP)
			noteMiss(0);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		if (downP)
			noteMiss(1);
	}

	function noteCheck(keyP:Bool, note:Note):Void {
		if (keyP)
			goodNoteHit(note);
		else
			badNoteCheck();
	}

	function goodNoteHit(note:Note):Void {
		#if sys
		script.callFunction('bfNoteHit', [note]);
		#end

		if (!note.isSustainNote) {
			combo += 1;
			popUpScore(note.strumTime, note);
		}

		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		switch (note.noteData) {
			case 0:
				boyfriend.playAnim('singLEFT', true, true);
			case 1:
				boyfriend.playAnim('singDOWN', true, true);
			case 2:
				boyfriend.playAnim('singUP', true, true);
			case 3:
				boyfriend.playAnim('singRIGHT', true, true);
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if (Math.abs(note.noteData) == spr.ID) {
				spr.animation.play('confirm', true);
			}
		});

		note.wasGoodHit = true;
		vocals.volume = 1;

		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	function lightningStrikeShit():Void {
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);

		FlxG.camera.shake(0.02, 0.3);
	}

	override function stepHit() {
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20)) {
			resyncVocals();
		}

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit() {
		#if sys
		script.callFunction('beatHit');
		#end

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		if (OptionsConfigs.dbicon)
			daveandbambiiconbump();

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		super.beatHit();

		if (generatedMusic) {
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM) {
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			} else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (totalBeats % gfSpeed == 0) {
			gf.dance();
		}

		if (!boyfriend.specialAnim)
			boyfriend.playAnim('idle');

		if (totalBeats % 8 == 7 && SONG.song.toLowerCase() == 'bopeebo') {
			boyfriend.playAnim('hey', true, true);

			if (SONG.song.toLowerCase() == 'tutorial' && dad.curCharacter == 'gf') {
				dad.playAnim('cheer', true);
			}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}
	}

	function daveandbambiiconbump() {
		if (curBeat % gfSpeed == 0) {
			curBeat % (gfSpeed * 2) == 0 ? {
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);

				FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			} : {
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);

				FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			}

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
	}
}


	function resyncVocals():Void {
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}
}
