﻿package com.upgrage {

	public class ScriptEvent {

		public static const DIALOG:int = 1;
		public static const LEVEL_COMPLETE:int = 2;
		public static const UPGRADE:int = 3;
		public static const IGUANAS:int = 4;
		public static const CUTSCENE:int = 5;

		private var _triggerID:String;
		private var _scriptType:String;
		private var _command:String;

		/*public function ScriptEvent(aTriggerID:String, aScriptType:int, aCommand:String) {
			_triggerID = aTriggerID;
			_scriptType = aScriptType;
			_command = aCommand;
		}*/
		
		public function ScriptEvent(data:String) {
			_triggerID = data.substring(0, data.indexOf(":"));
			_scriptType = data.substring(data.indexOf(":") + 1, data.lastIndexOf(":")); 
			_command = data.substring(data.lastIndexOf(":") + 1, data.length);
			trace("TriggerID: " + _triggerID + "\tType: " + _scriptType + "\tCommand: " + _command);
		}
		
		public function get TriggerID():String { return _triggerID; }
		public function get ScriptType():String { return _scriptType; }
		public function get Command():String { return _command; }

	}
	
}
