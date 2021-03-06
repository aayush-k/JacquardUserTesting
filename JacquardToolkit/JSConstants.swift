//
//  JSConstants.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 12/1/18.
//

import Foundation

struct JSConstants {
    
    enum JSGestures {
        case doubleTap
        case brushIn
        case brushOut
        case cover
        case scratch
        case undefined
    }
    
    struct JSStrings {
        
        enum CentralManagerState: String {
            case unknown = "Bluetooth Manager's state is unknown"
            case resetting = "Bluetooth Manager's state is resetting"
            case unsupporting = "Bluetooth Manager's state is unsupporting"
            case unauthorized = "Bluetooth Manager's state is unauthorized"
            case poweredOn = "Bluetooth Manager's state is powered on"
            case poweredOff = "Bluetooth Manager's state is powered off"
        }
        
        struct ErrorMessages {
            static let reconnectJacket = "ERROR: It doesn't seem like your Jacquard is connected. Make sure to manually connect and pair your jacket in the settings app..."
            static let emptyPeriphalList = "ERROR: It seems that your list of peripherals is empty..."
            static let rainbowGlow = "ERROR: Glow is not availible because it seems like your Jacquard is not connected. Make sure to manually connect and pair your jacket in the settings app..."
        }
        
        struct ForceTouch {
            static let outputLabel = "ForceTouch"
            static let reenableMessage = "Reenabling force touch"
        }
        
        struct Directions {
            static let qrInstructionPreScan = "Scan the QR Code on the inside of the jacket:"
            static let qrInstructionPostScan = "Re-snap the tag into the left cuff."
        }
        
    }
    
    struct JSNumbers {
        
        struct ForceTouch {
            static let threadCount = 15
            static let fullThreadCount = 675
        }
        
    }
    
    struct JSHexCodes {
        
        struct RainbowGlow {
            static let code1 = "801308001008180BDA060A0810107830013801"
            static let code2 = "414000"
        }
        
    }
    
    struct JSUUIDs {
        
        struct ServiceStrings {
            static let generalReadingUUID = "D45C2000-4270-A125-A25D-EE458C085001"
        }
        
        struct CharacteristicsStrings {
            static let gestureReadingUUID = "D45C2030-4270-A125-A25D-EE458C085001"
            static let threadReadingUUID = "D45C2010-4270-A125-A25D-EE458C085001"
        }
        
    }

}
