import Foundation
import CoreImage

protocol HoldingsCountable {
    var count: Int { get }
}

protocol DocumentStorable {
    func store(document: Document)
}

protocol DocumentResolvable {
    func resolve(for index: Int) -> Document
    func resolve() -> [Document]
}

typealias DocumentPersistentContainerProtocol = HoldingsCountable & DocumentStorable & DocumentResolvable

final class DocumentPersistentContainer: DocumentPersistentContainerProtocol {
    // MARK: Properties
    private var container: [Document] = []
    
    var count: Int {
        container.count
    }
    
    // MARK: Interface
    func store(document: Document) {
        container.append(document)
    }
    
    func resolve(for index: Int) -> Document {
        container[index]
    }
    
    func resolve() -> [Document] {
        container
    }
}
