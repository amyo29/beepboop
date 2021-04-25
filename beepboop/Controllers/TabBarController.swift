//
//  TabBarController.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/25/21.
//

import UIKit

class TabBarController: UITabBarController {
    
   let numberOfTabs: CGFloat = 4
   let tabBarHeight: CGFloat = 60

   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
    
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
    self.tabBarItem.imageInsets = UIEdgeInsets(top: 5.5, left: 0, bottom: -5.5, right: 0)
        self.tabBar.barTintColor = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
    

       // updateSelectionIndicatorImage()
   }

   override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()

      // updateSelectionIndicatorImage()
   }

   func updateSelectionIndicatorImage() {
       let width = tabBar.bounds.width
       var selectionImage = UIImage(named:"TealGradient.png")
       let tabSize = CGSize(width: width/numberOfTabs, height: tabBarHeight)

       UIGraphicsBeginImageContext(tabSize)
       selectionImage?.draw(in: CGRect(x: 0, y: 0, width: tabSize.width, height: tabSize.height))
       selectionImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       tabBar.selectionIndicatorImage = selectionImage
   }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
