//
//  SecondViewController.swift
//  AwesomePlayer
//
//  Created by Łukasz Sokołowski on 27/12/2018.
//  Copyright © 2018 Łukasz Sokołowski. All rights reserved.
//

import UIKit
import AVFoundation
import FDWaveformView
import UserNotifications

class SecondViewController: UIViewController, AVAudioPlayerDelegate,UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var coverImageWave: FDWaveformView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sliderRate: UISlider!
    
    @IBOutlet weak var pausebutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        songNameLabel.text = songs[currentSong]
        setLayout()
        setCoverImage()
        timeHandler()
       // audioPlayer.enableRate = true
    }
    override func viewWillAppear(_ animated: Bool) {
        songNameLabel.text = songs[currentSong]
        setCoverImage()
        audioPlayer.enableRate = true
        
        if audioPlayer.isPlaying {
            playButton.isHidden = true
            pausebutton.isHidden = false
        }
        else {
            playButton.isHidden = false
            pausebutton.isHidden = true
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            playButton.isHidden = true
            pausebutton.isHidden = false
        }
        else {
            playButton.isHidden = true
            pausebutton.isHidden = false
        }
        if audioStuffed && !audioPlayer.isPlaying {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                playThis(thisOne: songs[currentSong])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        if !audioPlayer.isPlaying {
            playButton.isHidden = false
            pausebutton.isHidden = true
        }
        else {
            playButton.isHidden = false
            pausebutton.isHidden = true
        }
        if audioStuffed && audioPlayer.isPlaying {
            audioPlayer.pause()
        }
    }
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        if currentSong != 0 && audioStuffed  {
            playThis(thisOne: songs[currentSong-1])
            currentSong -= 1
            songNameLabel.text = songs[currentSong]
            setCoverImage()
        }
        else {
            
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if currentSong < songs.count-1 && audioStuffed {
            playThis(thisOne: songs[currentSong+1])
            currentSong += 1
            songNameLabel.text = songs[currentSong]
            setCoverImage()
        }
        else {
            
        }
    }
    
    @IBAction func fastBackward(_ sender: Any) {
        var time = audioPlayer.currentTime
        time -= 5.0
        if time >= 0 {
          audioPlayer.currentTime = time
        }
        else{
            
        }
    }

    @IBAction func fastForward(_ sender: Any) {
        var time = audioPlayer.currentTime
        time += 5.0 
        if time <= audioPlayer.duration {
           audioPlayer.currentTime = time
        }else {
           
        }
    }
    
    @IBAction func rateSlider(_ slider: UISlider) {
        //audioPlayer.delegate = self
         audioPlayer.rate = slider.value
    }
    @IBAction func channelSlider(_ sender: UISlider) {
        
        audioPlayer.pan = sender.value
    }
    @IBAction func volumeSlider(_ sender: UISlider) {
     
        audioPlayer.volume = sender.value
    }
    
    func setLayout() {
        songNameLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)
        coverImageWave.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 10
        coverImageWave.layer.shadowColor = UIColor.black.cgColor
        coverImageWave.layer.shadowRadius = 4.0
        coverImageWave.layer.shadowOpacity = 1.0
        coverImageWave.layer.shadowOffset = CGSize(width: 5, height: 9)
        coverImageWave.layer.masksToBounds = false
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Now playing"
        content.body = songs[currentSong]
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    func setCoverImage() {
        let url = Bundle(for: type(of: self)).url(forResource: songs[currentSong], withExtension: ".mp3")
        self.coverImageWave.audioURL = url
        coverImageWave.reloadInputViews()
    }
    
    func playThis(thisOne: String) {
        do {
            
            let audioPath = Bundle.main.path(forResource: thisOne, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!)as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.enableRate = true
            setCoverImage()
            audioPlayer.rate = sliderRate.value
            songNameLabel.text = songs[currentSong]
            songNameLabel.reloadInputViews()
            audioPlayer.play()
            timeHandler()
            
        } catch {
            print("ERROR")
        }
    }
    
    @objc func updateAudioProgressView()
    {
        if audioPlayer.isPlaying {
            progressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: true)
        }
    }
    
    func timeHandler() {
        let state = UIApplication.shared.applicationState
        if state != .background {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
            progressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: false)
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if currentSong < songs.count-1 {
            print("JESTEM 2")
            currentSong += 1
            playThis(thisOne: songs[currentSong])

        }
        else {
            
        }
        
        let state = UIApplication.shared.applicationState
        if state == .background {
            print("App in Background")
            scheduleNotification()
        }
    }
}

