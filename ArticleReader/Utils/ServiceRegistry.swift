//
//  ServiceRegistry.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation

typealias ServiceRegistration<Service> = (ServiceRegistry) -> Service?

final class ServiceRegistry {
    struct Domain: Hashable, RawRepresentable, Equatable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }

        static let shared = Domain(rawValue: "__SHARED__")
    }

    private static var containers: [Domain: ServiceRegistry] = [:]

    static func container(_ domain: Domain = .shared) -> ServiceRegistry {
        if let registry = containers[domain] {
            return registry
        }

        var newRegistry: ServiceRegistry
        if domain != .shared {
            newRegistry = ServiceRegistry(parent: .container(.shared))
        } else {
            newRegistry = ServiceRegistry()
        }
        containers[domain] = newRegistry
        return newRegistry
    }

    @discardableResult
    func register<Service>(_ serviceRegistration: @escaping ServiceRegistration<Service>) -> RegistrationOptions<Service> {
        let key = registrationKey(for: Service.self)
        registrations[key] = serviceRegistration
        return RegistrationOptions<Service>(registry: self)
    }

    @discardableResult
    func register<Service>(_ serviceRegistration: @escaping () -> Service) -> RegistrationOptions<Service> {
        let registration: ServiceRegistration<Service> = { _ in
            serviceRegistration()
        }
        return register(registration)
    }

    func optional<Service>(_ serviceType: Service.Type = Service.self) -> Service? {
        let registration: ServiceRegistration<Service>? = locateRegistration()
        return registration?(self)
    }

    func resolve<Service>(_ serviceType: Service.Type = Service.self) -> Service {
        guard let registration: ServiceRegistration<Service> = locateRegistration() else {
            preconditionFailure("\(String(describing: Service.self)) not registered.")
        }

        guard let service = registration(self) else {
            preconditionFailure("\(String(describing: Service.self)) not resolved. The service might be nil.")
        }
        return service
    }

    private var registrations: [String: Any] = [:]

    private let parent: ServiceRegistry?

    private init(parent: ServiceRegistry? = nil) {
        self.parent = parent
    }
}

private extension ServiceRegistry {
    func registrationKey<Service>(for subject: Service.Type) -> String {
        return String(describing: subject)
    }

    func locateRegistration<Service>() -> ServiceRegistration<Service>? {
        let key = registrationKey(for: Service.self)

        var fullRegistrations: [String: Any] = [:]

        var cursor: ServiceRegistry? = self
        while let iCursor = cursor {
            fullRegistrations.merge(iCursor.registrations) { child, _ in child }
            cursor = iCursor.parent
        }

        return fullRegistrations[key] as? ServiceRegistration<Service>
    }
}

final class RegistrationOptions<Service> {
    weak var registry: ServiceRegistry!

    init(registry: ServiceRegistry) {
        self.registry = registry
    }

    @discardableResult
    func implements<ProjectedType>(_: ProjectedType.Type) -> RegistrationOptions<Service> {
        registry.register { registry -> ProjectedType? in
            let service: Service? = registry.optional()
            return service as? ProjectedType
        }
        return self
    }

    @discardableResult
    func register<Service>(_ serviceRegistration: @escaping ServiceRegistration<Service>) -> RegistrationOptions<Service> {
        registry.register(serviceRegistration)
    }

    @discardableResult
    func register<Service>(_ serviceRegistration: @escaping () -> Service) -> RegistrationOptions<Service> {
        registry.register(serviceRegistration)
    }
}

@propertyWrapper
struct Injected<Service> {
    private var service: Service

    init(registry: ServiceRegistry = .container()) {
        service = registry.resolve(Service.self)
    }

    var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }

    var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper
struct LazyInjected<Service> {
    private var service: Service!

    private var registry: ServiceRegistry

    init(registry: ServiceRegistry = .container()) {
        self.registry = registry
    }

    var isEmpty: Bool {
        return service == nil
    }

    var wrappedValue: Service {
        mutating get {
            if self.service == nil {
                let locatedService: Service = registry.resolve()
                service = locatedService
            }
            return service
        }
        mutating set { service = newValue }
    }

    var projectedValue: LazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }

    mutating func release() {
        service = nil
    }
}

@propertyWrapper
struct OptionalInjected<Service> {
    private var service: Service?

    init(registry: ServiceRegistry = .container()) {
        service = registry.optional()
    }

    var wrappedValue: Service? {
        get { return service }
        mutating set { service = newValue }
    }

    var projectedValue: OptionalInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}
