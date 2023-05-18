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

final class DataCBCEncryptor {
    
    private(set) var encryptedString: String?
    
    init() {
        self.encryptedString = nil
    }
    
    func encrypt() throws {
        do {
            let data = try loadData()
            let key = try generateSymmetricKey(from: "Cera")
            let iv = try generateIV(from: "asjnkgwqkddadhaq")
            let aes = try createAES(key: key, iv: iv)
            let encryptedData = try aes.encrypt(data.bytes)
            let base64EncodedData = Data(encryptedData).base64EncodedString()
            print(base64EncodedData)
            encryptedString = base64EncodedData
        } catch let error {
            throw error
        }
    }
    
    private func loadData() throws -> Data {
        guard let dataPath = Bundle.main.path(forResource: "Cera", ofType: "txt") else { throw CBCEncryptorError.cannotCreateFileURL }
        let fileURL = URL(fileURLWithPath: dataPath)
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw CBCEncryptorError.cannotLoadRawData
        }
    }
    
    private func generateSymmetricKey(from string: String) throws -> Data {
        let passwordData = Array(string.utf8)
        let salt = Array<UInt8>.init(hex: String(string.prefix(32)))
        guard let sizedKey = try? PKCS5.PBKDF2(password: passwordData, salt: salt).calculate() else { throw CBCEncryptorError.cannotLoadKeyBytes }
        let sizedKeyData = Data(sizedKey)
        print(sizedKeyData.bytes)
        return sizedKeyData
    }
    
    private func generateIV(from string: String) throws -> Data {
        let ivData = string.data(using: .utf8)
        guard let ivBytes = ivData?.bytes else { throw CBCEncryptorError.cannotLoadIVBytes }
        print(ivBytes)
        return Data(ivBytes)
    }
    
    private func createAES(key: Data, iv: Data) throws -> CryptoSwift.AES {
        return try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes))
    }

}
