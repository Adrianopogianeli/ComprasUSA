//
//  UIViewController+CoreData.swift
//  ComprasUSA
//
//  Created by admin on 4/21/18.
//  Copyright © 2018 Adriano Pogianeli. All rights reserved.
//

import UIKit
import CoreData


extension UIViewController {

    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
