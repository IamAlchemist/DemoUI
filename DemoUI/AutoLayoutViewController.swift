//
//  AutoLayoutViewController.swift
//  DemoUI
//
//  Created by wizard lee on 8/8/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

class AutoLayoutViewController: UIViewController {
    
    var chapterNumber = 1
    var book = Book()
    
    // views
    let avatarView = AvatarView()
    let bookTextView = UITextView()
    let chapterLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        book.loadChapter(chapterNumber)
        
        updateViews()   // load the views with book data
        
        colorViews()    // color views for reference
        addGestures()   // swipe gestures to turn the page
        
        addViews()      // add the sub views to the main view
        setupFrames()   // setup view frames
        
    }
}
