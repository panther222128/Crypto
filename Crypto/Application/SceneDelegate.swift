//
//  SceneDelegate.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/08.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        let cryptoViewController = CBCDecryptorViewController.instantiateViewController()
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        navigationController.present(cryptoViewController, animated: true)
    }

}

