//
//  GCMDecryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import Foundation
import CryptoKit

enum GCMDecryptorError: Error {
    case cannotCreateKeyData
    case cannotCreateInfoData
}

protocol GCMDecryptor {
    var decryptedData: Data? { get }
    
    func decrypt(_ encrypted: Data, password: String, info: String) throws
}

final class DefaultGCMDecryptor: GCMDecryptor {
    
    private(set) var decryptedData: Data?
    
    init() {
        self.decryptedData = nil
    }

    func decrypt(_ encrypted: Data, password: String, info: String) throws {
        let salt = createSalt(from: encrypted)
        let iv = createInitializationVector(from: encrypted)
        let tag = createTag(from: encrypted)
        let text = createCipherText(from: encrypted)
        
        let symmetricKey = createKey(of: password)
 
        do {
            guard let infoData = info.data(using: .utf8) else { throw GCMDecryptorError.cannotCreateInfoData }
            let derivedKey = CryptoKit.HKDF<SHA512>.deriveKey(inputKeyMaterial: symmetricKey, salt: salt, info: infoData, outputByteCount: 32)
            
            let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: iv), ciphertext: text, tag: tag)
            let decryptedData = try AES.GCM.open(sealedBox, using: derivedKey)
            
            self.decryptedData = decryptedData
        } catch let error {
            throw error
        }
    }
    
    private func createSalt(from data: Data) -> Data {
        let salt = data.subdata(in: 0..<32)
        return salt
    }
    
    private func createInitializationVector(from data: Data) -> Data {
        let iv = data.subdata(in: 32..<44)
        return iv
    }
    
    private func createTag(from data: Data) -> Data {
        let tag = data.subdata(in: 44..<60)
        return tag
    }
    
    private func createCipherText(from data: Data) -> Data {
        let text = data.subdata(in: 60..<data.count)
        return text
    }
    
    private func createKey(of string: String) -> SymmetricKey {
        let keyData = string.bytes
        let symmetricKey = SymmetricKey(data: keyData)
        return symmetricKey
    }

}
