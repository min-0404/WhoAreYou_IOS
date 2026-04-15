import SwiftUI
import Combine

struct TeamView: View {
    @StateObject private var vm = TeamViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.employees.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash").font(.system(size: 48)).foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("팀원 정보가 없습니다").font(.system(size: 15)).foregroundColor(AppTheme.textSecondary)
                    let err = EmployeeRepository.shared.debugLastError
                    if !err.isEmpty { Text(err).font(.system(size: 11)).foregroundColor(.red).multilineTextAlignment(.center).padding(.top, 4) }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vm.groupedTeams, id: \.key) { teamName, members in
                        Section {
                            ForEach(members) { emp in
                                NavigationLink { EmployeeDetailView(empNo: emp.empNo) } label: {
                                    TeamMemberRowView(employee: emp, onFavoriteToggle: { vm.toggleFavorite(emp) })
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowSeparator(.hidden).listRowBackground(Color.clear)
                            }
                        } header: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 2).fill(AppTheme.primary).frame(width: 3, height: 18)
                                Text(teamName).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                                Text("\(members.count)명").font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { await vm.load() }
            }
        }
        .navigationTitle("팀원보기")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }
}

@MainActor
class TeamViewModel: ObservableObject {
    @Published var employees: [Employee] = []
    @Published var isLoading = false

    var groupedTeams: [(key: String, value: [Employee])] {
        Dictionary(grouping: employees, by: { $0.team })
            .sorted { $0.key < $1.key }
    }

    func load() async {
        isLoading = true
        let team = await EmployeeRepository.shared.getMyTeam()
        let favs = await EmployeeRepository.shared.getMyFavorites()
        let favNos = Set(favs.map { $0.empNo })
        employees = team.map { emp in
            var e = emp; e.isFavorite = favNos.contains(emp.empNo); return e
        }
        isLoading = false
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
