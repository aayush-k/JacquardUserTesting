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
    @IBOutlet weak var gestureTestPrompt: UILabel!
    @IBOutlet weak var startGestureTestButton_A: UIButton!
    @IBOutlet weak var startGestureTestButton_B: UIButton!
    @IBOutlet weak var gestureTestPromptDirectionsLabel: UILabel!
    
    // gesture test vars
    private let fileName = "data.csv"
    private var gestureTestCSVText = ""
    private var gestureTestSequence = [""]
    private var gestureTestIndex = 0
    private var gestureTestMismatchErrors = 0
    private let gestureTestMismatchLimit = 5
    private var hasGestureTestStarted = false
    private var gestureTestType = ""
    
    // gesture tutorial vars
    private let tutorialPlayerController = AVPlayerViewController()
    private var currentGestureInTutorial = ""
    private var tutorialGestureRepeatCounter = 0
    private var tutorialSequenceIndex = 0
    private let tutorialGestureRepeats = 3
    private let tutorialNameSequence = ["Force Touch", "Scratch"]
    private let tutorialFileSequence = ["forceTouch2", "scratch"]

    override public func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
        for thread in threads {
            thread.alpha = CGFloat(0.05)
        }
        updateUI(isConnected: false)
    }
    
    public func updateUI(isConnected: Bool) {
        // Test UI: Gesture Prompt
        gestureTestPrompt.adjustsFontSizeToFitWidth = true
        gestureTestPrompt.text = "(\(gestureTestIndex + 1)/\(gestureTestSequence.count)): \(gestureTestSequence[gestureTestIndex])"
        gestureTestPrompt.isHidden = !hasGestureTestStarted
        gestureTestPromptDirectionsLabel.isHidden = !hasGestureTestStarted
        // Test UI: Start Gesture Test A
        startGestureTestButton_A.isHidden = hasGestureTestStarted
        startGestureTestButton_A.alpha = CGFloat(isConnected ? 1 : 0.4)
        startGestureTestButton_A.isEnabled = isConnected
        // Test UI: Start Gesture Test B
        startGestureTestButton_B.isHidden = hasGestureTestStarted
        startGestureTestButton_B.alpha = CGFloat(isConnected ? 1 : 0.4)
        startGestureTestButton_B.isEnabled = isConnected
        
        // Top-Left Logging UI
        loggingButton.isEnabled = isConnected
        loggingButton.alpha = CGFloat(isConnected ? 1 : 0.7)
        
        // Top-Right Tutorial UI
        showTutorialButton.isEnabled = isConnected
        showTutorialButton.alpha = CGFloat(isConnected ? 1 : 0.7)

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
    
    @IBAction func startTestATapped(_ sender: Any) {
        hasGestureTestStarted = true
        gestureTestType = "A"
        gestureTestSequence = ["Force Touch", "Brush In", "Scratch", "Cover", "Force Touch", "Double Tap", "Brush In", "Double Tap", "Brush Out", "Scratch", "Cover", "Brush In", "Brush Out", "Double Tap", "Force Touch", "Cover", "Scratch", "Brush Out"]
        updateUI(isConnected: true)
    }
    
    @IBAction func startTestBTapped(_ sender: Any) {
        hasGestureTestStarted = true
        gestureTestType = "B"
        gestureTestSequence = ["Brush Out", "Cover", "Scratch", "Brush In", "Double Tap", "Brush In", "Cover", "Brush Out", "Scratch", "Force Touch", "Brush Out", "Force Touch", "Double Tap", "Scratch", "Force Touch", "Double Tap", "Brush In", "Cover"]
        updateUI(isConnected: true)
    }
    
    
    @IBAction func showTutorial(_ sender: Any) {
        gestureTutorialHelper()
    }
    
    public func gestureTutorialHelper() {
        tutorialGestureRepeatCounter += 1
        if (tutorialGestureRepeatCounter == tutorialGestureRepeats + 1) {
            // reset repeats to zero and advance to next gesture
            tutorialGestureRepeatCounter = 1
            tutorialSequenceIndex += 1
            // if no more gestures, reset index to 0 for next call to show tutorials
            if (tutorialSequenceIndex == tutorialNameSequence.count) {
                tutorialSequenceIndex = 0
                return
            }
        }
        // update gesture being taught, specifically the name and the video file
        currentGestureInTutorial = tutorialNameSequence[tutorialSequenceIndex]
        let gestureFileVideo = tutorialFileSequence[tutorialSequenceIndex]
        
        // retrieve video file to construct video player with
        guard let path = Bundle.main.path(forResource: gestureFileVideo, ofType:"mp4") else {
            debugPrint("\(gestureFileVideo).mp4 not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        tutorialPlayerController.player = player
        tutorialPlayerController.showsPlaybackControls = false
        
        // create overlay of directions for gesture tutorial
        let gestureDirections = UILabel(frame: CGRect(x: 0, y: 40, width: tutorialPlayerController.view.frame.size.width, height: 50))
        gestureDirections.text = "\(currentGestureInTutorial): Try It Now!"
        gestureDirections.textColor = .white
        gestureDirections.textAlignment = .center
        
        // remove artifacts from video overlay and add updated directions overlay
        tutorialPlayerController.contentOverlayView?.subviews.forEach { $0.removeFromSuperview() }
        tutorialPlayerController.contentOverlayView?.addSubview(gestureDirections)
        
        // present the video tutorial
        present(tutorialPlayerController, animated: true) {
            player.play()
            // looping until forcetouch gesture delegate dismisses video tutorial
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
                player.seek(to: CMTime.zero)
                player.play()
            }
        }
    }
    
    public func gestureTestInputCheck(gestureName: String) {
        // exit if (1) a user test hasn't started, (2) a tutorial is being displayed, or (3) we have no gestures left to prompt for
        if !hasGestureTestStarted || tutorialPlayerController.isFirstResponder || gestureTestIndex >= gestureTestSequence.count {
            return
        }
        // add the intended gesture, then gesture detected to the csv
        gestureTestCSVText.append("\(gestureTestSequence[gestureTestIndex]),\(gestureName)\n")
        if gestureName == gestureTestSequence[gestureTestIndex] {
            // if these match, successfully proceed to next gesture prompt

            print("success!")
            advanceGestureTestPrompt()
        } else {
            // if a gesture other than the intended gesture was detected, the user is given a total of 5 chances before moving on to the next gesture
            print("error!")
            gestureTestMismatchErrors += 1
            
            if gestureTestMismatchErrors == gestureTestMismatchLimit {
                advanceGestureTestPrompt()
            }
        }
    }
    
    public func advanceGestureTestPrompt() {
        // proceed to next gesture to prompt for
        print("----")
        gestureTestMismatchErrors = 0
        gestureTestIndex += 1
        if gestureTestIndex < gestureTestSequence.count {
            gestureTestPrompt.text = "(\(gestureTestIndex + 1)/\(gestureTestSequence.count)): \(gestureTestSequence[gestureTestIndex])"
        } else {
            // if all gestures have been prompted for then display email window with data as csv
            self.emailCSV(csvText: gestureTestCSVText, emailSubject: "Gestures Intended vs Detected: \(gestureTestType)")
            gestureTestCSVText = ""
            gestureTestIndex = 0
            gestureTestMismatchErrors = 0
            hasGestureTestStarted = false
            gestureTestType = ""
            updateUI(isConnected: true)
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
        gestureTestInputCheck(gestureName: "Double Tap")
    }
    
    func didDetectBrushInGesture() {
        lastGestureLabel.text = "Brush In"
        print("Brush In")
        gestureTestInputCheck(gestureName: "Brush In")
    }
    
    func didDetectBrushOutGesture() {
        lastGestureLabel.text = "Brush Out"
        print("Brush Out")
        gestureTestInputCheck(gestureName: "Brush Out")
    }
    
    func didDetectCoverGesture() {
        print("Cover")
        lastGestureLabel.text = "Cover"
        gestureTestInputCheck(gestureName: "Cover")
    }
    
    func didDetectScratchGesture() {
        print("Scratch")
        lastGestureLabel.text = "Scratch"
        gestureTestInputCheck(gestureName: "Scratch")
        
        if tutorialPlayerController.isFirstResponder && currentGestureInTutorial == "Scratch" {
            tutorialPlayerController.dismiss(animated: true, completion: nil)
            gestureTutorialHelper()
        }
    }
    
    func didDetectThreadTouch(threadArray: [Float]) {
        for (index, thread) in threads.enumerated() {
            thread.alpha = CGFloat(max(0.05, threadArray[index]))
        }
    }
    
    func didDetectForceTouchGesture() {
        print("Force Touch")
        lastGestureLabel.text = "Force Touch"
        gestureTestInputCheck(gestureName: "Force Touch")
        
        if tutorialPlayerController.isFirstResponder && currentGestureInTutorial == "Force Touch" {
            tutorialPlayerController.dismiss(animated: true, completion: nil)
            gestureTutorialHelper()
        }
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
