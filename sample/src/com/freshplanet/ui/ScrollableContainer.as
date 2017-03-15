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
package com.freshplanet.ui {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ScrollableContainer extends Sprite {

        private var _xMovement:Boolean = true;
        private var _yMovement:Boolean = true;

        private var _prevTime:Number = 0;
        private var _moving:Boolean = false;
        private var _velocity:Point = new Point();
        private var _prevGripPoint:Point = new Point();
        private var _force:Point = new Point();

        public function ScrollableContainer(xMovement:Boolean, yMovement:Boolean) {

            super();

            _xMovement = xMovement;
            _yMovement = yMovement;

            this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        }

        private function _onAddedToStage(event:Event):void {

            this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
            this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
        }

        private function _onMouseDown(mouseEvent:MouseEvent):void {

            var gripPoint:Point = new Point(mouseEvent.stageX, mouseEvent.stageY);

            _moving = true;
            _velocity.setTo(0, 0);
            _prevGripPoint.copyFrom(gripPoint);

            this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
            this.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);

            if (this.hasEventListener(Event.ENTER_FRAME))
                this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
        }

        private function _onMouseMove(mouseEvent:MouseEvent):void {

            var gripPoint:Point = new Point(mouseEvent.stageX, mouseEvent.stageY);
            var movement:Point = gripPoint.subtract(_prevGripPoint);

            _force.copyFrom(movement);

            if (_xMovement)
                this.x += movement.x;

            if (_yMovement)
                this.y += movement.y;

            _prevGripPoint.copyFrom(gripPoint);
        }

        private function _onMouseUp(mouseEvent:MouseEvent):void {

            var gripPoint:Point = new Point(mouseEvent.stageX, mouseEvent.stageY);

            if (!gripPoint.equals(_prevGripPoint))
                _onMouseMove(mouseEvent);

            _moving = false;

            _velocity.copyFrom(_force);
//            _maxVelocity = _force ? _force / stopDuration : 1;

            _force.setTo(0, 0);

            this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
            this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
            this.stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
        }

        private function _onEnterFrame(event:Event):void {

            // grabbing the scroller stops all movement
            if (_moving)
                return;

//            // tunneling catch
//            if ((_maxVelocity > 0 && _velocity < 0) || (_maxVelocity < 0 && _velocity > 0))
//                _velocity = 0;
//
//            float friction = _maxVelocity * deltaTime;
//
//            // apply friction to velocity, cease at epsilon
//            if (fabsf(_velocity) > fabsf(_maxVelocity * _velocityEpsilon))
//                _velocity -= friction;
//            else
//                _velocity = 0;

//            // calculate gravity
//            float snapGravity = 0;
//
//            if (fabsf(_velocity) < fabsf(_maxVelocity) * velocityThreshold) {
//
//                snapGravity = (attractPoint - _position) * gravityStrength;
//
//                // gravity gets stronger as velocity gets weaker
//                snapGravity *= velocityThreshold - fabsf(_velocity / _maxVelocity);
//            }

//            // update position
//            this.x += _velocity.x;// + snapGravity.x;
//            this.y += _velocity.y;// + snapGravity.y;
        }
    }
}
