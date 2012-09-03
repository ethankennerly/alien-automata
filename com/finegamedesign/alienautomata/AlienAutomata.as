package com.finegamedesign.alienautomata
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    import com.finegamedesign.alienautomata.PBDecay;
    import it.flashfuck.debugger.FPSMonitor;

    [SWF(width="483", height="480", frameRate="30", backgroundColor="#000000")]
    public class AlienAutomata extends Sprite
    {
        [Embed (source="PlayerBullet3.png")]
        public static var PlayerBullet:Class;
        public static var playerBullet:Bitmap = new PlayerBullet();
        [Embed (source="PlayerRight.png")]
        public static var Player:Class;
        public static var player:Bitmap = new Player();
        [Embed (source="EnemyArmada.png")]
        public static var EnemyArmada:Class;
        public static var enemyArmada:Bitmap = new EnemyArmada();
        public static var aliveMask:uint = 0xFF000000;
        public static var deadColor:uint = 0x00000000;
        public static var shootInterval:int = 30;
        public static var shootFrame:int;
        public static var frame:int;
        public static var displayScale:int = 3;
        public var leftThrust:int;
        public var rightThrust:int;
        public var shooting:Boolean;
        public var started:Boolean;
        public var life:PBDecay;
        public var armadaFrame:int;
        public static var armadaInterval:int = 450;
        public var universe:Sprite;
        public var tf:TextField;
        public var debug:Boolean;
        public var monitor:FPSMonitor;

        public function AlienAutomata()
        {
            if (null == stage) {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
            else {
                init(null);
            }
        }

        public function init(event:Event) 
        {
            shootFrame = 0;
            frame = 0;
            leftThrust = 0;
            rightThrust = 0;
            shooting = false;
            started = false;
            debug = false;
            armadaFrame = int.MAX_VALUE;
            universe = new Sprite();
            universe.scaleX = displayScale;
            universe.scaleY = displayScale;
            life = new PBDecay(stage.stageWidth / displayScale, 
                stage.stageHeight / displayScale);
            universe.addChild(life.bitmap);
            addChild(universe);
            addPlayer(life.bitmapData, player);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
            stage.addEventListener(MouseEvent.CLICK, start, false, 0, true);
            stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            tf = new TextField();
            tf.text = "Press LEFT or RIGHT: Move\nPress SPACE: Shoot" 
                + "\n\nClick anywhere to spawn:\nALIEN AUTOMATA";
            tf.width = 200;
            tf.height = 200;
            tf.x = stage.stageWidth >> 2;
            tf.y = stage.stageHeight >> 1;
            tf.textColor = 0xFFFFFFFF;
            addChild(tf);
            monitor = new FPSMonitor();
            addChild(monitor);
        }

        public function start(event:Event)
        {
            if (debug) {
                trace("start");
            }
            if (!started) {
                tf.visible = false;
                armadaFrame = frame;
                started = true;
            }
        }

        public function addArmada(state:BitmapData)
        {
            state.lock();
            state.copyPixels(enemyArmada.bitmapData, 
                new Rectangle(0, 0, enemyArmada.width, enemyArmada.height),
                new Point((state.width - enemyArmada.width) >> 1, 1),
                null, null, true );
            state.unlock();
        }

        public function update(e:Event):void 
        {
            updateState(life.bitmapData);
            updateState(life.bitmapData);
            if (debug != monitor.visible) {
                monitor.visible = debug;
            }
            if (armadaFrame <= frame) {
                addArmada(life.bitmapData);
                armadaFrame = frame + armadaInterval;
            }
        }

        private function updateState(state:BitmapData):void 
        {
            player.x = Math.max(1, Math.min(player.x + leftThrust + rightThrust, 
                                        state.width - playerBullet.width - 1));
            if (shooting) {
                if (shootFrame <= frame) {
                    playerShoot(state, playerBullet);
                    shootFrame = frame + shootInterval;
                }
            }
            life.update();
            frame ++;
        }

        private function onKeyDown(event:KeyboardEvent)
        {
            if (Keyboard.SPACE == event.keyCode) {
                shooting = true;
            }
            if (Keyboard.LEFT == event.keyCode) {
                leftThrust = -1;
            }
            if (Keyboard.RIGHT == event.keyCode) {
                rightThrust = 1;
            }
        }

        private function onKeyUp(event:KeyboardEvent)
        {
            if (Keyboard.SPACE == event.keyCode) {
                shooting = false;
            }
            if (Keyboard.LEFT == event.keyCode) {
                leftThrust = 0;
            }
            if (Keyboard.RIGHT == event.keyCode) {
                rightThrust = 0;
            }
            if (Keyboard.ESCAPE == event.keyCode) {
                debug = !debug;
            }
        }

        private function addPlayer(state:BitmapData, player:Bitmap)
        {
            state.lock();
            player.x = (life.bitmap.width - player.width >> 1);
            player.y = (life.bitmap.height - player.height - 2);
            state.copyPixels(player.bitmapData, 
                new Rectangle(0, 0, player.width, player.height),
                new Point(player.x, player.y),
                null, null, true );
            state.unlock();
            universe.addChild(player);
        }

        private function playerShoot(state:BitmapData, playerBullet:Bitmap)
        {
            state.lock();
            state.copyPixels(playerBullet.bitmapData, 
                new Rectangle(0, 0, playerBullet.width, playerBullet.height),
                new Point(((player.width - playerBullet.width) >> 1) + player.x, 
                    player.y - playerBullet.height - 4),
                null, null, true );
            state.unlock();
        }
    }
}
