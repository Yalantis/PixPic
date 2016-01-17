//
//  SaverService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Jack Lapin. All rights reserved.
//

import Foundation

class SaverService {
    
    //MARK: - public
    
    func saveAndUploadPost(file: PFFile, comment: String?) {
        file.saveInBackgroundWithBlock(
            { (succeeded, error) -> () in
                if succeeded {
                    print("Saved!")
                    SaverService.upload(file, comment: comment)
                } else if let _ = error {
                    //TODO : handle error with response!!
                }
            }, progressBlock: { percent in
                print("Uploaded: \(percent)%")
            }
        )
    }
    
    private class func upload(file: PFFile, comment: String?) {
        if let user = User.currentUser() {
            let post = PEFPostModel(image: file, user: user, comment: comment).post
            post.saveInBackgroundWithBlock{ succeeded, error in
                if succeeded {
                    AlertService.simpleAlert("Upload successful!")
                } else {
                    if let error = error?.userInfo["error"] as? String {
                        //TODO : handle error with response!!
                        print(error)
                    }
                }
            }
        } else {
           // TODO: - plug in Auth Service
           // AuthService.logIn()
        }
    }
}
