import SwiftUI

struct SearchView: View {
    @Binding var employees: [Employee]
    @State private var searchText = ""

    var filtered: [Employee] {
        if searchText.isEmpty { return [] }
        return employees.filter {
            $0.name.contains(searchText) ||
            $0.team.contains(searchText) ||
            $0.mobilePhone.contains(searchText) ||
            $0.internalPhone.contains(searchText)
        }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // 검색바
                HStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.primary)
                            .font(.system(size: 16, weight: .semibold))
                        TextField(text: $searchText, prompt: Text("이름, 부서, 연락처로 검색").foregroundColor(AppTheme.textSecondary)) {}
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textPrimary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(AppTheme.radiusM)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.background)

                if searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryLight)
                                .frame(width: 72, height: 72)
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                        Text("이름, 부서, 연락처로 검색하세요")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.background)
                                .frame(width: 72, height: 72)
                            Image(systemName: "person.slash")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                        }
                        Text("검색 결과가 없습니다")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filtered) { employee in
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
        }
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
    }

    func toggleFavorite(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            employees[index].isFavorite.toggle()
        }
    }
}
