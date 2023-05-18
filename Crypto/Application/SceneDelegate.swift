//
//  SceneDelegate.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/08.
//

import UIKit
import PDFKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let decryptor: GCMDecryptor = DefaultGCMDecryptor()
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        var decryptedData: Data? = nil
        
        let navigationController = UINavigationController()
        do {
            let data = try loadData()
            try decryptor.decrypt(data, password: "Cera", info: "info")
            decryptedData = decryptor.decryptedData
            guard let pdfDocument = PDFDocument(data: decryptedData ?? Data()) else { return }
            let viewModel = DefaultPDFViewModel(pdf: .init(pdfDocument: pdfDocument, firstPageIndex: 0, lastPageIndex: pdfDocument.pageCount - 1))
            let cryptoViewController = GCMDecryptorViewController.create(with: viewModel)
            
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            navigationController.present(cryptoViewController, animated: true)
        } catch let error {
            print(error)
        }
    }

}

extension SceneDelegate {
    private func loadData() throws -> Data {
        guard let dataPath = Bundle.main.path(forResource: "LargeGCM", ofType: "bin") else {
            throw CBCDecryptorError.cannotCreateFileURL
        }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw CBCDecryptorError.cannotLoadRawData
        }
    }
}
