//
//  Auckland_Garbage_CollectionApp.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseFunctions

@main
struct Auckland_Garbage_CollectionApp: App {
    init() {
#if DEBUG && targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
#else
        let providerFactory: AppCheckProviderFactory = AGCAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
#endif

        FirebaseApp.configure()

#if DEBUG && targetEnvironment(simulator)
        Functions.functions().useEmulator(withHost: "localhost", port: 5001)
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
