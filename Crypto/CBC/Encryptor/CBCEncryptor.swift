//
//  CBCEncryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/16.
//

import Foundation
import CryptoSwift

enum EncryptError: Error {
    case cannotLoadData
}

protocol CBCEncryptor {
    var encryptedString: String? { get }
    
    func encrypt() throws
}

final class DefaultCBCEncryptor: CBCEncryptor {
    
    private(set) var encryptedString: String?
    private let initializationVector: String
    private let salt: String
    private let stringKey: String
    
    init(initializationVector: String, salt: String, stringKey: String) {
        self.encryptedString = nil
        self.initializationVector = initializationVector
        self.salt = salt
        self.stringKey = stringKey
    }
    
    func encrypt() throws {
        do {
            let data = try loadData()
            let key = try generateSymmetricKey()
            let iv = generateInitializationVector()
            let aes = try createAESWith(key: key, iv: iv)
            let encryptedData = try aes?.encrypt(data.bytes)
            let base64EncodedData = Data(encryptedData ?? []).base64EncodedString()
            encryptedString = base64EncodedData
            print("Base64: \(encryptedString)")
            
            let base64Data = Data(base64Encoded: base64EncodedData)
            
        } catch let error {
            throw error
        }
    }
    
    private func createAESWith(key: [UInt8], iv: [UInt8]) throws -> AES? {
        do {
            return try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        } catch {
            throw DecryptError.cannotCreateAES
        }
    }
    
    private func generateSymmetricKey() throws -> [UInt8] {
        let salt: [UInt8] = .init(hex: String(salt))
        do {
            let key = try PKCS5.PBKDF2(password: stringKey.bytes, salt: salt, iterations: 100, keyLength: 16, variant: .md5).calculate()
            return key
        } catch let error {
            throw error
        }
    }
    
    private func generateInitializationVector() -> [UInt8] {
        let iv: [UInt8] = .init(hex: String(initializationVector))
        return iv
    }
    
    private func loadData() throws -> Data {
        guard let dataPath = Bundle.main.path(forResource: "TestPDF", ofType: "pdf") else { throw CBCEncryptorError.cannotCreateFileURL }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            let data = try Data(contentsOf: fileURL)
            print(data)
            return data
        } catch {
            throw CBCEncryptorError.cannotLoadRawData
        }
    }
    
}
