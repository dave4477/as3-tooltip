package ds.gui
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import flash.system.System;
	
	/**
	 * The ToolTip class defines static functions to generate a generic tooltip. 
	 * The tooltip is always added to the stage itself, and is typically called
	 * in the mouseover's event listener function for a displayobject. 
 	 *
	 * @author	Dave Bleeker, Detailed Simplicity
	 * @version	3.0	
	 * @changes	
	 * ---------------------------------------------------------------------------
	 * 10 April 2010: Added the property autoHideTime and tooltiptimerHide.
	 * 02 June  2010: Added a garbage collector and tween cleanup to save system resources.
	 * ---------------------------------------------------------------------------
	 */
	public class ToolTip extends Sprite
	{
		// tooltiptimer is for the tooltip delay before shown.
		private static var tweens:Array = new Array();
		private static var tooltiptimer:Timer;
		private static var tooltiptimerHide:Timer;
		private static var tooltipclip:Sprite;
		private static var parentobject:Object;
		private static var rootobject:Object;		
		private static var isOverObject:Boolean;
		
		// Setter / getter variables. 
		private static var _defaultColors:Array = [0xFFFFFF, 0xBABCCC];
		private static var _defaultAlphas:Array = [0.9, 0.8];
		private static var _tooltiptext:String;		
		private static var _resetStyles:Boolean = true;
		private static var _autoHideTime:int = 0;
		private static var _hideonmove:Boolean = false;
		private static var _roundingBox:Number = 0;
		private static var _followMouse:Boolean = false;
		private static var _colors:Array = _defaultColors; // [0xFFFFFF, 0xBABCCC];
		private static var _transparency:Array = _defaultAlphas; ///[0.9, 0.8];
		private static var _fadeTime:Number = 0.7;
		private static var _delayTime:int = 350;
		private static var _tooltipWidth:*;
		
		/**
		 * Class constructor.
		 */
		public function ToolTip()
		{
		}
		
		/**
		 * The function show triggers the tooltip to display after registering the mouseout
		 * and mousedown listeners for the object that the mouse is currently over. 
		 *
		 * @param	obj		The object that belongs to this tooltip.
		 */
		public static function show(obj:Object):void
		{
			isOverObject = true;
			
			// Store the object that triggered the tooltip in parentobject.
			parentobject = obj;	
			// Store the object that triggered the tooltip in rootobject to find its root.
			rootobject = obj;	
			
			// Find the current targets root to add the tooltip to (main timeline).
			while(rootobject.parent)
			{
				rootobject = rootobject.parent;
			}
			
			// Add event listeners to the target that triggered the tooltip.
			parentobject.addEventListener(MouseEvent.ROLL_OUT, onOut);
			parentobject.addEventListener(MouseEvent.MOUSE_DOWN, onOut);
			
			// Start the timer that adds the tooltip to stage.
			if (tooltiptimer) 
			{
				tooltiptimer.reset();
				tooltiptimer.delay = delayTime;				
				tooltiptimer.start();
			}
			else
			{
				tooltiptimer = new Timer(delayTime, 1);
				tooltiptimer.addEventListener(TimerEvent.TIMER, addToolTip);
				tooltiptimer.start();
			}
		}
		
		/*
		 * Adds the tooltip to stage, if the mouse is still over the object
		 * that has called the tooltip. This function is automaticly called
		 * by the tooltiptimer and should not be called manually.
		 *
		 * @param	e	TimerEvent
		 */
		public static function addToolTip(e:TimerEvent):void
		{
			if (isOverObject)
			{
				// Set a text format for the tooltip.
				var tooltipformat:TextFormat = new TextFormat();
				tooltipformat.font = "Tahoma";
				tooltipformat.size = 11;
				tooltipformat.color = 0x444444;
				
				// Create a textfield for the tooltip.
				var tooltiptextfield:TextField = new TextField();
				tooltiptextfield.antiAliasType = AntiAliasType.ADVANCED;
				tooltiptextfield.gridFitType = GridFitType.SUBPIXEL;
				tooltiptextfield.thickness = 50;
				tooltiptextfield.sharpness = 0;
				tooltiptextfield.defaultTextFormat = tooltipformat;
				
				var pattern:RegExp = /<br>/gi;
				var isMultiLine:Boolean = pattern.test(tooltipLabel);
				
				// Find out if the tooltip fits on stage, and apply a multiline 
				// text if there the width was given for a tooltiptext.
				if (tooltiptextfield.width > parentobject.stage.stageWidth)
				{
					tooltiptextfield.width = parentobject.stage.stageWidth - 80;
					tooltiptextfield.multiline = true;
					tooltiptextfield.wordWrap = true;
				}				
				else if (isMultiLine)
				{
					tooltiptextfield.multiline = true;
					tooltiptextfield.wordWrap = false;					
				}
				tooltiptextfield.autoSize = TextFieldAutoSize.LEFT;
				tooltiptextfield.htmlText = tooltipLabel;
				
				// Adjust the width of the tooltip if tooltipWidth was given, and calculate it's height.				
				if (!isNaN(tooltipWidth))
				{
					tooltiptextfield.multiline = true;
					tooltiptextfield.wordWrap = true;
					tooltiptextfield.width = tooltipWidth;
					
					var nl:int = tooltiptextfield.numLines;
					var ttHeight:Number = 0;
					
					for (var i:int = 0; i < nl; i++)
					{
						var metrics:TextLineMetrics = tooltiptextfield.getLineMetrics(i);
						ttHeight += metrics.descent;
						ttHeight += metrics.height;	
					}
					tooltiptextfield.height = ttHeight;
				}
				
				// Apply some fancy gradient fill to fill the tooltip with.
				var rad:Number = 90 * (Math.PI / 180);
				
				var fillType:String = GradientType.LINEAR;
				var colors:Array = colors; 
				var alphas:Array = transparency;
				var ratios:Array = [0, 255]; 
				var matr:Matrix = new Matrix();
				matr.createGradientBox(tooltiptextfield.width +8, tooltiptextfield.height, rad, 0, 5);
				var spreadMethod:String = SpreadMethod.PAD;				

				// Create the actual tooltip Sprite.
				tooltipclip = new Sprite();
				tooltipclip.name = "tooltip";
				tooltipclip.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
				tooltipclip.graphics.lineStyle(1, 0x444444, 1, true);
				tooltipclip.graphics.drawRoundRect(0, 0, tooltiptextfield.width +10, tooltiptextfield.height +2, roundingBox, roundingBox);
				tooltipclip.graphics.endFill();
				tooltipclip.addChild(tooltiptextfield);
				tooltiptextfield.x = 4;
				tooltiptextfield.y = 1;
				tooltipclip.filters = [new DropShadowFilter(4, 45, 0x000000, 0.4, 3, 3, 1, 1)];
				tooltipclip.alpha = 0;
				
				// Check if a tooltip exsist and remove it, to prevent tooltips that does not hide.
				try
				{
					rootobject.removeChild(rootobject.getChildByName(tooltipclip.name));
				}
				catch(err:Error)
				{
				}
				// Add the tooltip to stage.
				rootobject.addChild(tooltipclip);
					
				// Check and recalculate the tooltips position and check if it falls of stage.		
				var tooltipX:Number = ((rootobject.mouseX + 12 + tooltipclip.width) > rootobject.stage.stageWidth) ? rootobject.stage.stageWidth - (tooltipclip.width + 8) : rootobject.mouseX + 12;
				var tooltipY:Number = ((rootobject.mouseY + 20 + tooltipclip.height) > rootobject.stage.stageHeight) ? rootobject.mouseY - (tooltipclip.height) : rootobject.mouseY + 20;
				
				tooltipclip.x = tooltipX; 
				tooltipclip.y = tooltipY; 
				
				// Fade the tooltip in.
				for (var t:int = 0; t < tweens.length; t++)
				{
					tweens[t] = null;	
				}
				tweens = [];
				
				System.gc();
				
				tweens.push(new Tween(tooltipclip, "alpha", Strong.easeInOut, 0, 1, fadeTime, true));
				
				// Apply listeners for the preferences on mousemove and/or click.
				if (hideOnMouseMove &&! followMouse)
				{
					parentobject.addEventListener(MouseEvent.MOUSE_MOVE, hide);
				}
				else if (followMouse)
				{
					parentobject.addEventListener(MouseEvent.MOUSE_MOVE, follow);
				}
				
				if (autoHideTime > 0)
				{
					tooltiptimerHide = new Timer(autoHideTime, 1);
					tooltiptimerHide.addEventListener(TimerEvent.TIMER, autoHideToolTip);
					tooltiptimerHide.start();					
				}
			}
		}
		
		private static function autoHideToolTip(e:TimerEvent):void
		{
			onOut(null);
		}
		
		/**
		 * the function onOut is called when the object that 
		 * the tooltip belongs to received a mouseout. Reset
		 * the tooltipstyles parameter in case another object
		 * that we want to use the tooltip for can use different 
		 * style settings.
		 */
		private static function onOut(e:Event = null):void
		{
			isOverObject = false;
			
			for (var i:int = 0; i < tweens.length; i++)
			{
				tweens[i] = null;
			}
			tweens = [];

			if (autoHideTime > 0)
			{
				tooltiptimerHide.reset();
				tooltiptimerHide.stop();
			}
			
			if (resetStyles)
			{
				roundingBox = 0;
				colors = _defaultColors;
				transparency = _defaultAlphas;
				hideOnMouseMove = false;
				autoHideTime = 0;
				followMouse = false;
				tooltipWidth = undefined;
				fadeTime = 1;
				delayTime = 350;
			}
			if (tooltipclip) hide(null);
			
			System.gc();
		}
		
		/**
		 * the hide function hides te tooltip by removing it from stage.
		 *
		 * @param	e	the event that causes the tooltip to hide or null.
		 */
		public static function hide(e:Event = null):void
		{
			if (rootobject.contains(tooltipclip))
			{
				rootobject.removeChild(tooltipclip);
			}
		}
		
		/**
		 * the follow function is only called when followMouse = true.
		 * Causes the tooltip to follow the mouse when the mouse is over 
		 * an object that the tooltip belongs to.
		 *
		 * @param	e	MouseEvent MOUSE_MOVE. 
		 */
		private static function follow(e:MouseEvent):void
		{
			var targ:* = e.target;
			
			var mouseCoords:Point = new Point(targ.mouseX, targ.mouseY);
			mouseCoords = targ.localToGlobal(mouseCoords);
			
			// Check and recalculate the tooltips position if it falls of stage.		
			var tooltipX:Number = ((rootobject.mouseX + 12 + tooltipclip.width) > rootobject.stage.stageWidth) ? rootobject.stage.stageWidth - (tooltipclip.width + 8) : rootobject.mouseX + 12;
			var tooltipY:Number = ((rootobject.mouseY + 20 + tooltipclip.height) > rootobject.stage.stageHeight) ? rootobject.mouseY - (tooltipclip.height) : rootobject.mouseY + 20;
			
			tooltipclip.x = tooltipX; 
			tooltipclip.y = tooltipY; 			
		}

		/**
	   	 * Registers the text to display in a tool tip. The text 
	   	 * displays when the cursor lingers over the component.
	   	 *
	   	 * @param value  the string to display.
	   	 */
		public static function set tooltipLabel(value:String):void
		{
			_tooltiptext = value;
		}
		
		/**
		 * Returns the text that was assigned to the tooltip.
		 *
		 * @return String  the text for this tooltip.
		 */
		public static function get tooltipLabel():String
		{
			return _tooltiptext;
		}		
				
		/**
		 * Setter hideOnMouseMove. This causes the tooltip to hide as soon as
		 * we start moving the mouse, despite if it is over the object that the
		 * tooltip belongs to or not.
		 *
		 * @param	value	a number that represents the width for the tooltip.
		 */		
		public static function set hideOnMouseMove(value:Boolean):void
		{
			_hideonmove = value;
		}
		
		/**
		 * Getter hideOnMouseMove. 
		 *
		 * @return	Boolean		a boolean value that tells to hide the tooltip or not.
		 */
		public static function get hideOnMouseMove():Boolean
		{
			return _hideonmove;
		}

		/**
		 * Setter that tells us if the tooltip needs to follow the mouse.
		 *
		 * @param	value		a boolean that tells if the tooltip should 
		 *						follow the mouse or not. If true it follows the mouse.
		 */		
		public static function set followMouse(value:Boolean):void
		{
			_followMouse = value;
		}
		/**
		 * Getter that tells us if the tooltip needs to follow the mouse.
		 *
		 * @return	Boolean		a boolean. If true it follows the mouse.
		 */
		public static function get followMouse():Boolean
		{
			return _followMouse;
		}
		
		/**
		 * Setter for the colors used to fill the tooltip with.
		 *
		 * @param	value	an array of colors. For example [0xFFFFFF, 0xFF0000].
		 */
		public static function set colors(value:Array):void
		{
			_colors = value;
		}
		/**
		 * Getter for the colors that the tooltip is being filled with.
		 *
		 * @return	Array	an Array with the colors that are used to fill the tooltip.
		 */
		public static function get colors():Array
		{
			return _colors;
		}
		
		/**
		 * Setter for the tooltip's fill transparency.
		 *
		 * @param	value	an array with the alphas used to fill the tooltip with.
		 */
		public static function set transparency(value:Array):void
		{
			_transparency = value;
		}
		
		/**
		 * Getter for the transparency.
		 *
		 * @return	Array	an array of the transparencies for the tooltip fill.
		 */
		public static function get transparency():Array
		{
			return _transparency;
		}
		
		/**
		 * Setter for the tooltip corner radius. This is the rounding for
		 * the corners of the tooltip. If 0 the tooltip will be square.
		 *
		 * @param	value	a number of the radius for the tooltips corner.
		 */
		public static function set roundingBox(value:Number):void
		{
			_roundingBox = value;
		}
		/**
		 * Getter for the corner radius of the tooltip.
		 *
		 * @return	Number	a number representing the corner radius rounding
		 *					for the tooltip.
		 */
		public static function get roundingBox():Number
		{
			return _roundingBox;
		}

		/**
		 * Setter that tells us to reset the styles for the tooltip or not.
		 *
		 * @param	value	a boolean that will reset all styles if true.
		 */
		public static function set resetStyles(value:Boolean):void
		{
			_resetStyles = value;
		}
		/**
		 * Getter for the resetStyles.
		 *
		 * @return	Boolean		a boolean that tells the tooltip whether or not to reset it's styles. 
		 */
		public static function get resetStyles():Boolean
		{
			return _resetStyles;
		}
		
		/**
		 * Set a fixed width for the tooltip. The height will be calculated when the tooltip is created.
		 * 
		 * @param	value	A number or integer that tells the width for the tooltip.
		 */
		public static function set tooltipWidth(value:Number):void
		{
			_tooltipWidth = value;
		}
		
		/**
		 * Getter that returns the tooltip's width if set. 
		 *
		 * @return	Number		a number or integer that represents a fixed width of the tooltip. 
		 */
		public static function get tooltipWidth():Number
		{
			return _tooltipWidth;
		}
		
		/**
		 * Set a time on which the tooltip automaticly hides.
		 * 
		 * @param	value	The amount of time in ms that it takes to complete the 
		 * 					annimation to fade in.
		 */
		public static function set fadeTime(value:Number):void
		{
			_fadeTime = value;
		}
		/**
		 * Gets the fadeTime property, representing the time of the fade-in annimation.
		 *
		 */
		public static function get fadeTime():Number
		{
			return _fadeTime;
		}
		
		/**
		 * Set the delay time before the tooltip is being shown.
		 * @param	value	An integer value that represents the delay time in ms before the tooltip is shown.
		 */
		public static function set delayTime(value:int):void
		{
			_delayTime = value;
		}
		/**
		 * Returns the delay time that represents the delay time of the tooltip in ms.
		 */
		public static function get delayTime():int
		{
			return _delayTime;
		}
		/**
		 * Set a time on which the tooltip automaticly hides.
		 * 
		 * @param	value	The amount of time in ms that the tooltip must be shown, 
		 * 					after the given amount of time the tooltip will hide.
		 */
		public static function set autoHideTime(value:int):void
		{
			_autoHideTime = value;
		}
		
		/**
		 * Getter that returns the time in ms after the tooltip must hide. 
		 *
		 * @return	Integer		a integer that represents the time in ms that the tooltip should be shown. 
		 */
		public static function get autoHideTime():int
		{
			return _autoHideTime;
		}
		
		/**
		 * Getter for the the tooltip Sprite object for access outside this class.
		 *
		 * @return	Sprite	a sprite that is the tooltip as it is put on stage.
		 */
		public static function get tooltipClip():Sprite
		{
			return tooltipclip;
		}
	}
}