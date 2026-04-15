import SwiftUI
import Combine

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // 검색창
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").foregroundColor(AppTheme.textSecondary)
                TextField("이름, 팀명, 직책으로 검색", text: $vm.keyword)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit { vm.search() }
                if !vm.keyword.isEmpty {
                    Button { vm.keyword = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .padding(14)
            .background(Color(red: 0.93, green: 0.93, blue: 0.94))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.8), lineWidth: 1.5))
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.white)

            ZStack {
                AppTheme.background.ignoresSafeArea()

                if vm.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.employees.isEmpty && !vm.keyword.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass").font(.system(size: 48)).foregroundColor(AppTheme.textSecondary)
                        Text("검색 결과가 없습니다").font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.employees.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill").font(.system(size: 48)).foregroundColor(AppTheme.textSecondary.opacity(0.4))
                        Text("이름, 팀명, 직책을 입력하세요").font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.employees) { emp in
                        NavigationLink { EmployeeDetailView(empNo: emp.empNo) } label: {
                            EmployeeRowView(employee: emp, onFavoriteToggle: { vm.toggleFavorite(emp) })
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.keyword) { _ in
            if vm.keyword.count >= 2 { vm.search() }
            else if vm.keyword.isEmpty { vm.employees = [] }
        }
    }
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var keyword = ""
    @Published var employees: [Employee] = []
    @Published var isLoading = false

    private var searchTask: Task<Void, Never>?

    func search() {
        guard !keyword.isEmpty else { employees = []; return }
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            let result = await EmployeeRepository.shared.search(keyword: keyword)
            if !Task.isCancelled { employees = result }
            isLoading = false
        }
    }

    func toggleFavorite(_ employee: Employee) {
        Task {
            let newFav = await EmployeeRepository.shared.toggleFavorite(empNo: employee.empNo, currentIsFavorite: employee.isFavorite)
            if let idx = employees.firstIndex(where: { $0.empNo == employee.empNo }) {
                employees[idx].isFavorite = newFav
            }
        }
    }
}
