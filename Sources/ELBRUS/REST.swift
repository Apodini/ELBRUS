//
//  REST.swift
//  
//
//  Created by Tom Mirwald on 20.11.19.
//

// MARK: Imports
import Foundation
import Combine
import CodableKit

// MARK: Typealiases
/// defines an element that can be handled over a REST property wrapper
public typealias RESTElement = Identifiable & Codable & Comparable & Hashable & Reflectable
/// defines an element that can be filtered through a REST property wrapper
public typealias Filterable = Comparable & Reflectable & ReflectionDecodable & CustomStringConvertible & Codable
/// defines an element that can be sorted through a REST property wrapper
public typealias Sortable = Comparable & Reflectable & ReflectionDecodable & CustomStringConvertible & Codable

// MARK: - propertyWrapper @REST
/// The property wrapper is used for automatic observation of a connected data structure that is automatically synchronized with the specified server endpoint in the `Service` variable. Filtering, Sorting or Caching the data structure is optional and can be configured with the initialisation.
/// - Paramaters:
///     - Element: specifies the type of the data structure that needs to be observed, it confirms to `RESTElement` which ensures that the data structure supports the needed functionality
///     - F: specifies the type of the data structure where a filter is applied on,  it confirms to `Filterable` which ensures that the data structure supports the needed functionality
///     - S: specifies the type of the data strucutre that will be sorted,  it confirms to `Sortable` which ensures that the data structure supports the needed functionality
///     - ID: specifies the type of the ID from the `Element`
@propertyWrapper public class REST
    <Element: RESTElement,
    N: NetworkHandler,
    F: Filterable,
    S: Sortable,
ID: CustomStringConvertible >: LocalFileStorable where Element.ID == ID? {
    
    
    private var cancelGet: AnyCancellable?
    private var cancelPost: AnyCancellable?
    private var cancelPut: AnyCancellable?
    private var cancelDelete: AnyCancellable?
    
    private enum NetworkRequest {
        case get
        case put
        case post
        case delete
    }
    
    private let service: Service<N>
    private let filterStrategy: FilterStrategy<Element, F>
    private let sortStrategy: SortStrategy<Element, S>
    private var caching = false
    
    private var _wrappedValue: [Element] = []
    
    private var publisher: CurrentValueSubject<[Element], Never>
    
    /// `storagePath` specifies the appendix of the storage location in the caching process.
    public var storagePath: String = ""
    
    // MARK: - init
    /// `init` is used for the configuration of the wanted functionality, to specifiy the server endpoint with the network service and optional filtering, sorting and cahcing.
    public init(_ service: Service<N>,
                filterStrategy: FilterStrategy<Element, F>,
                sortStrategy: SortStrategy<Element, S>,
                caching: Bool = false) {
        self.service = service
        self.publisher = CurrentValueSubject(_wrappedValue)
        self.filterStrategy = filterStrategy
        self.sortStrategy = sortStrategy
        self.caching = caching
        
        precondition(self.wrappedValue.isEmpty, "You can not initialize a @REST Property Wrapper with an initial non empty Array")
        
        switch filterStrategy {
        case .none:
            break
        default:
            filter()
        }
        
        switch sortStrategy {
        case .none:
            break
        default:
            sort()
        }
        
        if caching {
            storagePath = "\(Self.self)" + (service.urlComponents.string ?? service.url.absoluteString)
            _wrappedValue = loadFromFile()
        }
        
        cancelGet = handleNetworkChangeAndSetLocalData(networkRequest: .get)
    }
    
    // MARK: - wrappedValue
    /// The wrappedValue is the observed data structure and represents the connected data. This data will be synchronized with the server endpoint.
    public var wrappedValue: [Element] {
        get { _wrappedValue }
        set {
            var difference = calculateDifference(new: newValue, old: _wrappedValue)
            handleElementEdit(difference: difference, setterValue: newValue)
            difference = calculateDifference(new: newValue, old: _wrappedValue)
            handleArrayEdit(difference: difference, setterValue: newValue)
            
            switch filterStrategy {
            case .none:
                break
            default:
                filter()
            }
            
            switch sortStrategy {
            case .none:
                break
            default:
                sort()
            }
            
            if caching {
                saveToFile(wrappedValue)
            }
            
            publisher.send(_wrappedValue)
        }
    }
    
    
    // MARK: - instance methods
    
    /// Calculates the difference from to arrays, recognizes variable changes with assocations and returns the difference
    /// - Parameters:
    ///    - new: Defines the new array with changes
    ///    - old: Defines the old array
    /// - Returns: A CollectionDiffernence bbject with the corresponding differnce.
    private func calculateDifference(new: [Element], old: [Element]) -> CollectionDifference<Element> {
        return new.difference(from: old).inferringMoves()
    }
    
    
    /// Refreshs the service data when an element is edited
    /// - Parameters:
    ///     - difference: Contains the difference to track a possible variable change
    ///     - setterValue: Contains the newValue that the property observer returns
    /// -  Returns: Returns true if an element was edited and false if not
    private func handleElementEdit(difference: CollectionDifference<Element>, setterValue: [Element]) {
        for case let .insert(_, newElement, association) in difference.insertions where association == nil {
            for case let .remove(_, oldElement, _) in difference.removals where newElement.id == oldElement.id {
                cancelPut = handleNetworkChangeAndSetLocalData(
                    networkRequest: .put,
                    setterValue: setterValue,
                    newElement: newElement,
                    oldElement: oldElement)
            }
        }
    }
    
    
    /// Refreshs the data when an element is inserted or removed
    /// - Parameters:
    ///     - difference: Contains the difference to track a possible variable change
    ///     - setterValue: Contains the newValue that the property observer returns
    private func handleArrayEdit(difference: CollectionDifference<Element>, setterValue: [Element]) {
        for change in difference {
            switch change {
            case let .remove(_, oldElement, association):
                if association == nil {
                    cancelDelete = handleNetworkChangeAndSetLocalData(networkRequest: .delete, setterValue: setterValue, oldElement: oldElement)
                }
            case let .insert(_, newElement, association):
                if association == nil {
                    let replaceArray = _wrappedValue.filter { $0.id == newElement.id }
                    
                    if !replaceArray.isEmpty {
                        cancelPut = handleNetworkChangeAndSetLocalData(
                            networkRequest: .put,
                            setterValue: setterValue,
                            newElement: newElement,
                            oldElement: replaceArray.first)
                    } else {
                        cancelPost = handleNetworkChangeAndSetLocalData(networkRequest: .post, setterValue: setterValue, newElement: newElement)
                    }
                }
            }
        }
    }
    
    /// Contains the functions for the change on the service and modifies the wrappedValue accordingly
    /// - Parameters:
    ///     - networkRequest: Contains the type of network request
    ///     - setterValue: Contains the newValue that the property observer returns
    ///     - newElement: Contains the new element that a CollectionDifference object holds
    ///     - oldElement: Contains the old element that a CollectionDifference object holds
    /// - Returns: Returns an AnyCancellable object to avaible the network requests to finish
    private func handleNetworkChangeAndSetLocalData(
        networkRequest: NetworkRequest,
        setterValue: [Element] = [],
        newElement: Element? = nil,
        oldElement: Element? = nil) -> AnyCancellable? {
        
        var cancelRequest: AnyCancellable?
        
        switch networkRequest {
        case .get:
            return internalGet()
        case .put:
            if let newElement = newElement {
                if let oldElement = oldElement {
                    cancelRequest = internalPut(newElement)
                    self._wrappedValue.removeAll { $0.id == oldElement.id }
                    self._wrappedValue.append(newElement)
                }
            }
            return cancelRequest
        case .post:
            if let newElement = newElement {
                cancelRequest = internalPost(newElement)
                //post data change is applied internally due appending the network request response
            }
            return cancelRequest
        case .delete:
            if let oldElement = oldElement {
                cancelRequest = internalDelete(oldElement)
                self._wrappedValue.removeAll { $0.id == oldElement.id }
            }
            return cancelRequest
        }
    }
    
    
    // MARK: - Already configured network requests to perform the change on the service
    
    private func internalGet() -> AnyCancellable {
        return service.networkHandler.get(on: service.urlComponents.url ?? service.url)
            .receive(on: RunLoop.main)
            .replaceError(with: [])
            .assign(to: \._wrappedValue, on: self)
    }
    
    private func internalPost(_ element: Element) -> AnyCancellable {
        return service.networkHandler
            .post(element, on: service.url)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { response in
                    self._wrappedValue.append(response)
            })
    }
    
    private func internalPut(_ element: Element) -> AnyCancellable {
        if let id = element.id {
            return service.networkHandler
                .put(element, on: service.append(route: id.description))
                .sink(receiveCompletion: { _ in },
                      receiveValue: { _ in
                })
        } else {
            return internalPost(element)
        }
    }
    
    //TODO: remove force unwrap
    private func internalDelete(_ element: Element) -> AnyCancellable {
        return service.networkHandler
            .delete(at: service.append(route: element.id!.description))
            .replaceError(with: ())
            .sink(receiveValue: { _ in
            })
    }
}


// MARK: Extension: REST: filtering
extension REST {
    
    /// Either appends queries to the Service URL or performs filtering local
    private func filter() {
        
        switch filterStrategy {
        case .none:
            break
        case let .server(filter, filterServerStrategy):
            if !filter.applied {
                if let filterServerStrategy = filterServerStrategy {
                    service.append(queryStrategy: filter.applyServerStrategy(from: filterServerStrategy))
                } else {
                    if let serviceFilterServerStrategy = service.filterServerStrategy {
                        service.append(queryStrategy: filter.applyServerStrategy(from: serviceFilterServerStrategy))
                    } else {
                        service.append(queryStrategy: filter.applyServerStrategy(from: defaultFilterServerStrategy))
                    }
                }
                
                filter.applied = true
            }
            cancelGet = handleNetworkChangeAndSetLocalData(networkRequest: .get)
            fallthrough
        case .client(let filter):
            for operation in filter.operations {
                switch operation {
                case let .gte((property, value)):
                    _wrappedValue = _wrappedValue.filter({ $0[keyPath:property] >= value })
                case let .lte((property, value)):
                    _wrappedValue = _wrappedValue.filter({ $0[keyPath:property] <= value })
                case let .exists((property, value)):
                    _wrappedValue = _wrappedValue.filter({ $0[keyPath:property] == value })
                }
            }
        }
    }
}

// MARK: Extension: REST: sorting
extension REST {
    
    /// Either appends queries to the Service URL or performs sorting local
    private func sort() {
        switch sortStrategy {
        case .none:
            break
        case let .server(sorter, sorterServerStrategy):
            if !sorter.applied {
                if let sorterServerStrategy = sorterServerStrategy {
                    service.append(queryStrategy: [sorter.applyServerStrategy(from: sorterServerStrategy)])
                } else {
                    if let serviceSortServerStrategy = service.sortServerStrategy {
                        service.append(queryStrategy: [sorter.applyServerStrategy(from: serviceSortServerStrategy)])
                    } else {
                        service.append(queryStrategy: [sorter.applyServerStrategy(from: defaultSortServerStrategy)])
                    }
                }
                
                sorter.applied = true
            }
            cancelGet = handleNetworkChangeAndSetLocalData(networkRequest: .get)
            fallthrough
        case .client(let sorter):
            switch sorter.direction {
            case .asc:
                _wrappedValue = _wrappedValue.sorted(on: sorter.property, by: <)
            case .desc:
                _wrappedValue = _wrappedValue.sorted(on: sorter.property, by: >)
            }
        }
    }
}
