//
//  CBCEncryptor.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/12.
//

import Foundation
import CryptoSwift

enum CBCEncryptorError: Error {
    case cannotCreateFileURL
    case cannotLoadRawData
    case cannotLoadKeyBytes
    case cannotLoadIVBytes
}

protocol CBCEncryptor {
    var encryptedData: Data? { get }
    
    func encrypt() throws
}

final class DefaultCBCEncryptor: CBCEncryptor {
    
    private(set) var encryptedData: Data?
    
    init() {
        self.encryptedData = nil
    }
    
    func encrypt() throws {
        do {
            let data = try loadData()
            let key = try generateSymmetricKey(from: "Cera")
            let iv = try generateIV(from: "BangBus")
            let aes = try createAES(key: key, iv: iv)
            let encryptedData = try aes.encrypt(data.bytes)
            let base64EncodedData = Data(encryptedData).base64EncodedString()
            print(base64EncodedData)
        } catch let error {
            throw error
        }
    }
    
    private func loadData() throws -> Data {
        guard let dataPath = Bundle.main.path(forResource: "Lorem_ipsum", ofType: "pdf") else { throw CBCEncryptorError.cannotCreateFileURL }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw CBCEncryptorError.cannotLoadRawData
        }
    }
    
    private func generateSymmetricKey(from string: String) throws -> Data {
        let keyData = string.data(using: .utf8)
        guard let keyBytes = keyData?.bytes else { throw CBCEncryptorError.cannotLoadKeyBytes }
        let paddedKey = addPadding(keyBytes, size: 32, paddingByte: 0)
        print("Key: Cera, PaddedKey: \(paddedKey)")
        return Data(paddedKey)
    }
    
    private func generateIV(from string: String) throws -> Data {
        let ivData = string.data(using: .utf8)
        guard let ivBytes = ivData?.bytes else { throw CBCEncryptorError.cannotLoadIVBytes }
        let paddedIV = addPadding(ivBytes, size: 16, paddingByte: 0)
        print("Key: BangBus, PaddedKey: \(paddedIV)")
        return Data(paddedIV)
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
