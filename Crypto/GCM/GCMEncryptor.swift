//
//  Crypto.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/09.
//

import Foundation
import CryptoKit

protocol Encryptor {
    var encryptedData: Data? { get }
    var symmetricKey: SymmetricKey? { get }
    
    func encrypt() throws
}

final class DefaultEncryptor: Encryptor {
    
    private let rawData: Data
    private(set) var encryptedData: Data?
    private(set) var symmetricKey: SymmetricKey?
    
    init(rawData: Data, key: SymmetricKey? = nil) {
        self.symmetricKey = key
        self.rawData = rawData
        self.encryptedData = nil
    }
    
    func encrypt() throws {
        if let symmetricKey = symmetricKey {
            try encryptData(key: symmetricKey)
        } else {
            createSymmetricKey()
            guard let symmetricKey = symmetricKey else { throw CryptoKitError.invalidParameter }
            try encryptData(key: symmetricKey)
        }
    }
    
    private func createSymmetricKey() {
        symmetricKey = SymmetricKey(size: .bits256)
    }

    private func encryptData(key: SymmetricKey) throws {
        do {
            let sealedBox = try AES.GCM.seal(rawData, using: key)
            guard let encryptedData = sealedBox.combined else { throw CryptoKitError.invalidParameter }
            self.encryptedData = encryptedData
        } catch let error {
            throw error
        }
    }
    
}
