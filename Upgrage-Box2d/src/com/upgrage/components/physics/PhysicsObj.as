﻿package com.upgrage.components.physics {
	
	import fl.core.UIComponent;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2Fixture;
	import flash.display.MovieClip;
	import Box2D.Common.Math.b2Vec2;
	import flash.events.Event;
	import fl.events.ComponentEvent;
	import fl.core.InvalidationType;
	import com.upgrage.components.GraphicalObject;


	//Required overrides: drawBounds, setup
	public class PhysicsObj extends UIComponent{

		protected var _isDead:Boolean = false
		
		private var _isStatic:Boolean = true;
		private var _fixedRotation:Boolean = false;
		private var _density:Number = 10;
		private var _friction:Number = 0.2;
		private var _bounciness:Number = 0;
		private var _startVelX:Number = 0;
		private var _startVelY:Number = 0;
		private var _startVelR:Number = 0;
		
		private var _followingObject:MovieClip = null;
		private var _followingObjectName:String = "";
		
		protected var _bodyDef:b2BodyDef;
		protected var _body:b2Body;
		protected var _shape:b2Shape;
		protected var _fixtureDef:b2FixtureDef;
		protected var _fixture:b2Fixture;
		protected var _inWater:Boolean = false;
		protected var _waterHolder:PDampSpace = null;
		
		protected var _gravity:b2Vec2 = PhysicsWorld.DEFAULT_GRAVITY;

		protected var _world:PhysicsWorld = null;
		public function PhysicsObj() {
			_bodyDef = new b2BodyDef();
			_fixtureDef = new b2FixtureDef();
			
			if(this.isLivePreview) this.addEventListener(ComponentEvent.RESIZE, onComponentChange);
		}
		
		protected function setup(e:Event):void { //Called by world when things are finished loading.
			_world.removeEventListener(PhysicsWorld.DONE_LOADING,setup);
			//if(parent is PhysicsWorld) _world = parent as PhysicsWorld;
			_body = _world.w.CreateBody(_bodyDef);
			_body.SetUserData(this);
			trace("SETUP " + _body.GetUserData());
			
			var rotTemp:Number = this.rotation; //Initally positioning at own position in case graphic object not found.
			_body.SetPosition(new b2Vec2(x/_world.pscale,y/_world.pscale));
			_body.SetAngle(rotTemp*(Math.PI/180));
			
			_world.addEventListener(PhysicsWorld.TICK_WORLD,onTick);
			//_fixture = _body.CreateFixture(_fixtureDef); //Should be done by child class as they need to set the shape
			
			isStatic = isStatic;
			density = density;
			friction = friction;
			bounciness = bounciness;
			
			_body.SetLinearVelocity(new b2Vec2(_startVelX, _startVelY));
			_body.SetAngularVelocity(_startVelR);
			
			if(!this.isLivePreview && this._followingObject != null) {
				//var ratio:Number = _followingObject.height / _followingObject.width;
				//this._followingObject.width = this.width;
				//this._followingObject.height = this.width*ratio;
				//this._followingObject.rotation = this.rotation;
				//updateSelfToGraphics();
			}
		}
		
		public function kill(){
			if(_isDead) return;
			if(followingObject) parent.removeChild(this.followingObject);
			parent.removeChild(this);
			_world.removeBody(this._body);
			this._isDead = true;
		}
		
		protected override function configUI():void {
			super.configUI();
			draw();
		}
		
		protected override function draw():void {
			super.draw();
			if(this.isLivePreview/* || PhysicsWorld.DEBUG*/){
				drawBounds();
			}
		}
		
		private function onComponentChange(e:ComponentEvent):void { 
			graphics.clear();
			//this.invalidate(InvalidationType.SIZE);
			if(this.isLivePreview/* || PhysicsWorld.DEBUG*/){
				drawBounds();
			}
		}
		
		//Orient self to graphical object
		protected function updateSelfToGraphics():void {
			if(_followingObject == null || _world == null) return;
			
			var pos:b2Vec2 = new b2Vec2();
			pos.x = this._followingObject.x * _world.pscale;
			pos.y = this._followingObject.y * _world.pscale;
			_body.SetPosition(pos);
			
			var tempRot = _followingObject.rotation; //Push-pop rotation because width/height are affected otherwise
			_followingObject.rotation = 0;
			/*this.width = _followingObject.width/_world.pscale;
			this.height = _followingObject.height/_world.pscale;*/
			this.rotation = _followingObject.rotation = tempRot; 
			_body.SetAngle(tempRot * (Math.PI/180));
		}
		
		public function setPositionAndVelocity(pos:b2Vec2, vel:b2Vec2){
			this._body.SetPosition(pos);
			this._body.SetLinearVelocity(vel);
		}
		public function setRotation(rad:Number){
			this._body.SetAngle(rad);
		}
		public function onTick(e:Event):void{
			
			var pos:b2Vec2 = _body.GetPosition();
			this.x = pos.x*_world.pscale;
			this.y = pos.y*_world.pscale;
			
			//Move accompanying sprite
			this.rotation = _body.GetAngle()*(180/Math.PI);
			
			if(_followingObject != null){
				this._followingObject.x = this.x;
				this._followingObject.y = this.y;
				this._followingObject.rotation = this.rotation;
			}
			if(this.isLivePreview/* || PhysicsWorld.DEBUG*/){
				drawBounds();
			}
		}
		
		public function setInitialWorld(val:PhysicsWorld):void{
			this._world = val;
			this._world.addEventListener(PhysicsWorld.DONE_LOADING,setup);
		}
		
		public function get followingObject():MovieClip{
			return this._followingObject;
		}
		protected function setFollowingObject(val:MovieClip):void{
			this._followingObject = val;
		}

		public function set gravity(grav:b2Vec2):void { this._gravity = grav; }
		public function get gravity():b2Vec2 { return this._gravity; }
		public function get body():b2Body { return this._body; }
		
		// Draw object's physical shape boundaries (abstract)
		protected function drawBounds():void {}
		
		[Inspectable(name="Is Static", type=Boolean, defaultValue=true)]
		public function set isStatic(val:Boolean):void{
			_isStatic = val;
			_bodyDef.type = _isStatic? b2Body.b2_staticBody : b2Body.b2_dynamicBody;
			if(_body != null) {
				_body.SetType(_bodyDef.type);
			}
			draw();
		}
		public function get isStatic():Boolean { return _isStatic; }
		
		[Inspectable(name="Fixed Rotation", type=Boolean, defaultValue=false)]
		public function set isRotationFixed(val:Boolean):void{
			_fixedRotation = val;
			_bodyDef.fixedRotation = _fixedRotation;
			if(_body != null){ 
				_body.SetFixedRotation(_fixedRotation);
			}
		}
		public function get isRotationFixed():Boolean { return _fixedRotation; }

		
		[Inspectable(name="Density", type=Number, defaultValue=10)]
		public function set density(val:Number):void{
			_density = val;
			_fixtureDef.density = _density;
			if(_fixture != null)
				_fixture.SetDensity(_density);
		}
		public function get density():Number { return _density; }

		
		[Inspectable(name="Friction", type=Number, defaultValue=0.2)]
		public function set friction(val:Number):void{
			_friction = val;
			_fixtureDef.friction = _friction;
			if(_fixture != null)
				_fixture.SetFriction(_friction);
		}
		public function get friction():Number { return _friction; }

		
		[Inspectable(name="Bounciness", type=Number, defaultValue=0)]
		public function set bounciness(val:Number):void{
			_bounciness = val;
			_fixtureDef.restitution = _bounciness;
			if(_fixture != null)
				_fixture.SetRestitution(_bounciness);
		}
		public function get bounciness():Number { return _bounciness; }

		
		[Inspectable(name="Starting Velocity X", type=Number, defaultValue=0)]
		public function set startVelX(val:Number):void{
			_startVelX = val;
			if(_body != null)
				_body.SetLinearVelocity(new b2Vec2(_startVelX,_startVelY));
		}
		public function get startVelX():Number { return _startVelX; }

		
		[Inspectable(name="Starting Velocity Y", type=Number, defaultValue=0)]
		public function set startVelY(val:Number):void{
			_startVelY = val;
			if(_body != null)
				_body.SetLinearVelocity(new b2Vec2(_startVelX,_startVelY));
		}
		public function get startVelY():Number { return _startVelY; }

		
		[Inspectable(name="Starting Velocity R", type=Number, defaultValue=0)]
		public function set startVelR(val:Number):void{
			_startVelR = val;
			if(_body != null)
				_body.SetAngularVelocity(_startVelR);
		}
		public function get startVelR():Number { return _startVelR; }

		
		[Inspectable(name="Graphical Component", type=String, defaultValue="")]
		public function set followingObjectName(val:String):void{
			_followingObjectName = val;
			var hadSprite:Boolean = false; //if the sprite is getting swapped
			var last:MovieClip = null;
			if(_followingObject != null){
				parent.removeChild(_followingObject);
				last = this._followingObject;
				_followingObject = null;
				hadSprite = true;
			}
			if(_followingObjectName){
				try{
					this._followingObject = (parent.getChildByName(_followingObjectName) as GraphicalObject).duplicate();//parent.getChildByName(_followingObjectName) as MovieClip;
				}catch(e:Error){
					trace("Error: Following object must extend base class com.upgrage.components.GraphicalObject! " + _followingObjectName + " " + this);
				}
			}
			if(!hadSprite){
				this.updateSelfToGraphics();
			}else if(_followingObject){
				//var ratio:Number = _followingObject.height / _followingObject.width;
				//this._followingObject.width = this.width;
				//this._followingObject.height = this.width*ratio;
				//this._followingObject.rotation = this.rotation;
				
				_followingObject.scaleX = last.scaleX;
				_followingObject.scaleY = last.scaleY;
				if(last.isPlaying){
					_followingObject.gotoAndPlay(last.currentFrame);
				}else{
					_followingObject.gotoAndStop(last.currentFrame);
				}
			}
			//this._followingObject = this._followingObject.duplicateMovieClip("clip-" + _followingObject.name + ":r" + Math.round(Math.random()*1000), parent.numChildren);
		}
		public function get followingObjectName():String { return _followingObjectName; }

		
		public function set inWater(val:Boolean):void {
			this._inWater = val;
		}
		public function get inWater():Boolean{
			return this._inWater;
		}
		
		public function set water(val:PDampSpace):void {
			this._waterHolder = val;
		}
		public function get water():PDampSpace {
			return this._waterHolder;
		}

	}
	
}
