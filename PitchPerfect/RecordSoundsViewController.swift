//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by mayank metha on 20/06/18.
//  Copyright © 2018 mayank metha. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingError = "Recording Unsuccessful"
    }

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    enum uiState { case play, stop }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.stop)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Recording audio
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.play)
        let dirName = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirName, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    // MARK: stop audio and go to next screen
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(.stop)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            showAlert(Alerts.RecordingError, message: Alerts.RecordingError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    func configureUI(_ state: uiState) {
        switch(state) {
            case .play:
                stopRecordingButton.isEnabled = true
                recordButton.isEnabled = false
                stopRecordingButton.isHidden = false
                recordButton.isHidden = true
            case .stop:
                stopRecordingButton.isEnabled = false
                recordButton.isEnabled = true
                stopRecordingButton.isHidden = true
                recordButton.isHidden = false
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

