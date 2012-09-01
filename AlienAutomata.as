package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.PixelSnapping;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    [SWF(width="640", height="480", bgcolor="0xFF000000")]
    public class AlienAutomata extends Sprite
    {
        public static var universe:Bitmap;
        [Embed (source="PlayerBullet.png")]
        public static var PlayerBullet:Class;
        public static var playerBullet:Bitmap = new PlayerBullet();
        [Embed (source="EnemyArmada.png")]
        public static var EnemyArmada:Class;
        public static var enemyArmada:Bitmap = new EnemyArmada();

        public function AlienAutomata()
        {
            universe = new Bitmap(
                new BitmapData(640, 480, false, 0xFF000000),
                PixelSnapping.ALWAYS);
            universe.bitmapData.copyPixels(enemyArmada.bitmapData, 
                new Rectangle(0, 0, enemyArmada.width, enemyArmada.height),
                new Point(  (universe.width - enemyArmada.width) >> 1,
                            (universe.height - enemyArmada.height) >> 1)
            );
            addChild(universe);
        }
    }
}
