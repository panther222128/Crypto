//
//  CBCDecryptorViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import UIKit
import PDFKit
import CryptoSwift

final class CBCDecryptorViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var decryptedImageView: UIImageView!
    
    private var decryptor: CBCDecryptor = DefaultCBCDecryptor(decryptKey: .init(initializationVector: "", salt: "", stringKey: ""))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
//            let str = try loadData()
            
            decryptor = DefaultCBCDecryptor(decryptKey: .init(initializationVector: "67633b905aeab212583a3cfdbb14bd96", salt: "2426234a5a8715e7d0b940bfe5e34ed8", stringKey: "img-encrypt-key"))
            
            try decryptor.makeEncryptedString()
            try decryptor.decrypt()
            
            let data = decryptor.decryptedData
            loadPDF(data: data ?? Data())
        } catch let error {
            presentAlert(of: error)
        }
    }

    private func addExtension(to path: String) -> String {
        let pathExtension = (path as NSString).pathExtension
        if pathExtension.isEmpty {
            let extendedPath = (path as NSString).appendingPathComponent("bin")
            return extendedPath
        }
        return path
    }
    
//    private func loadData() throws -> String {
//        guard let dataPath = Bundle.main.path(forResource: "Encrypted", ofType: nil) else {
//            throw CBCDecryptorError.cannotCreateFileURL
//        }
//        let extendedPath = addExtension(to: dataPath)
//        let fileURL = URL(fileURLWithPath: extendedPath)
//        do {
//            let contents = try String(contentsOf: fileURL, encoding: .utf8)
//            return contents.trimmingCharacters(in: .whitespacesAndNewlines)
//        } catch {
//            throw CBCDecryptorError.cannotLoadRawData
//        }
//    }
    
    private func presentAlert(of error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error Occured", message: "\(error)", preferredStyle: UIAlertController.Style.alert)
            let addAlertAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(addAlertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func loadPDF(data: Data) {
        guard let pdfDocument = PDFDocument(data: data) else {
            // Handle error when loading PDF document
            return
        }
        
        guard let page = pdfDocument.page(at: 0) else {
            // Handle error when retrieving first page of the PDF document
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: page.bounds(for: .mediaBox))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(context.format.bounds)
            
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: 0.0, y: context.format.bounds.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            page.draw(with: .mediaBox, to: context.cgContext)
            
            context.cgContext.restoreGState()
        }
        
        decryptedImageView.image = image
    }
    
}
