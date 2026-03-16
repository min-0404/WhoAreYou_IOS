import SwiftUI

@main
struct WhoAreYouApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

struct AppRootView: View {
    @State private var isLoggedIn = false
    @State private var loggedInEmployee: Employee? = nil

    var body: some View {
        if isLoggedIn, let employee = loggedInEmployee {
            HomeView(loggedInEmployee: employee, isLoggedIn: $isLoggedIn)
        } else {
            NavigationStack {
                LoginView(isLoggedIn: $isLoggedIn, loggedInEmployee: $loggedInEmployee)
            }
        }
    }
}
