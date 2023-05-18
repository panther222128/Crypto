//
//  GCMDecryptorViewController.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/18.
//

import UIKit
import PDFKit
import Combine

final class GCMDecryptorViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var decryptedPDFView: PDFView!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    
    private var viewModel: PDFViewModel!
    private let gcmDecryptor: GCMDecryptor = DefaultGCMDecryptor()
    private var cancellable: Set<AnyCancellable> = Set([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeCurrentPage()
        viewModel.didLoadInitialPage()
    }
    
    static func create(with viewModel: PDFViewModel) -> GCMDecryptorViewController {
        let viewController = GCMDecryptorViewController.instantiateViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    private func presentAlert(of error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error Occured", message: "\(error)", preferredStyle: UIAlertController.Style.alert)
            let addAlertAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(addAlertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func previousPageButtonAction(_ sender: Any) {
        viewModel.didMovePreviousPage()
    }
    
    @IBAction func nextPageButtonAction(_ sender: Any) {
        viewModel.didMoveNextPage()
    }
    
    private func move(to page: PDFPage) {
        decryptedPDFView.autoScales = true
        decryptedPDFView.displayMode = .singlePage
        decryptedPDFView.isUserInteractionEnabled = false
        decryptedPDFView.displaysPageBreaks = false
        decryptedPDFView.document = page.document
        decryptedPDFView.go(to: page)
    }
    
}

extension GCMDecryptorViewController {
    private func subscribeCurrentPage() {
        viewModel.currentPage
            .receive(on: DispatchQueue.main)
            .sink { page in
                self.move(to: page)
            }
            .store(in: &cancellable)
    }
}
