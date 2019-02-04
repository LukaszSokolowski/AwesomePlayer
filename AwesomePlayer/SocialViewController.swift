//
//  SocialViewController.swift
//  AwesomePlayer
//
//  Created by Łukasz Sokołowski on 28/01/2019.
//  Copyright © 2019 Łukasz Sokołowski. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class SocialViewController: UIViewController  {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var urlForImage: String = ""
    var idUser: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.isHidden = true
      
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logOut()
        
        loginManager.logIn(readPermissions: [.publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("LOGGED IN!")
                print("GRANTED PERMISSIONS: \(grantedPermissions)")
                print("DECLINED PERMISSIONS: \(declinedPermissions)")
                print("ACCESS TOKEN \(accessToken)")
                if AccessToken.current != nil {
                    if let userID = AccessToken.current?.userId {
                        self.urlForImage = "https://graph.facebook.com/\(userID)/picture?type=large"
                        self.idUser = userID
                    }
                }
                
                let url = URL(string: self.urlForImage)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self.profilePicture.image = image
                    self.profilePicture.reloadInputViews()
                    self.profilePicture.isHidden = false
                }
            }
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
