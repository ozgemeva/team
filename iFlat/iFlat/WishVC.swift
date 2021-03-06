//
//  WishVC.swift
//  iFlat
//
//  Created by Alican Yilmaz on 01/01/2017.
//  Copyright © 2017 SE 301. All rights reserved.
//

import UIKit

class WishVC: UIViewController,imageMaker {
    
    let dbflat = FIRFlat()
    let dbusr = FIRUSER()
    
      @IBOutlet weak var wishListTV: WishListTableView!
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
wishList()
        
    }

    
 
    
    
    func wishList() {
        
        dbusr.getCurrentLoggedIn { (usr) in
            
            self.dbusr.getWishes(usrID: (usr?.id!)!, completion: { (dict) in
                
                if let dicti = dict {
                    
                    for item in dicti {
                        
                        self.dbflat.getFlatImages(flatID: item.key, completion: { (downloadedImages) in
                                self.wishListTV.flatImages.append((downloadedImages?.first?.imageDownloadURL)!)
                            self.wishListTV.reloadData()
                        })
                        
                        
                    }

                }
                
                else {
                    
                    print("no flat ")
                }
                
                
            })
        }

    }

}
