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

typealias DocumentPersistentContainerProtocol = HoldingsCountable & DocumentStorable & DocumentFetchable

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
        container[index]
    }
    
    func fetch() throws -> [Document] {
        container
    }
}
