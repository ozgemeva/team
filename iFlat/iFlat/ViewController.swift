//
//  ViewController.swift
//  iFlat
//
//  Created by Alican Yilmaz on 24/11/2016.
//  Copyright © 2016 SE 301. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference()
        ref.child("Flats").child("Flat1").setValue(["username": "Alican","password":"31"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
