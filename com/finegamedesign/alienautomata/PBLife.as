/*
download .pbk and read more on:
http://blog.yoz.sk/2010/03/game-of-life/

Adapted to decay after 4 turns.
*/

package com.finegamedesign.alienautomata
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.display.ShaderJob;
    
    /**
     * Minimal shader to update game of life.
     */
    public class PBDecay
    {
        public var bitmap:Bitmap = new Bitmap();
        public var bitmapData:BitmapData;
        
        [Embed(source="decay.pbj", mimeType="application/octet-stream")]
        public static var ShaderClass:Class;
        public var shader:Shader;
        
        public function PBDecay(width:int, height:int)
        {
            bitmapData = new BitmapData(width, height, true, 0);
            bitmap.bitmapData = bitmapData;
            
            shader = new Shader(new ShaderClass());
            shader.data.src.input = bitmapData;
            shader.data.width.value = [bitmapData.width];
            shader.data.height.value = [bitmapData.height];
        }
        
        public function update():void
        {
            new ShaderJob(shader, bitmapData, 4, 4).start(true);
        }
    }
}
