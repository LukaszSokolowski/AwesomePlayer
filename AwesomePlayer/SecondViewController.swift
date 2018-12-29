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

    override func viewDidLoad() {
        super.viewDidLoad()
        songNameLabel.text = songs[currentSong]
        setCoverImage()
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if audioStuffed && !audioPlayer.isPlaying {
             audioPlayer.play()
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
      
        if audioStuffed && audioPlayer.isPlaying {
            audioPlayer.pause()
        }
    }
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        if currentSong != 0 && audioStuffed  {
            playThis(thisOne: songs[currentSong-1])
            currentSong -= 1
            songNameLabel.text = songs[currentSong]
            
        }
        else {
            
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if currentSong < songs.count-1 && audioStuffed {
            playThis(thisOne: songs[currentSong+1])
            currentSong += 1
            songNameLabel.text = songs[currentSong]
        }
        else {
            
        }
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        if audioStuffed {
            audioPlayer.volume = sender.value
        }
    }
    
    
    @IBAction func notifyMe(_ sender: Any) {
        scheduleNotification()
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
       // self.coverImageWave.doesAllowScrubbing = true
       // self.coverImageWave.doesAllowStretch = true
       // self.coverImageWave.doesAllowScroll = true
        self.coverImageWave.audioURL = url
        coverImageWave.reloadInputViews()
    }
    
    func playThis(thisOne: String) {
        do {
            let audioPath = Bundle.main.path(forResource: thisOne, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!)as URL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            let url = Bundle(for: type(of: self)).url(forResource: songs[currentSong], withExtension: ".mp3")
            self.coverImageWave.audioURL = url
            coverImageWave.reloadInputViews()
            audioPlayer.play()
            
        } catch {
            print("ERROR")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("JESTEM")
        if currentSong < songs.count-1 {
            currentSong += 1
            playThis(thisOne: songs[currentSong])
            songNameLabel.text = songs[currentSong]
            audioPlayer.play()
        }
        else {
            
        }
        
        let state = UIApplication.shared.applicationState
        if state == .background {
            print("App in Background")
            //SEND NOTIFICATION ABOUT NEXT SONG
            scheduleNotification()
           
        }
    }

}

