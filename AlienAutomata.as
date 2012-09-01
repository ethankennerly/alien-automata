package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    import uk.co.stdio.SimpleConway;

    [SWF(width="640", height="480", frameRate="30", backgroundColor="#000000")]
    public class AlienAutomata extends Sprite
    {
        public static var universe:BitmapData;
        [Embed (source="PlayerBullet.png")]
        public static var PlayerBullet:Class;
        public static var playerBullet:Bitmap = new PlayerBullet();
        [Embed (source="EnemyArmada.png")]
        public static var EnemyArmada:Class;
        public static var enemyArmada:Bitmap = new EnemyArmada();
        public static var aliveMask:uint = 0xFF000000;
        public static var deadColor:uint = 0x00000000;
        public static var shootInterval:int = 1000;
        public static var shootTime:int;
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
            SimpleConway.displayScale = 2;
            shootTime = 0;
            universe = new BitmapData(stage.stageWidth / SimpleConway.displayScale, 
                stage.stageHeight / SimpleConway.displayScale, 
                true, 0x00000000);
            SimpleConway.aliveColour = 0xFFFFFFFF;
            conway = new SimpleConway(stage, universe, SimpleConway.displayScale, addArmada);
            addChild(conway);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
        }

        public function addArmada(event:Event)
        {
            conway.state.lock();
            conway.state.copyPixels(enemyArmada.bitmapData, 
                new Rectangle(0, 0, enemyArmada.width, enemyArmada.height),
                new Point(  (universe.width - enemyArmada.width) >> 1,
                            (universe.height - enemyArmada.height) >> 2 ),
                null, null, true );
            conway.state.unlock();
        }

        public function onKeyDown(event:KeyboardEvent)
        {
            if (Keyboard.SPACE == event.keyCode) {
                var now = getTimer();
                if (shootTime <= now) {
                    playerShoot(conway.state, playerBullet);
                    shootTime = now + shootInterval;
                }
            }
        }

        public function playerShoot(state:BitmapData, playerBullet:Bitmap)
        {
            state.lock();
            state.copyPixels(playerBullet.bitmapData, 
                new Rectangle(0, 0, playerBullet.width, playerBullet.height),
                new Point(  (universe.width - playerBullet.width) >> 1,
                            (universe.height - playerBullet.height - 1)  ),
                null, null, true );
            state.unlock();
        }
    }
}
