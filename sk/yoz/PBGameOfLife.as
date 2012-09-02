/*
download .pbk and read more on:
http://blog.yoz.sk/2010/03/game-of-life/
*/

package sk.yoz
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.display.ShaderJob;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    // import net.hires.debug.Stats;
    import it.flashfuck.debugger.FPSMonitor;
    
    [SWF(width="404", height="400", frameRate="30", backgroundColor="#333333")]
    public class PBGameOfLife extends Sprite
    {
        private static const ZERO_POINT:Point = new Point();
        private static const INITIAL_POINTS:Array = [63,99,101,127,128,135,136,
                149,150,164,168,173,174,187,188,191,192,201,207,211,212,229,230,
                239,243,245,246,251,253,277,283,291,316,320,355,356];
        
        private var bitmap:Bitmap = new Bitmap();
        private var bitmapData:BitmapData;
        
        [Embed(source="gameoflife.pbj", mimeType="application/octet-stream")]
        private static var ShaderClass:Class;
        private var shader:Shader;
        private var pxPerSecond:uint = 0;
        
        private var tf:TextField;
        
        public function PBGameOfLife()
        {
            trace("PBGameOfLife");
            if (null == stage) {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
            else {
                init(null);
            }
        }

        private function init(event:Event):void
        {
            trace("init");
            createBitmap();
            addChild(bitmap);
            
            shader = new Shader(new ShaderClass());
            shader.data.src.input = bitmapData;
            shader.data.width.value = [bitmapData.width];
            shader.data.height.value = [bitmapData.height];
            
            tf = new TextField();
            tf.y = stage.stageHeight - 32;
            tf.width = 400;
            tf.selectable = false;
            tf.textColor = 0xffffffff;
            tf.text = "init";
            addChild(tf);

            // var stats:Stats = new Stats();
            var stats:FPSMonitor = new FPSMonitor();
            stats.y = stage.stageHeight - stats.height - 32;
            addChild(stats);
            
            var timer:Timer = new Timer(1000);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        private function createBitmap():void
        {
            var w:uint = 38;
            var h:uint = 38;
            var X:uint, Y:uint;
            
            bitmapData = new BitmapData(
                stage.stageWidth, stage.stageHeight, true, 0);
            bitmapData.lock();
            for(var i:uint = 0; i < w*h; i++)
            {
                X = i%w;
                Y = int(i/w);
                if(INITIAL_POINTS.indexOf(i) > -1)
                    bitmapData.setPixel32(X, Y, 0xffffffff);
            }
            bitmapData.unlock();
            bitmap.bitmapData = bitmapData;
        }
        
        private function timerHandler(event:TimerEvent):void
        {
            tf.text = pxPerSecond.toString() + " pixels per second";
            pxPerSecond = 0;
        }
        
        private function enterFrame(event:Event):void
        {
            pxPerSecond += bitmapData.width * bitmapData.height;
            new ShaderJob(shader, bitmapData, 4, 4).start(true);
        }
    }
}
