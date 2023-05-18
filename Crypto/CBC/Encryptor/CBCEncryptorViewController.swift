//
//  CBCEncryptorViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import UIKit

final class CBCEncryptorViewController: UIViewController, StoryboardInstantiable {
    
    private let cbcEncryptor: CBCEncryptor = DefaultCBCEncryptor(initializationVector: "2e0b84417212d5ad161318a5fc769963", salt: "4e9ff003a7ab28ac25931151219c4f3c", stringKey: "img-encrypt-key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try cbcEncryptor.encrypt()
        } catch let error {
            presentAlert(of: error)
        }
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
