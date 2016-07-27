//
//  CoordinateHeaderViewController.swift
//  DemoUI
//
//  Created by wizard lee on 7/26/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit
import SnapKit

class CoordinateHeaderViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var accumulator : CGFloat = 0
    var headerTopConstraintY : CGFloat = 0
    let threadshold : CGFloat = 70
    
    var isAnimating = false
    var draging = false
    var lastOffset : CGFloat = 0
    
    var debuging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 2048)
        
        let colors = [UIColor.redColor(),
                     UIColor.orangeColor(),
                     UIColor.yellowColor(),
                     UIColor.greenColor(),
                     UIColor.cyanColor(),
                     UIColor.brownColor(),
                     UIColor.purpleColor(),
                     UIColor.grayColor()]
        for (i, color) in colors.enumerate() {
            let markView = UIView(frame: CGRect(x: 0, y: i*256, width: Int(scrollView.bounds.width), height: 20))
            markView.backgroundColor = color
            scrollView.addSubview(markView)
        }
        
        scrollView.delegate = self
    }
    
    @IBAction func exit(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var toggleView : UIView?
    @IBAction func toggleAddView(sender: UIButton) {
        headerTopConstraint.constant = -threadshold
        accumulator = threadshold
        
        if toggleView == nil {
            print("\(scrollView.constraints.count)")
            toggleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            toggleView?.backgroundColor = UIColor.whiteColor()
            scrollView.addSubview(toggleView!)
            toggleView!.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(scrollView)
                make.leading.equalTo(scrollView)
                make.width.equalTo(200)
                make.height.equalTo(200)
            })
        }
        else {
            print("\(scrollView.constraints.count)")
            toggleView?.removeFromSuperview()
            toggleView = nil
        }
    }
}

extension CoordinateHeaderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isAnimating {
            lastOffset = scrollView.contentOffset.y
            return
        }
        
        let delta = scrollView.contentOffset.y - lastOffset
        
        if delta > 0
            && scrollView.contentOffset.y > 0
            && draging
            && headerTopConstraint.constant > -threadshold {
            
            if (debuging) {
                print("wtf, \(accumulator), \(scrollView.contentOffset.y)")
            }
            
            accumulator += delta
            scrollView.contentOffset.y = lastOffset
            
            accumulator = min(accumulator, threadshold)
            headerTopConstraint.constant = -accumulator
            
        }
        
        if delta < 0
            && scrollView.contentOffset.y < 0
            && draging
            && headerTopConstraint.constant < 0 {
            if (debuging) {
                print("wtf2, \(accumulator), \(scrollView.contentOffset.y)")
            }
            
            if (debuging) {
                print("wtf2.0.1, \(delta)")
            }
            
            accumulator += delta
            scrollView.contentOffset.y = 0
            accumulator = max(0, accumulator)
            if (debuging) {
                print("wtf2.0.2, \(accumulator)")
            }
            
            headerTopConstraint.constant = -accumulator
            if (debuging) {
                print("wtf2.1, \(headerTopConstraint.constant)")
            }
        }
        
        lastOffset = scrollView.contentOffset.y
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        draging = true
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        print("velocity: \(velocity)")
        
        if velocity.y < -0.1 && accumulator >= threadshold {
            isAnimating = true
            accumulator = 0
            headerTopConstraint.constant = 0
            draging = false
            
            UIView.animateWithDuration(0.5,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: { _ in self.isAnimating = false  })
        }
    }
}
