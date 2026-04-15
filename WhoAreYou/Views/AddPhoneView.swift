import SwiftUI

struct AddPhoneView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = ContactStorage.shared
    @State private var showAddSheet = false
    @State private var deleteTarget: CustomContact? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if storage.contacts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(storage.contacts) { contact in
                            ContactCard(contact: contact, onDelete: {
                                deleteTarget = contact
                                showDeleteAlert = true
                            })
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("전화번호 추가")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showAddSheet) {
            AddContactSheet { name, phone, note in
                storage.addContact(CustomContact(
                    id: UUID().uuidString,
                    name: name,
                    phone: phone,
                    note: note
                ))
            }
        }
        .alert("삭제", isPresented: $showDeleteAlert, presenting: deleteTarget) { contact in
            Button("삭제", role: .destructive) {
                storage.deleteContact(id: contact.id)
            }
            Button("취소", role: .cancel) {}
        } message: { contact in
            Text("\(contact.name)(\(contact.phone))를 삭제하시겠습니까?")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 72, height: 72)
                Image(systemName: "phone.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppTheme.primary)
            }
            Text("저장된 번호가 없습니다")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("우측 상단 + 버튼으로 번호를 추가해보세요")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { showAddSheet = true }) {
                Label("전화번호 추가", systemImage: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Contact Card

private struct ContactCard: View {
    let contact: CustomContact
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                ProfileAvatarView(
                    employee: Employee(empNo: contact.id, name: contact.name, team: "", teamCode: "",
                                      position: "", nickname: "", jobTitle: "",
                                      internalPhone: "", mobilePhone: "", fax: "", email: "",
                                      imgdata: nil),
                    size: 52
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(contact.phone)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                    if !contact.note.isEmpty {
                        Text(contact.note)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                    }
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 12)

            Button(action: {
                let cleaned = contact.phone.filter { $0.isNumber || $0 == "+" }
                if let url = URL(string: "tel:\(cleaned)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("전화하기")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(AppTheme.primary)
                    .cornerRadius(AppTheme.radiusS)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .cardStyle()
    }
}

// MARK: - Add Contact Sheet

private struct AddContactSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String, String, String) -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var note = ""

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("이름 *", text: $name)
                    TextField("전화번호 *", text: $phone)
                        .keyboardType(.phonePad)
                }
                Section("메모 (선택)") {
                    TextField("메모", text: $note)
                }
            }
            .navigationTitle("전화번호 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        onSave(
                            name.trimmingCharacters(in: .whitespaces),
                            phone.trimmingCharacters(in: .whitespaces),
                            note.trimmingCharacters(in: .whitespaces)
                        )
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                    .disabled(!canSave)
                }
            }
        }
    }
}
