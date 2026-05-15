// AUDIT REFERENCE: Section 8.3
// STATUS: NEW
import GameController

class GameControllerManager {
    static let shared = GameControllerManager()

    func startMonitoring() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(controllerConnected),
            name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(controllerDisconnected),
            name: .GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery {}
    }

    @objc func controllerConnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController,
              let gamepad = controller.extendedGamepad else { return }
        gamepad.buttonA.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_CROSS, pressed: pressed)
        }
        gamepad.buttonB.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_CIRCLE, pressed: pressed)
        }
        gamepad.buttonX.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_SQUARE, pressed: pressed)
        }
        gamepad.buttonY.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_TRIANGLE, pressed: pressed)
        }
        gamepad.leftShoulder.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_L1, pressed: pressed)
        }
        gamepad.rightShoulder.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_R1, pressed: pressed)
        }
        gamepad.leftTrigger.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_L2, pressed: pressed)
        }
        gamepad.rightTrigger.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_R2, pressed: pressed)
        }
        gamepad.dpad.up.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_UP, pressed: pressed)
        }
        gamepad.dpad.down.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_DOWN, pressed: pressed)
        }
        gamepad.dpad.left.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_LEFT, pressed: pressed)
        }
        gamepad.dpad.right.valueChangedHandler = { _, _, pressed in
            BionicSX2Bridge.setPadButton(pad: 0, button: PAD_RIGHT, pressed: pressed)
        }
        gamepad.leftThumbstick.valueChangedHandler = { _, x, y in
            BionicSX2Bridge.setAnalogStick(pad: 0, stick: 0, x: x, y: y)
        }
        gamepad.rightThumbstick.valueChangedHandler = { _, x, y in
            BionicSX2Bridge.setAnalogStick(pad: 0, stick: 1, x: x, y: y)
        }
    }

    @objc func controllerDisconnected(_ notification: Notification) {
        BionicSX2Bridge.clearPadState(pad: 0)
    }
}
