import Foundation
import CoreImage

protocol HoldingsCountable {
    var count: Int { get }
    var isEmpty: Bool { get }
}

protocol DocumentStorable {
    func store(document: Document)
}

protocol DocumentFetchable {
    func fetch(for index: Int) throws -> Document
    func fetch() throws -> [Document]
}

protocol DocumentDeletable {
    func delete(at index: Int) throws
}

typealias DocumentPersistentContainerProtocol = HoldingsCountable & DocumentStorable & DocumentFetchable & DocumentDeletable

final class DocumentPersistentContainer: DocumentPersistentContainerProtocol {
    // MARK: Properties
    private var container: [Document] = []
    
    var count: Int {
        container.count
    }
    
    var isEmpty: Bool {
        container.isEmpty
    }
    
    // MARK: Interface
    func store(document: Document) {
        guard let index = container.firstIndex(where: { $0.id == document.id }) else {
            container.append(document)
            return
        }
        container[index] = document
    }
    
    func fetch(for index: Int) throws -> Document {
        guard container.isEmpty == false else {
            throw DocumentPersistentContainerError.documentNotFound
        }
        
        guard index >= .zero && index < count else {
            throw DocumentPersistentContainerError.indexOutOfRange
        }
        return container[index]
    }
    
    func fetch() throws -> [Document] {
        guard container.isEmpty == false else {
            throw DocumentPersistentContainerError.documentNotFound
        }
        return container
    }
    
    func delete(at index: Int) throws {
        guard container.isEmpty == false else {
            throw DocumentPersistentContainerError.documentNotFound
        }
        
        guard index >= .zero && index < count else {
            throw DocumentPersistentContainerError.indexOutOfRange
        }
        container.remove(at: index)
    }
}
