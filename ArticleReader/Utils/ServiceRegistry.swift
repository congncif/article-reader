//
//  ServiceRegistry.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation

typealias ServiceRegistration<Service> = (ServiceRegistry) -> Service?

final class ServiceRegistry {
    fileprivate static var shared: ServiceRegistry {
        guard let instance = _shared else {
            preconditionFailure("ServiceRegistry must be initialized")
        }
        return instance
    }

    static func initialize() -> ServiceRegistry {
        let newRegistry = ServiceRegistry()
        _shared = newRegistry
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
            preconditionFailure("\(String(describing: Service.self)) not registered. To register service \(Service.self) use injector.register().")
        }

        guard let service = registration(self) else {
            preconditionFailure("\(String(describing: Service.self)) not resolved. To disambiguate optionals use injector.optionalInject().")
        }
        return service
    }

    private var registrations: [String: Any] = [:]

    private static var _shared: ServiceRegistry?

    private init() {}
}

private extension ServiceRegistry {
    func registrationKey<Service>(for subject: Service.Type) -> String {
        return String(describing: subject)
    }

    func locateRegistration<Service>() -> ServiceRegistration<Service>? {
        let key = registrationKey(for: Service.self)
        return registrations[key] as? ServiceRegistration<Service>
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

    /// Return registry for next registration
    func next() -> ServiceRegistry { registry }
}

@propertyWrapper
struct Injected<Service> {
    private var service: Service

    init() {
        service = ServiceRegistry.shared.resolve(Service.self)
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

    private var registry: ServiceRegistry { .shared }

    init() {}

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

    init() {
        service = ServiceRegistry.shared.optional()
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
