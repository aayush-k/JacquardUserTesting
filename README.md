# JacquardToolkit

JacquardToolkit is a iOS frameowork to enable developers to develop their own applications using their Levi's Jacquard...

# New Features

- Enable your applications bluetooth to start searching nearby devices
- Ability to easily connect with your own Levi's Jacquard
- Send a rainbow glow to your jacket with ease
- React to gesture the user performs on their jacket

### Installation

JacquardToolkit is currently only availible as a Cocoapod.

1. Add a pod entry for JacquardToolkit to your Podfile: 
```sh
pod 'JacquardToolkit'
```
2. Update your Popdfile by running:
```sh
pod update
```
3. Don't forget to include the necessary import statement in your target class:
```sh
import JacquardToolkit
```

### Development

1. Enable your device's bluetooth capabilities and connect to your jacket by passing in your jacket's UUID: 
```sh
import UIKit
import JacquardToolkit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.activateBlutooth { _ in 
            JacquardService.shared.connectToJacket(uuidString: YourJacketsUUIDString)
        }
    }
}
```

3. Send a colorful rainbow glow to your jacket: 
```sh
@IBAction func glowButtonTapped(_ sender: Any) {
    JacquardService.shared.rainbowGlowJacket()
}
```

4. Use the JacquardServiceDelegate to react to all of the user gestures (including Double Tap, Brush In, Brush Out, Cover, & Scratch: 
```sh
override func viewDidLoad() {
    super.viewDidLoad()
    JacquardService.shared.delegate = self
}

extension ViewController: JacquardServiceDelegate {

    func didDetectDoubleTapGesture() {
        //Detected Double Tap Gesture
    }

    func didDetectBrushInGesture() {
        //Detected Brush In Gesture
    }

    func didDetectBrushOutGesture() {
        //Detected Brush Out Gesture
    }

    func didDetectCoverGesture() {
        //Detected Cover Gesture
    }

    func didDetectScratchGesture() {
        //Detected Scratch Gesture
    }

}
```

Be sure to check out the example application for more information (JacquardToolkitExample).

License
----
MIT
