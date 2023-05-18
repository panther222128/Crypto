//
//  CBCDecryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/16.
//

import Foundation
import CryptoSwift

enum DecryptError: Error {
    case cannotFindBase64EncodedString
    case cannotFindDecryptedArray
    case cannotFindDecryptedString
    case cannotCreateAES
}

protocol CBCDecryptor {
    var decryptedData: Data? { get }
    
    func makeEncryptedString() throws
    func decrypt() throws
}

struct CBCDecryptKey {
    let initializationVector: String
    let salt: String
    let stringKey: String
}

final class DefaultCBCDecryptor: CBCDecryptor {

    private(set) var decryptedData: Data?
//    private var encryptedString: String
    private var encryptedString: String?
    private let initializationVector: String
    private let salt: String
    private let stringKey: String
    
//    init(encryptedString: String, decryptKey: CBCDecryptKey) {
//        self.encryptedString = encryptedString
//        self.initializationVector = decryptKey.initializationVector
//        self.salt = decryptKey.salt
//        self.stringKey = decryptKey.stringKey
//        self.decryptedData = nil
//    }
    
    init(decryptKey: CBCDecryptKey) {
        self.encryptedString = nil
        self.initializationVector = decryptKey.initializationVector
        self.salt = decryptKey.salt
        self.stringKey = decryptKey.stringKey
        self.decryptedData = nil
    }
    
    func decrypt() throws {
        let key = try generateSymmetricKey()
        let iv = generateInitializationVector()
        let aes = try createAESWith(key: key, iv: iv)
        
        let stringToDecrypt = String(encryptedString ?? "")
//        let stringToDecrypt = String(encryptedString.suffix(encryptedString.count - 64))
        guard let dataToDecrypt = Data(base64Encoded: stringToDecrypt) else { throw DecryptError.cannotFindBase64EncodedString }
        
        let encrypted: [UInt8] = Array(dataToDecrypt)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let decrypted = try aes?.decrypt(encrypted)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = endTime - startTime
        print("복호화에 걸린 시간: \(elapsedTime) 초")
        
        guard let decryptedStr = String(bytes: decrypted ?? [], encoding: .utf8) else { throw DecryptError.cannotFindDecryptedArray }
        guard let data = Data(base64Encoded: decryptedStr) else { throw DecryptError.cannotFindDecryptedString }
        
        decryptedData = data
    }
    
    private func createAESWith(key: [UInt8], iv: [UInt8]) throws -> AES? {
        do {
            return try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        } catch {
            throw DecryptError.cannotCreateAES
        }
    }
    
    private func generateSymmetricKey() throws -> [UInt8] {
        let salt: [UInt8] = .init(hex: salt)
//        let salt: [UInt8] = .init(hex: String(encryptedString.prefix(32)))
        do {
            let key = try PKCS5.PBKDF2(password: stringKey.bytes, salt: salt, iterations: 100, keyLength: 16, variant: .md5).calculate()
            return key
        } catch let error {
            throw error
        }
    }
    
    private func generateInitializationVector() -> [UInt8] {
        let iv: [UInt8] = .init(hex: initializationVector)
//        let iv: [UInt8] = .init(hex: String(encryptedString.prefix(64).suffix(32)))
        return iv
    }
    
}

extension DefaultCBCDecryptor {
    func makeEncryptedString() throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            encryptedString = try decodeBase64Data()
        } catch let error {
            throw error
        }
    }
    
    private func decodeBase64Data() throws -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let data = try loadData()
            let base64Encoded = data.base64EncodedString()
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let elapsedTime = endTime - startTime
            
            return base64Encoded
        } catch let error {
            throw error
        }
    }
    
    private func loadData() throws -> Data {
        guard let dataPath = Bundle.main.path(forResource: "large", ofType: "bin") else {
            throw CBCDecryptorError.cannotCreateFileURL
        }
        let extendedPath = addExtension(to: dataPath)
        let fileURL = URL(fileURLWithPath: extendedPath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw CBCDecryptorError.cannotLoadRawData
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
    
}
