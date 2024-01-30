import Foundation

protocol ScanDocumentUseCase {
    func scan(document: Document) async -> Result<Document, Error>
}
