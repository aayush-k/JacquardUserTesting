//
//  ViewController.swift
//  JacquardToolkitExample
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import MessageUI
import JacquardToolkit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    // UI Outlets
    @IBOutlet weak var connectionIndicator: UIImageView!
    @IBOutlet weak var lastGestureLabel: UILabel!
    @IBOutlet weak var loggingButton: UIButton!
    @IBOutlet weak var showTutorialButton: UIButton!
    @IBOutlet var threads:[UIImageView]!
    @IBOutlet weak var gesturePrompt: UILabel!

    // CSV Logging Constants
    private let fileName = "data.csv"
    private var gestureCSVText = ""
    private let gestureSequence = ["Scratch", "Cover", "Force Touch", "Force Touch", "Cover", "Brush In", "Double Tap", "Scratch", "Brush In", "Brush Out","Scratch", "Double Tap"]
    private var gestureIndex = 0
    private var gestureErrors = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
        for thread in threads {
            thread.alpha = CGFloat(0.05)
        }
        updateUI(isConnected: false)
    }
    
    public func updateUI(isConnected: Bool) {
        loggingButton.isEnabled = isConnected
        loggingButton.alpha = CGFloat(isConnected ? 1 : 0.7)
        gesturePrompt.adjustsFontSizeToFitWidth = true
        gesturePrompt.text = gestureSequence[gestureIndex]
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        JacquardService.shared.activateBlutooth { _ in
            JacquardService.shared.connect(viewController: self)
        }
    }
    
    @IBAction func loggingButtonToggled(_ sender: Any) {
        if JacquardService.shared.loggingThreads {
            let threadCSVText = JacquardService.shared.exportLog()
            self.emailCSV(csvText: threadCSVText, emailSubject: "Thread Pressure Readings")
        }
        loggingButton.setTitle(JacquardService.shared.loggingThreads ? "Start Logging" : "Stop Logging", for: UIControl.State.normal)
        JacquardService.shared.loggingThreads = !JacquardService.shared.loggingThreads
    }
    
    @IBAction func showTutorial(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "forceTouch2", ofType:"mp4") else {
            debugPrint("forceTouch2.mp4 not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    public func advanceGesturePrompt() {
        print("----")
        gestureErrors = 0
        gestureIndex += 1
        if gestureIndex < gestureSequence.count {
            gesturePrompt.text = gestureSequence[gestureIndex]
        } else {
            self.emailCSV(csvText: gestureCSVText, emailSubject: "Gestures Intended vs Detected")
            gesturePrompt.text = "Done"
        }
        

    }
    
    public func gestureInputCheck(gestureName: String) {
        if gestureIndex >= gestureSequence.count {
            return
        }
        gestureCSVText.append("\(gestureSequence[gestureIndex]),\(gestureName)\n")
        if gestureName == gestureSequence[gestureIndex] {
            print("success!")
            advanceGesturePrompt()
        } else {
            print("error!")
            gestureErrors += 1
            
            if gestureErrors == 5 {
                advanceGesturePrompt()
            }
        }
    }
    
    
    
}

extension ViewController: JacquardServiceDelegate {
    
    func didDetectConnection(isConnected: Bool) {
        self.updateUI(isConnected: isConnected)
    }
    
    func didDetectDoubleTapGesture() {
        lastGestureLabel.text = "Double Tap"
        print("Double Tap")
        gestureInputCheck(gestureName: "Double Tap")
    }
    
    func didDetectBrushInGesture() {
        lastGestureLabel.text = "Brush In"
        print("Brush In")
        gestureInputCheck(gestureName: "Brush In")
    }
    
    func didDetectBrushOutGesture() {
        lastGestureLabel.text = "Brush Out"
        print("Brush Out")
        gestureInputCheck(gestureName: "Brush Out")
    }
    
    func didDetectCoverGesture() {
        print("Cover")
        lastGestureLabel.text = "Cover"
        gestureInputCheck(gestureName: "Cover")
    }
    
    func didDetectScratchGesture() {
        print("Scratch")
        lastGestureLabel.text = "Scratch"
        gestureInputCheck(gestureName: "Scratch")
    }
    
    func didDetectThreadTouch(threadArray: [Float]) {
        for (index, thread) in threads.enumerated() {
            thread.alpha = CGFloat(max(0.05, threadArray[index]))
        }
    }
    
    func didDetectForceTouchGesture() {
        print("Force Touch")
        lastGestureLabel.text = "Force Touch"
        gestureInputCheck(gestureName: "Force Touch")
    }
    
}


// Extension class for emailing log files
extension ViewController: MFMailComposeViewControllerDelegate {
    
    func emailCSV(csvText: String, emailSubject: String) {
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            sendMail(dataURL: path!, emailSubject: emailSubject)
        } catch {
            print("Failed to create/send csv file: \(error)")
        }
    }
    
    func sendMail(dataURL: URL, emailSubject: String) {
        if( MFMailComposeViewController.canSendMail()) {
            // attach logged csv data to email and display compose pop-up
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setSubject("\(emailSubject): \(NSDate().description)")
            do {
                try mailComposerVC.addAttachmentData(NSData(contentsOf: dataURL, options: NSData.ReadingOptions.mappedRead) as Data, mimeType: "text/csv", fileName: fileName)
            } catch {
                print("Couldn't Attach \(fileName)")
            }
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            // email failed to send
            let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
            sendMailErrorAlert.addAction(dismiss)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
