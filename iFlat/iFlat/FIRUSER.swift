//
//  UserDelegate.swift
//  iFlat
//
//  Created by Alican Yilmaz on 02/12/2016.
//  Copyright © 2016 SE 301. All rights reserved.
//
//Change password and change email not included.
//This class is wroted though FIREBASvarser authendication framework!
//Handle Optionals
import Foundation
import Firebase
import FirebaseStorage

///This protocol is a delegation bridge. When any coder wants to use DB manipulation methods, then the coder must use this bridge instance.
///Coder also need to conform the protocol which is ManipulableUser. If want to use the manipulation methods. Manipulation methods only takes objects which conforms ManipulableUser.
protocol FIRUSERDelegate :class
{
    func insert(usr:ManipulableUser!,completion: @escaping (String?) -> ())
    func edit(newUsr:ManipulableUser!, completion: @escaping (String?) -> ())
    func loginByEmailAndPassword(email:String, password:String, completion:  @escaping (String?) -> ())
    func logout(completion: @escaping (String?) -> ())
    func getCurrentLoggedIn(completion: @escaping (ManipulableUser?) -> ())
    func getByEmail(email:String, completion: @escaping (ManipulableUser?) -> ())
    func sendverificationEmail(completion: @escaping (String?) -> ())
    func isUserVerified(completion: @escaping (Bool) -> ())
    func changePassword(newPassword:String, completion: @escaping (String?) -> ())
    func changeEmail(newEmail:String, completion: @escaping (String?) -> ())
    func insertUserProfileImage(user:ManipulableUser, completion: @escaping (String?) -> ())
    func getUserProfileImg(user:ManipulableUser, completion: @escaping (String?) -> ())
    func rateUser(toUserID:String,rate:Rate, completion: @escaping (String?) -> ())
    func getUserRates(userID:String, completion: @escaping ([Rate]?) -> ())
    func changeUserProfileImage(user:ManipulableUser,img:UIImage, completion: @escaping (String?) -> ())
    func getCities(completion: @escaping ([String]) -> ())
    func forgotPassword(email:String, completion: @escaping (String?) -> ())
    func openIssue(toUser:ManipulableUser, issue:Issue, completion: @escaping (String?) -> ())
    func getISsue(user:ManipulableUser, completion: @escaping([Issue]) -> ())
    func getUserByID(id:String, completion: @escaping(ManipulableUser?) -> ())
    func sendReservationRequest(req:ReservationRequest, completion: @escaping(String?) -> ())
    func acceptReservationRequest(req:ReservationRequest,completion: @escaping(String?) -> ())
    func rejectReservationRequest(req:ReservationRequest,completion: @escaping(String?) -> ())
    func getUsersReservationRequests(usr:ManipulableUser, completion: @escaping([ReservationRequest]) -> ())
    
}




///This class is the object which connects coder to Db for manipulation.
class FIRUSER: FIRUSERDelegate {
    internal func getUsersReservationRequests(usr:ManipulableUser,completion: @escaping([ReservationRequest]) -> ()) {
        var req = ReservationRequest()
        FIRREF.instance().getRef().child("reservationRequests").queryOrdered(byChild: "toU").queryEqual(toValue: usr.id).observe(.value, with: { (ss) in
            let obj = ss.children.allObjects
            for a in obj
            {
                let key = a as! FIRDataSnapshot
                let value = key.value as! [String:Any]
                
                let title = value["title"] as! String
                let content = value["content"] as! String
                let issued = value["issued"] as! String
                let isOpen = value["isopen"] as! Bool
                let answer = value["answer"] as? String
                let issue = Issue(title: title, content: content, issued: issued)
                issue.isOpen = isOpen
                issue.answer = answer
               
                
            }
        
        
        })
    }




    internal func acceptReservationRequest(req: ReservationRequest, completion: @escaping (String?) -> ()) {
        FIRREF.instance().getRef().child("reservationRequests/" + req.id).setValue(1, forKey: "accepted")
    }
    
    internal func rejectReservationRequest(req: ReservationRequest, completion: @escaping (String?) -> ()) {
        FIRREF.instance().getRef().child("reservationRequests/" + req.id).setValue(2, forKey: "accepted")
    }

    internal func sendReservationRequest(req: ReservationRequest, completion: @escaping (String?) -> ()) {
        FIRREF.instance().getRef().child("reservationRequests/" + req.id).setValue(
            [
            "toU": req.toU! as String,
            "flat" : req.flat!,
            "from": req.from!.toTimeStamp(),
            "to" : req.to!.toTimeStamp(),
            "accepted": req.accepted!,
            "date": req.date!
            ]
            
            ) { (err, nil) in
                if err == nil
                {
                    completion(nil)
                }
                else
                {
                    completion(err.debugDescription)
                }
        }
    }

    

    internal func getUserByID(id: String, completion: @escaping (ManipulableUser?) -> ()) {
        let usr = User()
        
        FIRREF.instance().getRef().child("users/" + id).observeSingleEvent(of: .value, with: { snapshot in
            
            if(snapshot.childrenCount >= 1){
                let obj = snapshot.children.allObjects[0] as! FIRDataSnapshot
                let objdict = obj.value as! [String:String]
                usr.id = obj.key
                usr.email = objdict["email"]!
                usr.Gender = objdict["gender"]!
                usr.name = objdict["firstName"]!
                usr.birthDate = objdict["birthdate"]!
                usr.surname = objdict["lastName"]!
                usr.country = objdict["country"]!
                completion(usr)
            }
            else
            {
                completion(nil)
            }
        })
    }

    internal func openIssue(toUser: ManipulableUser, issue: Issue, completion: @escaping (String?) -> ()) {
        let insertingDict = [
            "content": issue.content!,
            "isopen": issue.isOpen!,
            "issued": toUser.id!,
            "title": issue.title!,
            "issuer": issue.issuer!] as [String : Any]
        FIRREF.instance().getRef().child("Issues/" + toUser.id! + "/" + issue.ID!).setValue(insertingDict) { (err, nil) in
            if err == nil
            {
                completion(nil)
            }
            else
            {
                completion(err.debugDescription)
            }
        }
    }

    internal func getISsue(user: ManipulableUser, completion: @escaping ([Issue]) -> ()) {
        var issues = [Issue]()
        FIRREF.instance().getRef().observe(.value, with: { (ss) in
            let obj = ss.children.allObjects
            for a in obj
            {
                let key = a as! FIRDataSnapshot
                let value = key.value as! [String:Any]

                let title = value["title"] as! String
                let content = value["content"] as! String
                let issued = value["issued"] as! String
                let isOpen = value["isopen"] as! Bool
                let answer = value["answer"] as? String
                var issue = Issue(title: title, content: content, issued: issued)
                issue.ID = key.key
                issue.issuer = value["issuer"] as! String
                issue.isOpen = isOpen
                issue.answer = answer
                issues.append(issue)
                
            }
            completion(issues)
        })
    }

   

    internal func forgotPassword(email: String, completion: @escaping (String?) -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (err) in
            if err != nil
            {
                completion(err.debugDescription)
                return
            }
            else
            {
                completion(nil)
                return
            }
        })
    }

    internal func getCities(completion: @escaping ([String]) -> ()) {
        FIRREF.instance().getRef().child("cities").queryOrderedByKey().observe(.value, with: { (ss) in
        var arr = [String]()
        let dict = ss.value as! [String:String]
            for a in dict.values
            {
                arr.append(a)
            }
            let sortedArr = arr.sorted(by: { $0 < $1  })
            completion(sortedArr)
       
        })
    }

    internal func changeUserProfileImage(user: ManipulableUser, img: UIImage, completion: @escaping (String?) -> ()) {
        user.profileImage = img
        insertUserProfileImage(user: user) { (str) in
            completion(str)
        }
    }



   
    
    
    
    internal func getUserRates(userID: String, completion: @escaping ([Rate]?) -> ()) {
        var allRates = [Rate]()
        FIRREF.instance().getRef().child("user_rates/" + userID).observe(.value, with:  { (ss) in
            let allvalues = ss.children.allObjects
            for a in allvalues
            {
                let keyObj = a as! FIRDataSnapshot
                let obj = keyObj.value as! [String:Any]
                let rate = Rate()
                rate.rateID = keyObj.key
                rate.rate = obj["rate"] as! Int?
                rate.from_userID = obj["from"] as! String?
                allRates.append(rate)
            }
            completion(allRates)
            
        })
        
    }
    
    internal func rateUser(toUserID:String, rate: Rate, completion: @escaping (String?) -> ()) {
        FIRREF.instance().getRef().child("user_rates/" + toUserID + "/" + rate.rateID!).setValue(["from" : rate.from_userID!, "rate": rate.rate!]) { (err, nil) in
            if err == nil
            {
                completion(nil)
            }
            else
            {
                completion(err.debugDescription)
                return
            }
        }
        
        
    }

    internal func getUserProfileImg(user: ManipulableUser, completion: @escaping (String?) -> ()) {
        FIRREF.instance().getRef().child("user_profile_images/" + user.id!).observeSingleEvent(of: .value, with: { (ss) in
            let dict = ss.value as! [String:String]
            completion(dict["downloadURL"])
        })
    }



    internal func insertUserProfileImage(user: ManipulableUser, completion: @escaping (String?) -> ()) {
        if let profileImg = user.profileImage
        {
            let imagePNGDataConverter = UIImageJPEGRepresentation(profileImg, 0.1)
            
            FIRREF.instance().getStorageRef().child("user_profile_images/" + user.id! + ".jpeg").put(imagePNGDataConverter!, metadata: nil) { (metadata, error) in
                if (error == nil)
                {
                    FIRREF.instance().getRef().child("user_profile_images/" + user.id!).setValue(
                        ["downloadURL" : metadata?.downloadURL()?.absoluteString]
                        ,withCompletionBlock: { (err, nil) in
                            if err == nil{
                                completion(nil)
                            }
                            else
                            {
                                completion(err.debugDescription)
                                return
                            }
                    })
                }
            }
        }
        else
        {
            completion("user profile image is nil!")
            return
        }
    }

    
    


    
    
    internal func changeEmail(newEmail: String, completion: @escaping (String?) -> ()) {
        
        
        
        FIRAuth.auth()?.currentUser?.updateEmail(newEmail, completion: { (err) in
            if err == nil{
                
                completion(nil)
            }
            else
            {
                completion(err.debugDescription)
                return
            }
        })
    }

    internal func changePassword(newPassword:String,completion: @escaping (String?) -> ()) {
            FIRAuth.auth()?.currentUser?.updatePassword(newPassword, completion: { (err) in
                if err == nil
                {
                    completion(nil)
                }
                else{
                completion(err.debugDescription)
                    return
                }
            })
         }

    internal func isUserVerified(completion: @escaping (Bool) -> ()) {
            let isVerified = FIRAuth.auth()?.currentUser?.isEmailVerified
            completion(isVerified!)
    }

    internal func sendverificationEmail(completion: @escaping (String?) -> ()) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (e) in
            if e == nil
            {
                completion(nil)
            }
            else
            {
                completion(e.debugDescription)
                
            }
        })
    }

    ///Returns a Manipulableuser Instance for a given email. If email exists in DB.
    ///If the user exists, returns it. Otherwise, returns nil.
    ///Returning parameters are in completion block.
    internal func getByEmail(email: String, completion: @escaping (ManipulableUser?) -> ()) {
        let usr = User()

        FIRREF.instance().getRef().child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            
            if(snapshot.childrenCount >= 1){
            let obj = snapshot.children.allObjects[0] as! FIRDataSnapshot
                let objdict = obj.value as! [String:String]
                usr.id = obj.key
                usr.email = objdict["email"]!
                usr.Gender = objdict["gender"]!
                usr.name = objdict["firstName"]!
                usr.birthDate = objdict["birthdate"]!
                usr.surname = objdict["lastName"]!
                usr.country = objdict["country"]!
                
                completion(usr)
            }
            else
            {
                completion(nil)
            }
        })
    }

    ///Returns currently logged user if any.
    ///If the user exists, returns it. Otherwise, returns nil.
    ///Returning parameters are in completion block.
    internal func getCurrentLoggedIn(completion:  @escaping (ManipulableUser?) -> ()) {
        if let loggedUsr = FIRAuth.auth()?.currentUser{
            getByEmail(email: loggedUsr.email!, completion: { (usr) in
                completion(usr)
            })
        }
        else
        {
            completion(nil)

        }
    }
    
    ///Logouts user who is logged in already.
    ///If the user exists, returns true. Otherwise, returns false.
    ///Returning parameters are in completion block.
    internal func logout(completion:  @escaping (String?) -> ()) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            completion("ERROR OCCURED DURING SIGN OUT!")
        }
        completion(nil)
        
        return

    }
    
    ///Logouts user who is logged in already.
    ///If the user exists, returns true. Otherwise, returns false.
    ///Returning parameters are in completion block.
    internal func loginByEmailAndPassword(email: String, password: String, completion:  @escaping (String?) -> ()) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, err) in
            if err != nil{
                completion(err.debugDescription)
                return

            }
            else
            {
                completion(nil)
            }
        })
    }
    ///Edit user info. The parameter newUsr is the new user whos info will replaced by the user which is passed by its email.
    ///If the user exists, returns true. Otherwise, returns false.
    ///Returning parameters are in completion block.
    internal func edit(newUsr: ManipulableUser!, completion:  @escaping (String?) -> ()) {
        getCurrentLoggedIn { (loggedUser) in
            if loggedUser != nil
            {
                FIRREF.instance().getRef().child("users").child((loggedUser?.id!)!).setValue(
                    [
                        "firstName": newUsr.name!,
                        "lastName" : newUsr.surname!,
                        "birthdate": newUsr.birthDate!,
                        "country": newUsr.country!,
                        "email": newUsr.email!,
                        "gender": newUsr.Gender!
                    ]
                )
                self.changeEmail(newEmail: newUsr.email!, completion: { (str) in
                    if str != nil
                    {
                        completion(str)
                    }
                    else
                    {
                        completion(str)
                    }
                })

            }
            else
            {
                completion("No logged in user detected!")
            }
        }
        

        
        
        
    }
    ///Insert user which is manipulableuser.
    ///If the operation is OK, returns true. Otherwise, returns false.
    ///Returning parameters are in completion block.
    ///This func also adds id to the inserted user object.
    internal func insert( usr: ManipulableUser!, completion: @escaping (String?) -> ()) {
        FIRAuth.auth()?.createUser(withEmail: usr.email!, password: usr.password!, completion: { (user, err) in
            if err == nil
            {
                FIRREF.instance().getRef().child("users").child(user!.uid).setValue(
                    [
                    "firstName": usr.name!,
                    "lastName" : usr.surname!,
                    "email": usr.email!,
                    "gender": usr.Gender!,
                    "birthdate": usr.birthDate!,
                    "country": usr.country!
                    ],
                    withCompletionBlock: { (err, ref) in
                        if err == nil{
                            usr.id = user?.uid
                            completion(nil)
                        }
                            
                        else
                        {
                            completion(err.debugDescription)
                            return
                        }
                })

            }
            else {
                completion(err.debugDescription)
                return
            }
        })

    }
}


