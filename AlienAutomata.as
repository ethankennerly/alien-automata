package
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
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    import uk.co.stdio.SimpleConway;
    import it.flashfuck.debugger.FPSMonitor;

    [SWF(width="640", height="480", frameRate="30", backgroundColor="#000000")]
    public class AlienAutomata extends Sprite
    {
        public static var universe:BitmapData;
        [Embed (source="PlayerBulletWide.png")]
        public static var PlayerBullet:Class;
        public static var playerBullet:Bitmap = new PlayerBullet();
        [Embed (source="Player.png")]
        public static var Player:Class;
        public static var player:Bitmap = new Player();
        [Embed (source="EnemyArmada.png")]
        public static var EnemyArmada:Class;
        public static var enemyArmada:Bitmap = new EnemyArmada();
        public static var aliveMask:uint = 0xFF000000;
        public static var deadColor:uint = 0x00000000;
        public static var shootInterval:int = 1000;
        public static var shootTime:int;
        public static var displayScale:int = 2;
        public var leftThrust:int;
        public var rightThrust:int;
        public var shooting:Boolean;
        public var conway:SimpleConway;

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
            displayScale = 2;
            shootTime = 0;
            leftThrust = 0;
            rightThrust = 0;
            shooting = false;
            universe = new BitmapData(stage.stageWidth / displayScale, 
                stage.stageHeight / displayScale, 
                true, 0x00000000);
            SimpleConway.aliveColour = 0xFFFFFFFF;
            conway = new SimpleConway(universe);
            conway.scaleX = displayScale;
            conway.scaleY = displayScale;

            addChild(conway);
            player.x = (universe.width - playerBullet.width >> 1);
            player.y = (universe.height - player.height - 1);
            conway.addChild(player);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
            stage.addEventListener(MouseEvent.CLICK, addArmada);
            stage.addEventListener(Event.ENTER_FRAME, update);
            addChild(new FPSMonitor());
        }

        public function addArmada(event:Event)
        {
            conway.state.lock();
            conway.state.copyPixels(enemyArmada.bitmapData, 
                new Rectangle(0, 0, enemyArmada.width, enemyArmada.height),
                new Point((universe.width - enemyArmada.width) >> 1, 1),
                null, null, true );
            conway.state.unlock();
        }

        private function update(e:Event):void 
        {
            player.x = Math.max(1, Math.min(player.x + leftThrust + rightThrust, 
                                        universe.width - playerBullet.width - 1));
            if (shooting) {
                var now = getTimer();
                if (shootTime <= now) {
                    playerShoot(conway.state, playerBullet);
                    shootTime = now + shootInterval;
                }
            }
            conway.update();
        }

        public function onKeyDown(event:KeyboardEvent)
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

        public function onKeyUp(event:KeyboardEvent)
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
        }

        public function playerShoot(state:BitmapData, playerBullet:Bitmap)
        {
            state.lock();
            state.copyPixels(playerBullet.bitmapData, 
                new Rectangle(0, 0, playerBullet.width, playerBullet.height),
                new Point(player.x, player.y - playerBullet.height - 1),
                null, null, true );
            state.unlock();
        }
    }
}
