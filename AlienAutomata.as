package
{
    import flash.display.Bitmap;
    import flash.display.Sprite;

    [SWF(width="640", height="480", bgcolor="0xFF000000")]
    public class AlienAutomata extends Sprite
    {
        [Embed (source="PlayerBullet.png")]
        public static var PlayerBullet:Class;
        public static var playerBullet:Bitmap = new PlayerBullet();

        public function AlienAutomata()
        {
            addChild(playerBullet);
        }
    }
}
