//
//  CoordinateHeaderViewController.swift
//  DemoUI
//
//  Created by wizard lee on 7/26/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

class CoordinateHeaderViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var accumulator : CGFloat = 0
    var headerTopConstraintY : CGFloat = 0
    let threadshold : CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1024)
        
        for i in 0..<4 {
            let markView = UIView(frame: CGRect(x: 0, y: i*256, width: Int(scrollView.bounds.width), height: 2))
            scrollView.addSubview(markView)
        }
        
        scrollView.delegate = self
    }
    
    @IBAction func exit(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CoordinateHeaderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if accumulator < threadshold && scrollView.contentOffset.y > 0{
            accumulator += scrollView.contentOffset.y
            print("accumulator set : \(accumulator)")
            
            headerTopConstraint.constant = max(-accumulator, -threadshold)
            print("constant : \(headerTopConstraint.constant)")
            scrollView.contentOffset.y = 0
        }
        
        if scrollView.contentOffset.y < 0 && accumulator >= 0 {
            accumulator += scrollView.contentOffset.y
            print("accumulator set : \(accumulator)")
            headerTopConstraint.constant =  min(-accumulator, 0)
            print("constant : \(headerTopConstraint.constant)")
            scrollView.contentOffset.y = 0
        }
    }
}
