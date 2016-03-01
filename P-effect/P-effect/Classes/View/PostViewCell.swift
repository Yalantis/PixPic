//
//  PostViewCell.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import SDWebImage
import MHPrettyDate

protocol PostViewCellDelegate: class {
    
    func didChooseCellWithUser(user: User)
}

class PostViewCell: UITableViewCell {
    
    static let identifier = "PostViewCellIdentifier"
    static let designedHeight: CGFloat = 78
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    var selectionClosure: ((cell: PostViewCell) -> Void)?
    
    var selectionClosure2: ((cell: PostViewCell) -> Void)?

    
    let imageLoader = ImageLoaderService()
    weak var delegate: PostViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .None
    }
    
    func configure(withPost post: Post?) {
        guard let post = post else {
            postImageView.image = UIImage.placeholderImage()
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        profileLabel.text = post.user?.username
        dateLabel.text = MHPrettyDate.prettyDateFromDate(
            post.createdAt,
            withFormat: MHPrettyDateShortRelativeTime
        )
        profileImageView.layer.cornerRadius = (profileImageView.frame.size.width) / 2
        
        let indicator = UIActivityIndicatorView().addActivityIndicatorOn(view: postImageView)
        postImageView.sd_setImageWithURL(
            NSURL(string: post.image.url!),
            placeholderImage: UIImage.placeholderImage()) { _, _, _, _ -> Void in
                indicator.removeFromSuperview()
            }

        guard let user = post.user else {
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        if let avatar = user.avatar?.url {
            profileImageView.sd_setImageWithURL(
                NSURL(string: avatar),
                placeholderImage: UIImage.avatarPlaceholderImage(),
                completed: nil
            )
        }
    }
    
    dynamic private func profileTapped(recognizer: UIGestureRecognizer) {
        selectionClosure?(cell: self)
    }
    
    @IBAction func jjjjj(sender: AnyObject) {
        selectionClosure2?(cell: self)

//        let alertController = UIAlertController(
//            title: "Results wasn't saved",
//            message: "Do you want to save result to the photo library?",
//            preferredStyle: .ActionSheet
//        )
//        
//        let saveAction = UIAlertAction(title: "Save", style: .Default) { [weak self] _ in
//            guard let this = self else {
//                return
//            }
//            print("saveAction")
//        }
//        alertController.addAction(saveAction)
//        
//        let dontSaveAction = UIAlertAction(title: "Don't save", style: .Default) { [weak self] _ in
//            print("saveAction")
//
//        }
//        alertController.addAction(dontSaveAction)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        self.superview.presentViewController(alertController, animated: true, completion: nil)

    }
    
}