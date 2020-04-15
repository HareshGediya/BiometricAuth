//
//  LocalAuth.swift
//  BiometricAuth
//
//  Created by Haresh Gediya on 15/04/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import Foundation
import LocalAuthentication

public final class LocalAuth: NSObject {
    public static let shared = LocalAuth()
    
    private override init() {
        super.init()
    }
    
    public enum LocalAuthError {
        case success
        case cancel
        case failure(error: String)
    }
    
    public func authentication(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        let reason = "Authentication to access app"
        authenticationWithLocalAuth(reason: reason) { error in
            switch error {
            case .success:
                success()
            case .cancel:
                failure("Auth screen cancel")
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func authenticationWithLocalAuth(reason: String, completion completionHandler: @escaping (LocalAuthError) -> Void) {
        
        let completion = { (error: LocalAuthError) in
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
        
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = TimeInterval(0)
        
        var authError: NSError?
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &authError)
        
        if !canEvaluate || authError != nil {
            let error = self.getLocalAuthError(authError!)
            completion(error)
            return
        }
        
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
            if success {
                completion(.success)
            } else {
                let error = self.getLocalAuthError(authError)
                completion(error)
            }
        }
        
    }
    
    private func getLocalAuthError(_ error: Error?) -> LocalAuthError {
        guard let error = error else {
            return .failure(error: "Unexpected error")
        }
        
        guard let laError = error as? LAError else {
            return .failure(error: error.localizedDescription)
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .failure(error: "You must enable a passcode in your iOS Settings in order to use Auth Lock.")
        case .biometryNotEnrolled:
            return .failure(error: "You must enable a passcode in your iOS Settings in order to use Auth Lock.")
        case .biometryLockout:
            return .failure(error: "Too many failed authentication attempts. Please try again later.")
        case .authenticationFailed:
            return .failure(error: "Authentication failed.")
        case .userCancel, .userFallback, .systemCancel, .appCancel:
            return .cancel
        case .passcodeNotSet:
            return .failure(error: "You must enable a passcode in your iOS Settings in order to use Auth Lock.")
        case .invalidContext, .notInteractive:
            return .failure(error: laError.localizedDescription)
        default:
            return .failure(error: laError.localizedDescription)
        }
        
    }
    
}
