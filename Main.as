package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.text.TextField;
	import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;	
	import fl.controls.Button;
	import ds.gui.ToolTip;
	
	public class Main extends Sprite
	{
		// tooltipWidthTf is the input text where a fixed
		// width can given for the tooltip on button06. 
		private var tooltipWidthTf:TextField;
		// ttWidth is a default value for this example
		// for the tooltip of button06.
		private var ttWidth:Number = 115;
		
		private var buttonSprite_01:Sprite;
		private var buttonSprite_02:Sprite;
		private var buttonSprite_03:Sprite;
		private var buttonSprite_04:Sprite;
		private var buttonSprite_05:Sprite;		
		private var buttonSprite_06:Sprite;
		private var buttonSprite_07:Sprite;
		private var componentButton01:Button;
		
		public function Main()
		{
			buttonSprite_01 = createButton(25, 10, 100, 20, "button 1", "button01");
			buttonSprite_01.name = "button01";
			buttonSprite_01.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);			
			addChild(buttonSprite_01);
			
			buttonSprite_02 = createButton(135, 10, 100, 20, "Hover Me!", "button02");
			buttonSprite_02.name = "button02";
			buttonSprite_02.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);			
			addChild(buttonSprite_02);
			
			buttonSprite_03 = createButton(245, 10, 100, 20, "Button 3", "button03");
			buttonSprite_03.name = "button03";
			buttonSprite_03.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);			
			addChild(buttonSprite_03);
			
			buttonSprite_04 = createButton(355, 10, 100, 20, "MouseOver Me!", "button04");
			buttonSprite_04.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			addChild(buttonSprite_04);

			buttonSprite_05 = createButton(200, 165, 100, 20, "Bottom button", "button05");
			buttonSprite_05.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			addChild(buttonSprite_05);
			
			// Code for button and textinput added for fixed width example.
			var inputFormat:TextFormat = new TextFormat("Arial", 11, 0x000000);
			var lbl:TextField = new TextField();
			lbl.defaultTextFormat = inputFormat;
			lbl.multiline = false;
			lbl.autoSize = TextFieldAutoSize.RIGHT;
			lbl.text = "Change fixed width:";
			lbl.x = 150 - lbl.width;
			lbl.y = 60;
			addChild(lbl);
			
			tooltipWidthTf = new TextField();
			tooltipWidthTf.type = TextFieldType.INPUT;
			tooltipWidthTf.name = "sizeInput";
			tooltipWidthTf.border = true;
			tooltipWidthTf.borderColor = 0x78ACFF;
			tooltipWidthTf.width = 35;
			tooltipWidthTf.height = 18;
			tooltipWidthTf.maxChars = 3;
			tooltipWidthTf.restrict = "0-9";
			tooltipWidthTf.defaultTextFormat = inputFormat;
			tooltipWidthTf.x = 155;
			tooltipWidthTf.y = 60;
			tooltipWidthTf.text = String(ttWidth);
			tooltipWidthTf.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			tooltipWidthTf.addEventListener(Event.CHANGE, onChangeTooltipWidth);
			addChild(tooltipWidthTf);
			
			buttonSprite_06 = createButton(200, 60, 100, 20, "Fixed width tooltip", "button06");
			buttonSprite_06.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			addChild(buttonSprite_06);

			buttonSprite_07 = createButton(25, 110, 100, 20, "Custom Timers", "button07");
			buttonSprite_07.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			addChild(buttonSprite_07);

			componentButton01 = new Button();
			componentButton01.name = "componentButton01";
			componentButton01.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			componentButton01.x = 200;
			componentButton01.y = 110;
			addChild(componentButton01);
		}
		
		// This is triggered when the text change in the textinput,
		// which is used to set a fixed tooltip width.
		private function onChangeTooltipWidth(e:Event):void
		{
			ttWidth = e.currentTarget.text;
		}
		
		private function onButtonOver(e:Event):void
		{
			switch(e.currentTarget.name)
			{
				case "sizeInput":
					ToolTip.tooltipLabel = "Enter a width for the <b>Fixed Width tooltip</b> button";
					ToolTip.followMouse = true;
					break;
					
				case "button01":
					ToolTip.tooltipLabel = "This is a default style tooltip";
					break;
				
				case "button02":
					ToolTip.tooltipLabel = "This is a tooltip with rounded corners that follow the mouse";
					ToolTip.roundingBox = 12;
					ToolTip.followMouse = true;
					break;
					
				case "button03":
					ToolTip.tooltipLabel = "Tooltip will be removed when the mouse is moved";
					ToolTip.colors = [0xFFFFAA, 0xFFFF00];	
					ToolTip.transparency = [0x55, 0xDD];
					ToolTip.hideOnMouseMove = true;
					break;
					
				case "button04":
					ToolTip.tooltipLabel = "This is a tooltip with longer text to<br>demonstrate multiline text in tooltips";
					break;
					
				case "button05":
					ToolTip.tooltipLabel = "This is a tooltip that does <u>not</u> fit <i>under</i> the mouse";
					break;
					
				case "button06":
					ToolTip.tooltipLabel = "This is a tooltip that has a fixed width. The height is calculated automaticly";
					ToolTip.tooltipWidth = Number(ttWidth);
					break;
					
				case "button07":
					ToolTip.tooltipLabel = "This tooltip has a custom delay and fade time";
					ToolTip.fadeTime = 2;
					ToolTip.delayTime = 1000;
					break;


				case "componentButton01":
					ToolTip.tooltipLabel = "Tooltips that work even for components!";
					ToolTip.autoHideTime = 0;
					break;
			}
			ToolTip.show(e.currentTarget);
		}
		
		private function createButton(x:int, y:int, w:int, h:int, buttonText:String = "", buttonName:String = null):Sprite
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(1, 0x78ACFF, 1);
			sprite.graphics.beginFill(0xEAF2FF);
			sprite.graphics.drawRect(0, 0, w, h);
			sprite.graphics.endFill();
			
			var btnFormat:TextFormat = new TextFormat("Arial", 11, 0x000000);
			
			var btnLabel:TextField = new TextField();
			btnLabel.defaultTextFormat = btnFormat;
			btnLabel.autoSize = TextFieldAutoSize.CENTER;
			btnLabel.text = buttonText;
			btnLabel.y = 1;
			
			sprite.addChild(btnLabel);
			
			if (buttonName)
			{
				sprite.name = buttonName;
			}
			sprite.x = x;
			sprite.y = y;
			sprite.buttonMode = true;
			sprite.mouseChildren = false;
			return sprite;
		}
	}
}