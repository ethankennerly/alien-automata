package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
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
            universe = new BitmapData(320, 240, true, 0x00000000);
            SimpleConway.aliveColour = 0xFFFFFFFF;
            conway = new SimpleConway(stage, universe, 2, addArmada);
            addChild(conway);
        }

        public function addArmada(event:Event)
        {
            conway.state.lock();
            conway.state.copyPixels(enemyArmada.bitmapData, 
                new Rectangle(0, 0, enemyArmada.width, enemyArmada.height),
                new Point(  (universe.width - enemyArmada.width) >> 1,
                            (universe.height - enemyArmada.height) >> 1 ),
                null, null, true );
            conway.state.unlock();
        }
    }
}
