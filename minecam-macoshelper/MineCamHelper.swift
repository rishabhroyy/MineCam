//
//  main.swift
//  minecam-macoshelper
//
//  Created by Rishabh on 6/1/22.
//

import Foundation
import Cocoa

var KeyCode:[String:Double] = ["esc":53,"f1":122,"f2":120,"f3":99,"f4":118,"f5":96,"f6":97,"f7":98,"f8":100,"f9":101,"f10":109,"f11":103,"f12":111,"`":50,"1":18,"2":19,"3":20,"4":21,"5":23,"6":22,"7":26,"8":28,"9":25,"0":29,"-":27,"+":24,"delete":51,"tab":48,"q":12,"w":13,"e":14,"r":15,"t":17,"y":16,"u":32,"i":34,"o":31,"p":35,"[":33,"]":30,"\\":42,"caps":57,"a":0,"s":1,"d":2,"f":3,"g":5,"h":4,"j":38,"k":40,"l":37,";":41,"'":39,"enter":76,"return":36,"shift":57,"z":6,"x":7,"c":8,"v":9,"b":11,"n":45,"m":46,",":43,".":47,"/":44,"function":63,"control":59,"option":58,"command":55,"space":49,"up":126,"down":125,"left":123,"right":124]

func moveMouseTo(point: CGPoint, mouseDown: Bool, mouseUp: Bool, button: String, moveMouse: Bool) {
    if (button == "left") {
        var point2 = point
        if (moveMouse) {
            CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: point, mouseButton: CGMouseButton.left)?.post(tap: CGEventTapLocation.cghidEventTap)
        } else {
            let ourEvent = CGEvent.init(source: nil);
            point2 = ourEvent?.location ?? point
        }

        if (mouseDown) {
            CGEvent(mouseEventSource:nil,mouseType:CGEventType.leftMouseDown, mouseCursorPosition: point2, mouseButton: CGMouseButton.left)?.post(tap:CGEventTapLocation.cghidEventTap)
        }

        if (mouseUp) {
            CGEvent(mouseEventSource:nil,mouseType:CGEventType.leftMouseUp, mouseCursorPosition: point2, mouseButton: CGMouseButton.left)?.post(tap:CGEventTapLocation.cghidEventTap)
        }
    }
    if (button == "right") {
        var point2 = point
        if (moveMouse) {
            CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: point, mouseButton: CGMouseButton.right)?.post(tap: CGEventTapLocation.cghidEventTap)
        } else {
            let ourEvent = CGEvent.init(source: nil);
            point2 = ourEvent?.location ?? point
        }

        if (mouseDown) {
            CGEvent(mouseEventSource:nil,mouseType:CGEventType.rightMouseDown, mouseCursorPosition: point2, mouseButton: CGMouseButton.right)?.post(tap:CGEventTapLocation.cghidEventTap)
        }

        if (mouseUp) {
            CGEvent(mouseEventSource:nil,mouseType:CGEventType.rightMouseUp, mouseCursorPosition: point2, mouseButton: CGMouseButton.right)?.post(tap:CGEventTapLocation.cghidEventTap)
        }
    }
}

func pressKey(key:Double, down: Bool) {
    CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: down)?.post(tap:CGEventTapLocation.cghidEventTap)
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            return false
        }
    }
}

// ponytail: one persistent process reading commands from stdin, not a fresh
// process per input event (that was starving the system of PIDs/FDs and made
// events fire late or never). Same "type arg1 arg2 ..." grammar as before,
// one command per line instead of one command per process.
func handle(_ tokens: [Substring]) {
    guard let type = tokens.first else { return }

    if type == "mouse", tokens.count >= 7 {
        let pt = CGPoint(x: Double(tokens[1]) ?? 0, y: Double(tokens[2]) ?? 0)
        moveMouseTo(
            point: pt,
            mouseDown: String(tokens[4]).bool ?? false,
            mouseUp: String(tokens[5]).bool ?? false,
            button: String(tokens[3]),
            moveMouse: String(tokens[6]).bool ?? false
        )
    }

    if type == "keyboard", tokens.count >= 3, let key = KeyCode[String(tokens[1])] {
        pressKey(key: key, down: String(tokens[2]).bool ?? false)
    }
}

while let line = readLine(strippingNewline: true) {
    handle(line.split(separator: " "))
}
