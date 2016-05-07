//
//  LightSocket.swift
//  iot-semestral
//
//  Created by filletzz on 07/05/16.
//  Copyright © 2016 pchmelar. All rights reserved.
//

import Starscream
import SwiftyJSON

class LightSocket {
  
  var light: Bool = false
  var ibeacon: Bool = false
  let socket: WebSocket
  
  init(socket: WebSocket){
    self.socket = socket
    self.socket.delegate = self
    self.socket.connect()
  }
  
}

// MARK: - WebSocketDelegate
extension LightSocket: WebSocketDelegate {
  
  func websocketDidConnect(socket: WebSocket) {
    print("websocket is connected")
  }
  
  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    print("websocket is disconnected: \(error?.localizedDescription)")
  }
  
  func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    print("got some text: \(text)")
    
    if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
      //get data from json
      let json = JSON(data: dataFromString)
      light = json["val"].boolValue
    }
    
    //send notification
    NSNotificationCenter.defaultCenter().postNotificationName("websocketUpdate", object: nil)
  }
  
  func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    print("got some data: \(data.length)")
  }
  
}