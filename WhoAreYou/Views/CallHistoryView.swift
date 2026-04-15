import SwiftUI

struct CallHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = ContactStorage.shared
    @State private var showClearAlert = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if storage.callRecords.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(storage.callRecords) { record in
                            CallRecordCard(record: record)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("통화내역")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.primary)
                }
            }
            if !storage.callRecords.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showClearAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
        }
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("통화내역 삭제", isPresented: $showClearAlert) {
            Button("삭제", role: .destructive) { storage.clearCallRecords() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("모든 통화내역을 삭제하시겠습니까?")
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
            Text("통화내역이 없습니다")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("후아유에 등록된 번호와 통화하면\n자동으로 기록됩니다")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Call Record Card

private struct CallRecordCard: View {
    let record: CallRecord

    private var callColor: Color {
        switch record.callType {
        case "incoming": return Color(red: 0x15/255.0, green: 0x65/255.0, blue: 0xC0/255.0)
        case "outgoing": return Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0)
        default:         return Color(red: 0xE5/255.0, green: 0x39/255.0, blue: 0x35/255.0)
        }
    }

    private var callIcon: String {
        switch record.callType {
        case "incoming": return "phone.arrow.down.left"
        case "outgoing": return "phone.arrow.up.right"
        default:         return "phone.down.fill"
        }
    }

    private var callTypeLabel: String {
        switch record.callType {
        case "incoming": return "수신"
        case "outgoing": return "발신"
        default:         return "부재중"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Call type circle
            ZStack {
                Circle()
                    .fill(callColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: callIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(callColor)
            }

            // Center: name, type, team, job
            VStack(alignment: .leading, spacing: 3) {
                Text(record.callerName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(callTypeLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(callColor)

                    if !record.callerTeam.isEmpty {
                        Text(record.callerTeam)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                if !record.callerJob.isEmpty {
                    Text(record.callerJob)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0))
                        .cornerRadius(20)
                }
            }

            Spacer()

            // Right: time + duration
            VStack(alignment: .trailing, spacing: 4) {
                Text(record.formattedTime)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
                Text(record.formattedDuration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.accentGreen)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .cardStyle()
    }
}
