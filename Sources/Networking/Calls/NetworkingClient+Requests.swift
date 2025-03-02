//
//  NetworkingClient+Requests.swift
//
//
//  Created by Sacha on 13/03/2020.
//

import Foundation
import Combine

public extension NetworkingClient {

    func getRequest(_ route: String, params: Params = Params()) -> NetworkingRequest {
        request(.get, route, params: params)
    }

    func postRequest(_ route: String, params: Params = Params()) -> NetworkingRequest {
        request(.post, route, params: params)
    }

    func putRequest(_ route: String, params: Params = Params()) -> NetworkingRequest {
        request(.put, route, params: params)
    }
    
    func patchRequest(_ route: String, params: Params = Params()) -> NetworkingRequest {
        request(.patch, route, params: params)
    }

    func deleteRequest(_ route: String, params: Params = Params()) -> NetworkingRequest {
        request(.delete, route, params: params)
    }

    internal func request(_ httpVerb: HTTPVerb, _ route: String, params: Params = Params()) -> NetworkingRequest {
        let req = NetworkingRequest()
        req.httpVerb             = httpVerb
        req.route                = route
        req.params               = params

        let updateRequest = { [weak req, weak self] in
            guard let self = self else { return }
            req?.baseURL              = self.baseURL
            req?.logLevels            = self.logLevels
            req?.headers              = self.headers
            req?.parameterEncoding    = self.parameterEncoding
            req?.sessionConfiguration = self.sessionConfiguration
            req?.timeout              = self.timeout
        }
        updateRequest()
        req.requestRetrier = { [weak self] in
            self?.requestRetrier?($0, $1)?
                .handleEvents(receiveOutput: { _ in
                    updateRequest()
                })
                .eraseToAnyPublisher()
        }
        return req
    }
}
