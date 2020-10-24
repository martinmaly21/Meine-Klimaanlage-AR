//
//  ErrorManager.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import UIKit

struct Errors {
    public enum GenericError {
        case unknown
        case noInernet
        case signingOut
    }
    
    public enum OnboardingError {
        //creating an account
        case invalidEmail
        case passwordsDontMatch
        case passwordNotStrongEnough
        
        //if user does not fill out all fields
        case missingfields
    }
}

class ErrorManager {
    static let shared = ErrorManager()
    
    static func showOnboardingError(with type: Errors.OnboardingError, on viewController: UIViewController) {
        let errorText: String
        switch type {
        case .invalidEmail:
            errorText = "You have entered an invalid email."
        case  .passwordsDontMatch:
            errorText = "The passwords you have entered don't match."
        case .passwordNotStrongEnough:
            errorText = "The password you entered isn't strong enough. It must be at least 8 characters, contain one symbol, one number, and one upper case letter."
        case .missingfields:
            errorText = "One or more of the fields is empty. Please fill them out, and try again."
        }
        
        let errorController = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorController.addAction(okayAction)
        
        viewController.present(errorController, animated: true, completion: nil)
    }
    
    static func showFirebaseError(with description: String, on viewController: UIViewController) {
        let errorController = UIAlertController(
            title: "Error",
            message:description,
            preferredStyle: .alert
        )
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorController.addAction(okayAction)
        
        viewController.present(errorController, animated: true, completion: nil)
    }
    
    //App errors
    static func showMissingFieldsForQuoteError(on viewController: UIViewController) {
        let errorController = UIAlertController(
            title: "Error",
            message: "You must fill out all fields to proceed.",
            preferredStyle: .alert
        )
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorController.addAction(okayAction)
        
        viewController.present(errorController, animated: true, completion: nil)
    }
    
    static func showCannotOpenEmail(on viewController: UIViewController) {
        let errorController = UIAlertController(
            title: "Error",
            message: "Cannot open mail app. Have you set up your email with the mail app yet?",
            preferredStyle: .alert
        )
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorController.addAction(okayAction)
        
        viewController.present(errorController, animated: true, completion: nil)
    }
    
    static func showGenericError(with genericError: Errors.GenericError, on viewController: UIViewController) {
        let errorText: String
        
        switch genericError {
        case .unknown:
            errorText = "An unknown error occurred."
        case .noInernet:
            errorText = "It appears you have no internet connection. Please connect, and try again."
        case .signingOut:
            errorText = "There was an error signing you out. Please try again."
        }
        
        
        let errorController = UIAlertController(
            title: "Error",
            message: errorText,
            preferredStyle: .alert
        )
        
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        errorController.addAction(okayAction)
        
        viewController.present(errorController, animated: true, completion: nil)
    }
}


