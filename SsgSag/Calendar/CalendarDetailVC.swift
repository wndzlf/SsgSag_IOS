//
//  CalendarDetailVC.swift
//  SsgSag
//
//  Created by admin on 04/01/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class CalendarDetailVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard(name: "Calendar", bundle: nil)
        let prevVC = storyBoard.instantiateViewController(withIdentifier: "DetailPoster")
        
        
    }
    
}
