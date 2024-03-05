//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 05.03.2024.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "68afc50c-b41f-4243-afbd-ca0690f2a83f") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(_ event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
