//
//  WalkthroughViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/08/08.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {

    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardBtn: UIButton!
    
    var index = 0
    var imageFileName = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLabel.text = content
        centerImage.image = UIImage(named: imageFileName)
        
        pageControl.currentPage = index
        switch index {
        case 0...1:
            forwardBtn.setImage(UIImage(named: "ahead"), for: UIControlState.normal)
        case 2:
            forwardBtn.setImage(UIImage(named: "check1"), for: UIControlState.normal)
        default:
            break
        }
    }
    
    @IBAction func nextBtn_touchUpInside(_ sender: Any) {
        switch index {
        case 0...1:
            let pageVC = parent as! WalkthroughPageViewController
            pageVC.forward(index: index)
        case 2:
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            
            dismiss(animated: true, completion: nil)
        default:
            print("")
        }
    }

}
