//
//  WalkthroughPageViewController.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/08/08.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController,UIPageViewControllerDataSource {
    
    var pageContent = ["NearBuddyは「場所」で近くの人とつながることができるSNSです。","実際の現在地にチャットルームを作って近くにいる人と会話したり、近くの誰かのルームに入って会話することができます。","さあ、さっそくログイン後、投稿画面からルームを作成してみましょう！"]
    var pageImage = ["shakeHands1","location_walk","talk4"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let startingVC = viewControllerAtIndex(index: 0){
            setViewControllers([startingVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
        dataSource = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index += 1
        return viewControllerAtIndex(index:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index -= 1
        return viewControllerAtIndex(index:index)
    }
    
    func viewControllerAtIndex(index:Int) -> WalkthroughViewController? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            return pageContentVC
        }
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
}
