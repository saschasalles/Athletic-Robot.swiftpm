import SwiftUI
import UIKit


@main
struct MyApp: App {

    init() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}

