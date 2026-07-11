package willyhorizont.runtime {
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldType;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import Main;
    [SWF(backgroundColor="0x121212")]
    public class Terminal extends Sprite {
        private var bg:Sprite;
        private var f:TextFormat;
        public static var t:TextField;
        private var N:String = String(CONFIG::USER_NAME);
        private var PC:String = String(CONFIG::USER_COMPUTER);
        private var D:String = String(CONFIG::USER_PWD);
        private var C1:String = String(CONFIG::COMMAND_1);
        private var C2:String = String(CONFIG::COMMAND_2);
        private var C3:String = String(CONFIG::COMMAND_3);
        private var tP:String = N + "@" + PC + ":" + D + "$ ";
        public static var rTx:String = "";
        public function Terminal() {
            if (stage) {
                init();
            } else {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }
        private function init(e:Event = null):void {
            if (e) {
                removeEventListener(Event.ADDED_TO_STAGE, init);
            }
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            bg = new Sprite();
            addChild(bg);
            f = new TextFormat();
            f.font = "_typewriter";
            f.color = 0xEEEEEE;
            f.size = 14;
            f.leading = 2;
            t = new TextField();
            t.defaultTextFormat = f;
            t.multiline = true;
            t.wordWrap = false;
            t.type = TextFieldType.DYNAMIC;
            t.selectable = true;
            addChild(t);
            rTx = tP + C1 + "\n" + C2 + "\n" + C3 + "\n";
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, hMw);
            stage.addEventListener(Event.RESIZE, re);
            Main.run();
            re();
        }
        private function re(e:Event = null):void {
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight;
            bg.graphics.clear();
            bg.graphics.beginFill(0x121212);
            bg.graphics.drawRect(0, 0, w, h);
            bg.graphics.endFill();
            t.width = w;
            t.height = h;
            var hcTx:String = colP(rTx);
            t.setTextFormat(f);
            t.htmlText = wrapChar(hcTx, w);
            t.scrollV = t.maxScrollV;
        }
        private function colP(cleanTx:String):String {
            var hA:String = "<font color='#00e287'>" + N + "@" + PC + "</font>";
            var hB:String = "<font color='#eeeeee'>:</font>";
            var hC:String = "<font color='#729fcf'>" + D + "</font>";
            var hD:String = "<font color='#eeeeee'>$ </font>";
            var fP:String = hA + hB + hC + hD;
            var rP:String = N + "@" + PC + ":" + D + "$ ";
            var cP:String = cleanTx.split(rP).join(fP);
            var dP:String = "<font color='#777777'>|</font>";
            return cP + dP;
        }
        private function wrapChar(hTx:String, maxWidth:Number):String {
            var wR:Number = 1600 / 199; 
            var maxchpRow:int = Math.floor(maxWidth / wR);
            if (maxchpRow <= 0) return hTx;
            var txR:String = "";
            var cc:int = 0;
            var inTag:Boolean = false;
            for (var i:int = 0; i < hTx.length; i += 1) {
                var c:String = hTx.charAt(i);
                if (c === "<") {
                    inTag = true;
                }
                if (c === "\n") {
                    cc = 0;
                } else if (!inTag) {
                    cc += 1;
                    if (cc > maxchpRow) {
                        txR += "\n";
                        cc = 1;
                    }
                }
                txR += c;
                if (c === ">") {
                    inTag = false;
                }
            }
            return txR;
        }
        private function hMw(e:MouseEvent):void {
            t.scrollV -= e.delta;
        }
        public static function print(s:String):void {
            rTx += s + "\n";
        }
    }
}
