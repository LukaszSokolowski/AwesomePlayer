//
//  FirstViewController.swift
//  AwesomePlayer
//
//  Created by Łukasz Sokołowski on 27/12/2018.
//  Copyright © 2018 Łukasz Sokołowski. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

var songs:[String] = []
var audioPlayer = AVAudioPlayer()
var currentSong = 0
var audioStuffed = false
var numberOf = 0

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate,UNUserNotificationCenterDelegate {

    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gettingSongName()
    }
    
    func gettingSongName() {
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for song in songPath {
                var mySong = song.absoluteString
                
                if mySong.contains(".mp3") {
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count-1]
                    mySong = mySong.replacingOccurrences(of: "%20", with:" ")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with:"")
                    songs.append(mySong)
                }
            }
            myTableView.reloadData()
        }
        catch {
            
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        do {
            let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!)as URL)
           
            audioPlayer.delegate = self
            audioPlayer.play()
            currentSong = indexPath.row
            audioStuffed = true
           
        } catch {
            print("ERROR")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("JESTEM")
        if currentSong < songs.count-1 {
            do {
                currentSong += 1
                let audioPath = Bundle.main.path(forResource: songs[currentSong], ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!)as URL)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } catch {
                print("ERROR")
            }
            
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

