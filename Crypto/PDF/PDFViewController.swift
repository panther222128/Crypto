//
//  PDFViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/10.
//

import UIKit
import PDFKit

final class PDFViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var pdfImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPDFFile()
    }

    private func loadPDFFile() {
        if let path = Bundle.main.path(forResource: "Lorem_ipsum", ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
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
                        pdfImageView.image = image
                    }
                }
            } catch {
                
            }
        }
    }
    
}
