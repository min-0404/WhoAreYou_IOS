import SwiftUI

struct EmployeeDetailView: View {
    let empNo: String

    @State private var employee: Employee? = nil
    @State private var isLoading = true
    @State private var isFav = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let emp = employee {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 프로필 헤더
                        VStack(spacing: 12) {
                            ProfileAvatarView(employee: emp, size: 90)

                            Text(emp.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            HStack(spacing: 8) {
                                if !emp.position.isEmpty {
                                    Text(emp.position)
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(AppTheme.primaryLight)
                                        .foregroundColor(AppTheme.primary)
                                        .cornerRadius(20)
                                }
                                if !emp.team.isEmpty {
                                    Text(emp.team)
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }

                            if !emp.nickname.isEmpty {
                                Text(emp.nickname)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.primaryLight)
                                    .cornerRadius(20)
                            }

                            if !emp.jobTitle.isEmpty {
                                Text(emp.jobTitle)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.12, green: 0.28, blue: 0.65))
                                    .padding(.horizontal, 12).padding(.vertical, 5)
                                    .background(Color(red: 0.88, green: 0.93, blue: 1.0))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 16)

                        // 연락처 카드
                        VStack(spacing: 0) {
                            if !emp.internalPhone.isEmpty {
                                ContactRow(icon: "phone.fill", label: "사내전화", value: emp.internalPhone, color: AppTheme.accentGreen, phone: emp.internalPhone)
                                Divider().padding(.leading, 52)
                            }
                            if !emp.mobilePhone.isEmpty {
                                ContactRow(icon: "iphone", label: "휴대전화", value: emp.mobilePhone, color: AppTheme.primary, phone: emp.mobilePhone)
                                if !emp.fax.isEmpty || !emp.email.isEmpty { Divider().padding(.leading, 52) }
                            }
                            if !emp.fax.isEmpty {
                                ContactRow(icon: "printer.fill", label: "팩스", value: emp.fax, color: AppTheme.textSecondary)
                                if !emp.email.isEmpty { Divider().padding(.leading, 52) }
                            }
                            if !emp.email.isEmpty {
                                ContactRow(icon: "envelope.fill", label: "이메일", value: emp.email, color: AppTheme.accentBlue)
                            }
                        }
                        .background(Color.white).cornerRadius(16)
                        .padding(.horizontal, 16)

                        // 전화 버튼
                        if !emp.internalPhone.isEmpty || !emp.mobilePhone.isEmpty {
                            HStack(spacing: 12) {
                                if !emp.internalPhone.isEmpty {
                                    CallButton(label: "사내전화", phone: emp.internalPhone, color: AppTheme.accentGreen)
                                }
                                if !emp.mobilePhone.isEmpty {
                                    CallButton(label: "휴대전화", phone: emp.mobilePhone, color: AppTheme.primary)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 32)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark").font(.system(size: 48)).foregroundColor(AppTheme.textSecondary)
                    Text("정보를 불러올 수 없습니다").foregroundColor(AppTheme.textSecondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(employee?.name ?? "직원 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { toggleFavorite() } label: {
                    Image(systemName: isFav ? "star.fill" : "star")
                        .foregroundColor(isFav ? AppTheme.accentOrange : AppTheme.textSecondary)
                }
            }
        }
        .task { await loadDetail() }
    }

    private func loadDetail() async {
        isLoading = true
        employee = await EmployeeRepository.shared.getDetail(empNo: empNo)
        isFav = employee?.isFavorite ?? false
        isLoading = false
    }

    private func toggleFavorite() {
        guard let emp = employee else { return }
        Task {
            isFav = await EmployeeRepository.shared.toggleFavorite(empNo: emp.empNo, currentIsFavorite: isFav)
            employee?.isFavorite = isFav
        }
    }
}

private struct ContactRow: View {
    let icon: String; let label: String; let value: String; let color: Color
    var phone: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 11)).foregroundColor(AppTheme.textSecondary)
                Text(value).font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
            if let p = phone {
                Button {
                    if let url = URL(string: "tel://\(p.filter { $0.isNumber })") { UIApplication.shared.open(url) }
                } label: {
                    Image(systemName: "phone.fill").foregroundColor(color).font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

private struct CallButton: View {
    let label: String; let phone: String; let color: Color
    var body: some View {
        Button {
            if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") { UIApplication.shared.open(url) }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "phone.fill").font(.system(size: 13))
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(color).cornerRadius(12)
        }
    }
}
