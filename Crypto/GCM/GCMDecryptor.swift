//
//  GCMDecryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import Foundation
import CryptoKit

protocol Decryptor {
    var decryptedData: Data? { get }
    
    func decrypt() throws
}

final class DefaultDecryptor: Decryptor {
    
    private let encryptedData: Data
    private(set) var decryptedData: Data?
    private let symmetricKey: SymmetricKey
    
    init(encryptedData: Data, key: SymmetricKey) {
        self.encryptedData = encryptedData
        self.symmetricKey = key
        self.decryptedData = nil
    }

    func decrypt() throws {
        do {
            try decryptData()
        } catch let error {
            throw error
        }
    }
    
    private func decryptData() throws {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            self.decryptedData = decryptedData
        } catch let error {
            throw error
        }
    }
    
}
