import SwiftUI

@main
struct WhoAreYouApp: App {
    @State private var isLoggedIn = false
    @State private var loggedInEmployee: Employee? = nil

    var body: some Scene {
        WindowGroup {
            if isLoggedIn, let employee = loggedInEmployee {
                HomeView(loggedInEmployee: employee, isLoggedIn: $isLoggedIn)
            } else {
                NavigationStack {
                    LoginView(isLoggedIn: $isLoggedIn, loggedInEmployee: $loggedInEmployee)
                }
            }
        }
    }
}
