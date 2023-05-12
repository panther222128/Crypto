//
//  CryptoViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/08.
//

import UIKit

final class CryptoViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var decryptedImageView: UIImageView!
    
    private var data: Data?
    private var encryptor: Encryptor?
    private var decryptor: Decryptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try setupData()
        } catch let error {
            presentAlert(of: error)
        }
        
        setupEncryptor()
        encrypt()
        print("Encrypted: \(String(describing: encryptor?.encryptedData))")

        setupDecryptor()
        decrypt()
        print("Decrypted: \(String(describing: decryptor?.decryptedData))")

        DispatchQueue.main.async {
            guard let decryptedData = self.decryptor?.decryptedData else { return }
            let dataImage = UIImage(data: decryptedData)

            self.decryptedImageView.image = dataImage
        }
        
    }
    
    static func create() -> CryptoViewController {
        let view = CryptoViewController.instantiateViewController()
        return view
    }
    
    private func encrypt() {
        do {
            try encryptor?.encrypt()
        } catch let error {
            presentAlert(of: error)
        }
    }
    
    private func decrypt() {
        do {
            try decryptor?.decrypt()
        } catch let error {
            presentAlert(of: error)
        }
    }
    
    private func setupEncryptor() {
        guard let data = data else { return }
        encryptor = DefaultEncryptor(rawData: data)
    }
    
    private func setupDecryptor() {
        guard let encryptedData = encryptor?.encryptedData else { return }
        guard let symmetricKey = encryptor?.symmetricKey else { return }
        decryptor = DefaultDecryptor(encryptedData: encryptedData, key: symmetricKey)
    }
    
    private func setupData() throws {
        guard let dataPath = Bundle.main.path(forResource: "Lorem_ipsum", ofType: "pdf") else { return }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            data = try Data(contentsOf: fileURL)
        } catch let error {
            throw error
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
