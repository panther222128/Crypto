//
//  CBCDecryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import Foundation
import CryptoSwift

enum CBCDecryptorError: Error {
    case cannotCreateFileURL
    case cannotLoadRawData
    case cannotLoadKeyBytes
    case cannotLoadIVBytes
    case cannotFindData
}

protocol CBCDecryptor {
    var decryptedData: Data? { get }
    
    func decrypt() throws
}

final class DefaultCBCDecryptor: CBCDecryptor {
    
    private(set) var decryptedData: Data?
    
    init() {
        self.decryptedData = nil
    }
    
    func decrypt() throws {
        do {
            let encryptedString = try loadData()
            guard let encryptedData = Data(base64Encoded: encryptedString) else { throw CBCDecryptorError.cannotFindData }
            let key = try generateSymmetricKey(from: "Cera")
            let iv = try generateIV(from: "asjnkgwqkddadhaq")
            let aes = try createAES(key: key, iv: iv)
            let target = encryptedData
            let decryptedData = try aes.decrypt(target.bytes)
            
            self.decryptedData = Data(decryptedData)
        } catch let error {
            throw error
        }
    }
    
    private func loadData() throws -> String {
        guard let dataPath = Bundle.main.path(forResource: "image", ofType: "txt") else { throw CBCDecryptorError.cannotCreateFileURL }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            return contents.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw CBCDecryptorError.cannotLoadRawData
        }
    }
    
    private func generateSymmetricKey(from string: String) throws -> Data {
        let passwordData = Array(string.utf8)
        guard let sizedKey = try? PKCS5.PBKDF2(password: passwordData, salt: [67, 101, 114, 97]).calculate() else { throw CBCEncryptorError.cannotLoadKeyBytes }
        let sizedKeyData = Data(sizedKey)
        
        return sizedKeyData
    }
    
    private func generateIV(from string: String) throws -> Data {
        let ivData = string.data(using: .utf8)
        print("IV: \(string)")
        guard let ivBytes = ivData?.bytes else { throw CBCEncryptorError.cannotLoadIVBytes }
        
        return Data(ivBytes)
    }
    
    private func createAES(key: Data, iv: Data) throws -> CryptoSwift.AES {
        return try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)
    }
    
    private func addPadding(_ array: [UInt8], size: Int, paddingByte: UInt8) -> [UInt8] {
        var paddedArray = array
        
        if paddedArray.count < size {
            let paddingCount = size - paddedArray.count
            let paddingBytes = Array(repeating: paddingByte, count: paddingCount)
            paddedArray.append(contentsOf: paddingBytes)
        }
        
        return paddedArray
    }
    
}
