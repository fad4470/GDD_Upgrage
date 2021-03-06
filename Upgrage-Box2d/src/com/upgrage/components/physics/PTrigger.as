﻿package com.upgrage.components.physics {
	
	import flash.display.MovieClip;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import flash.events.Event;
	import flash.display.Sprite;
	
	
	public class PTrigger extends PhysicsObj {
		
		private var _triggerID:String = "default";
		private var _command:String;
		private var _disabled:Boolean = false;
		private var _locks:int = 0;
		private var _enemyLocked:Boolean = false;
		
		
		public function get disabled():Boolean { return _disabled; }
		public function set disabled(val:Boolean):void { _disabled = val; }
		public function get enemyLocked():Boolean { return _enemyLocked; }
		public function set enemyLocked(val:Boolean):void { _enemyLocked = val; }
		public function get Command():String { return _command; }
		public function set Command(comm:String) { _command = comm; }
		
		public function PTrigger() {
		}
		
		protected override function updateSelfToGraphics():void {
			super.updateSelfToGraphics();
			if(_world != null) {
				_shape = new b2PolygonShape();
				(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
				_fixtureDef.shape = _shape;
				_fixture = _body.CreateFixture(_fixtureDef);
			}
		}
		
		protected override function drawBounds():void {
			super.drawBounds();
			graphics.clear();
			graphics.endFill();
			graphics.lineStyle(3,isStatic ? 0xffDD00 : (this._body != null && this._body.IsAwake() ? 0x00ff00:0xBBDDBB)); //Red:Static, Green:Moving, Gray:Sleeping
			graphics.drawRect(-width/2,-height/2, width,height);
			graphics.moveTo(0,0);
			graphics.lineTo(width/2,0);
		}
		
		protected override function setup(e:Event):void {
			super.setup(e);
			
			_shape = new b2PolygonShape();
			(_shape as b2PolygonShape).SetAsBox(this.width/2/_world.pscale, this.height/2/_world.pscale)
			_fixtureDef.shape = _shape;
			_fixtureDef.isSensor = true;
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
		public function unlock(){
			_locks --;
			if (_locks == 0)
				this._disabled = false;
			trace(_triggerID + "\t" + _command + "\t" + _locks);
		}
		
		public function lock(){
			_locks ++;
			this._disabled = true;
		}
		
		
		[Inspectable(name="Trigger ID", type=String, defaultValue="default")]
		public function set triggerID(val:String):void {
			this._triggerID = val;
		}
		public function get triggerID():String { return this._triggerID; }
	}
	
}
