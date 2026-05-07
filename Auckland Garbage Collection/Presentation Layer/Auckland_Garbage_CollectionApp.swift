//
//  Auckland_Garbage_CollectionApp.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct Auckland_Garbage_CollectionApp: App {
    init() {
#if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
#else
        let providerFactory: AppCheckProviderFactory = AGCAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
#endif

        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
