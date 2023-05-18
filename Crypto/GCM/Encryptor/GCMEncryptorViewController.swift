//
//  GCMEncryptorViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/18.
//

import UIKit

final class GCMEncryptorViewController: UIViewController, StoryboardInstantiable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func presentAlert(of error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error Occured", message: "\(error)", preferredStyle: UIAlertController.Style.alert)
            let addAlertAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(addAlertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
