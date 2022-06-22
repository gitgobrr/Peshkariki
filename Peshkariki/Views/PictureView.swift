//
//  PictureView.swift
//  Peshkariki
//
//  Created by sergey on 04.05.2022.
//

import UIKit

class PictureView: UIImageView {
    
    // RESIZE IMAGE
    override var intrinsicContentSize: CGSize {
        if let myimg = self.image, let modalViewSize = superview?.frame.size {
            /// aspectFit by default
            self.contentMode = .scaleAspectFit
            let ratio = modalViewSize.width/myimg.size.width
            
            /// if screen width < image width
            if ratio < 1 {
                /// shrinking image
                let shrinkedHeight = myimg.size.height*ratio
                let heightWithPreservedSpace = modalViewSize.height-modalViewSize.height*0.2
                
                /// if shrinked height > than available space for stats
                if shrinkedHeight > heightWithPreservedSpace {
                    /// switch to aspectFill to fill the horizontal edges
                    self.contentMode = .scaleAspectFill
                    return CGSize(width: modalViewSize.width, height: heightWithPreservedSpace)
                }
                
                return CGSize(width: modalViewSize.width, height: myimg.size.height*ratio) //shrinked image
            } else { /// if screen width > image width
                /// scale the image to fit the screen
                let scaledHeight = myimg.size.height*ratio
                let heightWithPreservedSpace = modalViewSize.height-modalViewSize.height*0.2
                
                /// if scaled image height > available space for stats
                if scaledHeight > heightWithPreservedSpace {
                    /// change its height to max available
                    return CGSize(width: modalViewSize.width, height: heightWithPreservedSpace)
                }
                
                return CGSize(width: modalViewSize.width, height: myimg.size.height*ratio) ///scaled image
            }
        }
        
        return CGSize(width: -1, height: -1) /// no image
    }
}
