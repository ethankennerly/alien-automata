/*
Conway's Game of Life using a convolution filter and a palette map.
 
In the game of life, cells live or die depending on how many live neighbours
they have. In this version, pixels represent cells and the eight pixels around
every pixel are considered to be the cell's neighbours.
 
A convolution filter takes the job of adding up each pixel's number of live
neighbours and setting the pixel's colour to a value that represents that
value. After this, the pixels are palette mapped so the correct pixels are
kept alive. The process is repeated to animate the Game of Life.
 
The four rules controlling the system are:
1. Fewer than two live neighbours and the cell dies (Loneliness)
2. Greater than three live neighbours and the cell dies (Overcrowding)
3. Exactly three live neighbours and the cell comes to life (Creation)
4. Exactly two live neighbours and the cell stays how it is (Stasis)
 
Alistair Macdonald
http://www.stdio.co.uk/blog

Modified to be reused.
*/
 
package uk.co.stdio {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ConvolutionFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import it.flashfuck.debugger.FPSMonitor;
    
    public class SimpleConway extends Sprite {
        
        public static var aliveColour:uint = 0xFFFF0000;
        public static const DEAD_COLOUR:uint = 0x00000000;
        public static const DISPLAY_SCALE:Number = 2;
        // Bitmap that is shown in the display list.
        public var displayContainer:Bitmap;
        // Bitmap that is used to hold the state of the pixels.
        public var state:BitmapData;
        // Filter used to determine how many 
        // alive neighbours a pixel has.
        private var countNeighbours:ConvolutionFilter;
        // Palette map array used to apply the rules of creation, destruction
        // and stasis on the state bitmap after countNeighbours has been applied.
        private var applyConwayRules:Array;
        // Pre-instantated objects do avoid object creation 
        // during the main event loop.
        private var point:Point = new Point();
        private var rect:Rectangle = new Rectangle();
 
        public function SimpleConway(stage:Stage, state:BitmapData, DISPLAY_SCALE:int,
                onClickCallback:Function) {
            this.state = state;
            rect.width = state.width;
            rect.height = state.height;
            
            displayContainer = new Bitmap(state);
            displayContainer.scaleX = DISPLAY_SCALE;
            displayContainer.scaleY = DISPLAY_SCALE;
            addChild(displayContainer);
            addChild(new FPSMonitor());
            
            /* Convolution filter which counts the number of alive neighbours a pixel has. Note the value of 0.5 applied to the source pixel. This allows the filter to carry the state of the state of the source pixel through so the stasis rule can be applied. */
            countNeighbours = new ConvolutionFilter(3, 3, [1, 1, 1, 1, 0.5, 1, 1, 1, 1], 8, 0, false);
            // Palette map, used after applying countNeighbours to convert from 
            // the pixels' values to their alive or dead colours.
            applyConwayRules = new Array(256);
            // Set values which must be counted as alive. All other values
            // will be counted as dead.
            // source pixel is alive and has 2 alive neighbours (stasis)
            applyConwayRules[0x4D] = aliveColour;
            // source pixel is alive and has 3 alive neighbours (creation)
            applyConwayRules[0x6E] = aliveColour;
            // source pixel is dead and has 3 alive neighbours (creation)
            applyConwayRules[0x5E] = aliveColour;
            
            stage.addEventListener(MouseEvent.CLICK, onClickCallback);
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    
        private function onClick(e:MouseEvent):void {
            // Draw the "acorn" shape at the mouse position. When scaled,
            // displayContainer can return sub-pixel mouse positions so
            // the value is rounded.
            var x:int = Math.round(displayContainer.mouseX);
            var y:int = Math.round(displayContainer.mouseY);
            state.lock();
            state.setPixel32(x, y, aliveColour);
            state.setPixel32(x-2, y-1, aliveColour);
            state.setPixel32(x-3, y+1, aliveColour);
            state.setPixel32(x-2, y+1, aliveColour);
            state.setPixel32(x+1, y+1, aliveColour);
            state.setPixel32(x+2, y+1, aliveColour);
            state.setPixel32(x+3, y+1, aliveColour);
            state.unlock();
        }
        
        private function onEnterFrame(e:Event):void {
            state.lock();
            state.applyFilter(state, rect, point, countNeighbours);
            state.paletteMap(state, rect, point, applyConwayRules, applyConwayRules, applyConwayRules, applyConwayRules);
            state.unlock();
        }
    }
}

