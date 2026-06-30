package runtime.willyhorizont {
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldType;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getQualifiedClassName;

    import Program;

    [SWF(backgroundColor="0x121212")]

    public class Runtime extends Sprite {
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

        public function Runtime() {
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

            stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
            stage.addEventListener(Event.RESIZE, re);

            Program.run();
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

            var hcTx:String = colorPrompt(rTx);
            t.setTextFormat(f);
            t.htmlText = wrapChar(hcTx, w);

            t.scrollV = t.maxScrollV;
        }

        private function colorPrompt(cleanTx:String):String {
            var hA:String = "<font color='#00e287'>" + N + "@" + PC + "</font>";
            var hB:String = "<font color='#eeeeee'>:</font>";
            var hC:String = "<font color='#729fcf'>" + D + "</font>";
            var hD:String = "<font color='#eeeeee'>$ </font>";
            var fP:String = hA + hB + hC + hD;
            var rP:String = N + "@" + PC + ":" + D + "$ ";
            var cP:String = cleanTx.split(rP).join(fP);
            return cP;
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

        private function handleMouseWheel(e:MouseEvent):void {
            t.scrollV -= e.delta;
        }

        public static function print(s:String):void {
            rTx += s + "\n";
        }

        public static function getType(a:*):String {
            var aT:String = getQualifiedClassName(a);
            switch (aT) {
                case "Array":
                    return "[object XlList]";
                    break;
                case "Object":
                    return "[object XlDict]";
                    break;
                case "null":
                    return "[object XlNone]";
                    break;
                case "Boolean":
                    return "[object XlBool]";
                    break;
                case "String":
                    return "[object XlString]";
                    break;
                case "int":
                    return "[object XlInt]";
                    break;
                case "Number":
                    return "[object XlFloat]";
                    break;
                case "Function":
                    return "[object XlClosure]";
                    break;
                default:
                    return "[object " + aT + "]";
                    break;
            }
        }

        public static function xlListReduce(a:Array, c:Function, iV:* = null):* {
            var i:int = 0;
            var ac:* = iV;

            if ((iV === null) && (a.length > 0)) {
                ac = a[0];
                i = 1;
            }

            for (i; i < a.length; i += 1) {
                ac = c(ac, a[i], i, a);
            }
            return ac;
        }

        public static function xlDictGetItems(d:Object):Array {
            var dEl:Array = [];

            for (var k:String in d) {
                dEl.push([k, d[k]]);
            }
            return dEl;
        }

        public static function xlDictFromItems(el:Array):Object {
            var d:Object = {};

            for (var i:int = 0; i < el.length; i += 1) {
                var p:Array = el[i] as Array;

                if ((p != null) && (p.length >= 2)) {
                    var key:String = String(p[0]);
                    var val:* = p[1];

                    d[key] = val;
                }
            }
            return d;
        }

        public static function jsonStringify(r:*, o:Object = null):String {
            var p:Boolean = false;
            if ((o != null) && (o.hasOwnProperty("pretty"))) {
                p = Boolean(o["pretty"]);
            }
            var rT:String = getType(r);
            if (rT === "[object XlClosure]") return "\"[object Function]\"";
            if (rT === "[object XlNone]") return "null";
            if (rT === "[object XlBool]") return r ? "true" : "false";
            if (rT === "[object XlString]") return "\"" + r + "\"";
            if ((rT === "[object XlInt]") || (rT === "[object XlFloat]")) return String(r);
            if ((rT !== "[object XlList]") && (rT !== "[object XlDict]")) return rT;

            var sT:Array = [];
            var rs:Object = {};
            var iC:int = 0;

            var rId:String = "___TOKEN_" + iC + "___";
            iC += 1;
            sT.push({ id: rId, data: r, type: rT, step: 0, childrenIds: [], keys: [], depth: 0 });

            while (sT.length > 0) {
                var c:Object = sT[sT.length - 1];
                var tg:* = c.data;
                var cD:int = c.depth;

                var getIndent:Function = function(d:int):String {
                    if (!p) return "";
                    var ind:String = "";
                    for (var indLv:int = 0; indLv < d; indLv += 1) {
                        ind += "    ";
                    }
                    return ind;
                };

                var nL:String = p ? "\n" : "";

                if (c.type === "[object XlList]") {
                    var l:Array = tg as Array;

                    if (c.step === 0) {
                        for (var i:int = 0; i < l.length; i += 1) {
                            var el:* = l[i];
                            var elT:String = getType(el);

                            if ((elT === "[object XlList]") || (elT === "[object XlDict]")) {
                                var childId:String = "___TOKEN_" + iC + "___";
                                iC += 1;
                                c.childrenIds.push(childId);
                                sT.push({ id: childId, data: el, type: elT, step: 0, childrenIds: [], keys: [], depth: cD + 1 });
                            } else {
                                var pS:String = "";
                                if (elT === "[object XlClosure]") pS = "\"[object Function]\"";
                                else if (elT === "[object XlNone]") pS = "null";
                                else if (elT === "[object XlBool]") pS = el ? "true" : "false";
                                else if (elT === "[object XlString]") pS = "\"" + el + "\"";
                                else pS = String(el);
                                
                                c.childrenIds.push(pS);
                            }
                        }
                        c.step = 1;
                    } 
                    else if (c.step === 1) {
                        var lP:Array = [];
                        for (var j:int = 0; j < c.childrenIds.length; j += 1) {
                            var tokOrV:String = c.childrenIds[j];
                            var fS:String = (rs[tokOrV] !== undefined) ? rs[tokOrV] : tokOrV;
                            lP.push(getIndent(cD + 1) + fS);
                        }

                        if (lP.length === 0) {
                            rs[c.id] = "[]";
                        } else {
                            rs[c.id] = "[" + nL + lP.join("," + nL) + nL + getIndent(cD) + "]";
                        }
                        sT.pop();
                    }
                } 
                else if (c.type === "[object XlDict]") {
                    var dEl:Array = xlDictGetItems(tg);

                    if (c.step === 0) {
                        for (var k:int = 0; k < dEl.length; k += 1) {
                            var kvp:Array = dEl[k] as Array;
                            var dK:String = kvp[0];
                            var dV:* = kvp[1];
                            var dvT:String = getType(dV);

                            c.keys.push(dK);

                            if ((dvT === "[object XlList]") || (dvT === "[object XlDict]")) {
                                var dCdId:String = "___TOKEN_" + iC + "___";
                                iC += 1;
                                c.childrenIds.push(dCdId);
                                sT.push({ id: dCdId, data: dV, type: dvT, step: 0, childrenIds: [], keys: [], depth: cD + 1 });
                            } else {
                                var dPrmStr:String = "";
                                if (dvT === "[object XlClosure]") dPrmStr = "\"[object Function]\"";
                                else if (dvT === "[object XlNone]") dPrmStr = "null";
                                else if (dvT === "[object XlBool]") dPrmStr = dV ? "true" : "false";
                                else if (dvT === "[object XlString]") dPrmStr = "\"" + dV + "\"";
                                else dPrmStr = String(dV);

                                c.childrenIds.push(dPrmStr);
                            }
                        }
                        c.step = 1;
                    } 
                    else if (c.step === 1) {
                        var dP:Array = [];
                        for (var m:int = 0; m < c.keys.length; m += 1) {
                            var dKy:String = c.keys[m];
                            var dTokOrV:String = c.childrenIds[m];
                            var fValStr:String = (rs[dTokOrV] !== undefined) ? rs[dTokOrV] : dTokOrV;

                            var cS:String = p ? ": " : ":";
                            dP.push(getIndent(cD + 1) + "\"" + dKy + "\"" + cS + fValStr);
                        }

                        if (dP.length === 0) {
                            rs[c.id] = "{}";
                        } else {
                            rs[c.id] = "{" + nL + dP.join("," + nL) + nL + getIndent(cD) + "}";
                        }
                        sT.pop();
                    }
                }
            }

            return rs[rId];
        }
    }
}
