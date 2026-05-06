//
//  ContentView.swift
//  Auckland Garbage Collection
//
//  Created by Lancy Norbert Fernandes on 06/05/26.
//

import SwiftUI
import FirebaseAppCheck
import FirebaseFunctions

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                let test = try await BinDatesRepository().getAucklandBinDates(propertyId: "12343839101")
                print(test)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
