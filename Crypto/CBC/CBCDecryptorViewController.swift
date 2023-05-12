//
//  CBCDecryptorViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import UIKit
import PDFKit

final class CBCDecryptorViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var decryptedImageView: UIImageView!
    
    private let decryptor: CBCDecryptor = DefaultCBCDecryptor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try decryptor.decrypt()
            let data = decryptor.decryptedData
            DispatchQueue.main.async {
                let string = String(data: data!, encoding: .utf8)
                print(string)
//                self.loadPDF(data: data ?? Data())
            }
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
    
    private func loadPDF(data: Data) {
        let pdfDocument = PDFDocument(data: data)
        let pageSize = pdfDocument?.page(at: 0)?.bounds(for: .mediaBox)
        UIGraphicsBeginImageContext(pageSize?.size ?? CGSize())
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            guard let pageSize = pageSize else { return }
            context.translateBy(x: (0.0), y: pageSize.height)
            context.scaleBy(x: 1.0, y: -1.0)
            pdfDocument?.page(at: 0)?.draw(with: .mediaBox, to: context)
            context.restoreGState()
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                decryptedImageView.image = image
            }
        }
    }
    
}
