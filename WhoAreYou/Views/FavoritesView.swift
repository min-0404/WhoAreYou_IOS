import SwiftUI
import Combine

struct FavoritesView: View {
    @StateObject private var vm = FavoritesViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.employees.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.slash").font(.system(size: 48)).foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("즐겨찾기한 직원이 없습니다").font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.employees) { emp in
                    NavigationLink { EmployeeDetailView(empNo: emp.empNo) } label: {
                        EmployeeRowView(employee: emp, onFavoriteToggle: { vm.toggleFavorite(emp) })
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden).listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .refreshable { await vm.load() }
            }
        }
        .navigationTitle("즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }
}

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var employees: [Employee] = []
    @Published var isLoading = true   // 첫 렌더부터 로딩 상태로 시작

    func load() async {
        isLoading = true
        await Task.yield()  // UI 갱신(ProgressView 표시) 후 네트워크 호출
        employees = await EmployeeRepository.shared.getMyFavorites()
        isLoading = false
    }

    func toggleFavorite(_ employee: Employee) {
        Task {
            let newFav = await EmployeeRepository.shared.toggleFavorite(empNo: employee.empNo, currentIsFavorite: employee.isFavorite)
            if let idx = employees.firstIndex(where: { $0.empNo == employee.empNo }) {
                employees[idx].isFavorite = newFav
                if !newFav { employees.remove(at: idx) }
            }
        }
    }
}
