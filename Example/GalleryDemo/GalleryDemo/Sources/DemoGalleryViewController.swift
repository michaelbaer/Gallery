//
//  DemoGalleryViewController.swift
//  GalleryDemo
//
//  Created by mb on 21.03.17.
//  Copyright © 2017 mb
//

import UIKit
import Gallery

class DemoGalleryViewController: GalleryController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  override var prefersStatusBarHidden: Bool {
    get {
      return false
    }
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
