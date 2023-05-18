//
//  GCMDecryptorViewModel.swift
//  Crypto
//
//  Created by Jun Ho JANG on 2023/05/18.
//

import Foundation
import Combine
import PDFKit

protocol PDFViewModel {
    var currentPage: PassthroughSubject<PDFPage, Never> { get }
    
    func didLoadInitialPage()
    func didMoveNextPage()
    func didMovePreviousPage()
}

final class DefaultPDFViewModel: PDFViewModel {
    
    private(set) var currentPage: PassthroughSubject<PDFPage, Never>
    private let gcmDecryptor: GCMDecryptor = DefaultGCMDecryptor()
    private var currentPageIndex: Int
    private let pdfDocument: PDFDocument
    private let lastPageIndex: Int
    
    init(pdf: PDF) {
        self.currentPage = PassthroughSubject()
        self.currentPageIndex = pdf.firstPageIndex
        self.pdfDocument = pdf.pdfDocument
        self.lastPageIndex = pdf.lastPageIndex
    }
    
    func didLoadInitialPage() {
        currentPage.send(pdfDocument.page(at: currentPageIndex) ?? PDFPage())
    }
    
    func didMovePreviousPage() {
        if currentPageIndex > 0 && lastPageIndex >= currentPageIndex {
            currentPageIndex -= 1
            let pdfPage = pdfDocument.page(at: currentPageIndex) ?? PDFPage()
            currentPage.send(pdfPage)
        }
    }
    
    func didMoveNextPage() {
        if lastPageIndex > currentPageIndex {
            currentPageIndex += 1
            let pdfPage = pdfDocument.page(at: currentPageIndex) ?? PDFPage()
            currentPage.send(pdfPage)
        }
    }
    
}

