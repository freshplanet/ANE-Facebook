/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    public class TestBlock extends Sprite {

        static private const NAME_FORMAT:TextFormat = new TextFormat("Courier",
                32, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);

        private var _name:String = null;
        private var _func:Function = null;

        public function TestBlock(name:String, func:Function) {

            super();

            _name = name;
            _func = func;

            this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        }

        private function _onAddedToStage(event:Event):void {

            this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);

            this.graphics.beginFill(0x000000);
            this.graphics.drawRect(0, 0, Main.stageWidth - (Main.indent * 2), 60);
            this.graphics.endFill();
            this.x = (Main.stageWidth - this.width) / 2;

            var nameText:TextField = new TextField();
            nameText.defaultTextFormat = NAME_FORMAT;
            nameText.textColor = 0xffffff;
            nameText.text = _name;
            nameText.width = this.width;
            nameText.height = this.height;
            this.addChild(nameText);

            this.addEventListener(MouseEvent.CLICK, _onClick);
        }

        private function _onClick(mouseEvent:MouseEvent):void {
            _func();
        }
    }
}
