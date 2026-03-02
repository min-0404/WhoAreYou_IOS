import SwiftUI

struct FavoritesView: View {
    @Binding var employees: [Employee]

    var favorites: [Employee] {
        employees.filter { $0.isFavorite }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if favorites.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryLight)
                            .frame(width: 80, height: 80)
                        Image(systemName: "star.slash")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                    }
                    Text("즐겨찾기한 직원이 없습니다")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("팀원보기에서 별표를 눌러 추가하세요")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(favorites) { employee in
                            EmployeeRowView(employee: employee) {
                                toggleFavorite(employee)
                            }
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
    }

    func toggleFavorite(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            employees[index].isFavorite.toggle()
        }
    }
}
