import SwiftUI

struct TeamView: View {
    @Binding var employees: [Employee]

    // 팀별로 그룹핑
    var groupedByTeam: [String: [Employee]] {
        Dictionary(grouping: employees, by: { $0.team })
    }

    var teamNames: [String] {
        groupedByTeam.keys.sorted()
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(teamNames, id: \.self) { teamName in
                        // 팀 헤더
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.primary)
                                .frame(width: 3, height: 18)
                            Text(teamName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text("\(groupedByTeam[teamName]?.count ?? 0)명")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 6)

                        ForEach(groupedByTeam[teamName] ?? []) { employee in
                            EmployeeRowView(employee: employee) {
                                toggleFavorite(employee)
                            }
                        }
                    }
                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            } // VStack
        } // ZStack
        .navigationTitle("팀원보기")
        .navigationBarTitleDisplayMode(.inline)
    }

    func toggleFavorite(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            employees[index].isFavorite.toggle()
        }
    }
}
