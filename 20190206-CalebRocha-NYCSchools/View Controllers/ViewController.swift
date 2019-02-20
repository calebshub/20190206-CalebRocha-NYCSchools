//
//  ViewController.swift
//  20190206-CalebRocha-NYCSchools
//
//  Created by Caleb Admin on 2/6/19.
//  Copyright © 2019 Caleb Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.welcomeLabel.text = "View NYC Schools"
        self.welcomeLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.welcomeLabel.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BasicSchoolViewController") as! BasicSchoolViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    

}

