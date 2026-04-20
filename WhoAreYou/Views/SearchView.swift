import SwiftUI
import Combine

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // ── 검색창 ────────────────────────────────────────────────────
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 15))
                    TextField("이름, 팀명, 직책으로 검색", text: $vm.keyword)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textPrimary)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                        .focused($isSearchFocused)
                        .onSubmit {
                            vm.search()
                            isSearchFocused = false
                        }
                    if !vm.keyword.isEmpty {
                        Button {
                            vm.keyword = ""
                            vm.employees = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(red: 0.93, green: 0.93, blue: 0.94))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.8), lineWidth: 1.5))

                // 검색 버튼
                Button {
                    vm.search()
                    isSearchFocused = false
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                }
                .disabled(vm.keyword.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(vm.keyword.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)

            // ── 결과 영역 ─────────────────────────────────────────────────
            ZStack {
                AppTheme.background.ignoresSafeArea()
                    .onTapGesture { isSearchFocused = false }

                if vm.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("검색 중...")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.employees.isEmpty && !vm.keyword.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.4))
                        Text("검색 결과가 없습니다")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.employees.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.3))
                        Text("이름, 팀명, 직책을 입력하세요")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
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
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.keyword) { _, _ in
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
            await Task.yield()  // UI에 로딩 인디케이터 즉시 표시
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
