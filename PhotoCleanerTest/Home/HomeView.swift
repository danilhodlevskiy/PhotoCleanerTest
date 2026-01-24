//
//  HomeView.swift
//  PhotoCleanerTest
//
//  Created by danilka on 22.01.2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        VStack {
            header

            content
        }
        .padding(.top, 13)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue700)
        .task { vm.load() }
    }
}

// MARK: - Sections
private extension HomeView {

    var header: some View {
        HStack {
            StorageHeaderView(
                title: "iPhone Storage",
                totalGB: vm.totalStorage,
                usedGB: vm.usedStorage
            )

            Spacer()

            RingProgressView(
                progress: vm.usedStoragePercent,
                valueText: String(format: "%.0f%%", vm.usedStoragePercent * 100),
                caption: "used"
            )
        }
        .padding(.leading, 12)
        .padding(.trailing, 36)
        .padding(.bottom, 30)
    }

    var content: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .clipShape(.rect(cornerRadii: .init(topLeading: 30, topTrailing: 30)))
                .ignoresSafeArea()
                .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(spacing: 16) {
                FeatureCard(
                    title: "Video Compressor",
                    icon: .majesticonsVideo,
                    iconBackground: .pink600.opacity(0.09),
                    showLock: !vm.isPhotoAuthorizationGranted(),
                    onLockTap: openAppSettings,
                    subtitle: SubtitleState(
                        isLoading: vm.isCalculatingAssetsCount,
                        text: "\(vm.videoCount) Media • N/A GB"
                    )
                ) {
                    Image(.videoPlaceholder)
                        .clipShape(.rect(cornerRadius: 10))
                }

                FeatureCard(
                    title: "Media",
                    icon: .imageIcon,
                    iconBackground: .iconBlue600.opacity(0.09),
                    showLock: !vm.isPhotoAuthorizationGranted(),
                    onLockTap: openAppSettings,
                    subtitle: SubtitleState(
                        isLoading: vm.isCalculatingAssetsCount,
                        text: "\(vm.allAssetsCount) Media • N/A GB"
                    ),
                    trailing: {
                        TrailingActionView(title: "View all")
                    }
                ) {
                    HStack(spacing: 8) {
                        ForEach(1..<3) { id in
                            Image("media_image_\(id)")
                                .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
    }

    func openAppSettings() {
        HapticManager.instance.generateFeedback(.light)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

private struct StorageHeaderView: View {
    let title: String
    let totalGB: Double?
    let usedGB: Double?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)

            storageText
        }
        .foregroundStyle(Color.gray50)
        .font(.callout)
    }

    @ViewBuilder
    private var storageText: some View {
        if let totalGB, let usedGB {
            (Text(String(format: "%.1f GB", usedGB)).bold()
             + Text(" of ")
             + Text(String(format: "%.1f GB", totalGB)))
        } else {
            (Text("N/A").bold()
             + Text(" of ")
             + Text("N/A"))
        }
    }
}

private struct RingProgressView: View {
    let progress: Double
    let valueText: String
    let caption: String

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text(valueText)
                    .font(.system(size: 24, weight: .semibold))
                    .animation(.none, value: progress) // щоб цифри не "пливли"
                Text(caption)
                    .font(.footnote)
            }
            .foregroundStyle(.gray50)

            ZStack {
                Circle()
                    .stroke(lineWidth: 14.4)
                    .foregroundStyle(.blue100.opacity(0.5))
                    .shadow(color: .blue800, radius: 6.95)

                Circle()
                    .trim(from: 0, to: max(0, min(1, progress)))
                    .stroke(style: StrokeStyle(lineWidth: 14.4, lineCap: .round))
                    .rotation(.degrees(-90))
                    .foregroundStyle(.blue950)
            }
            .frame(width: 148, height: 148)
        }
    }
}

private struct FeatureCard<Content: View, Trailing: View>: View {
    let title: String
    let icon: ImageResource
    let iconBackground: Color
    let showLock: Bool
    let onLockTap: () -> Void
    let subtitle: SubtitleState
    
    @ViewBuilder let trailing: () -> Trailing
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        icon: ImageResource,
        iconBackground: Color,
        showLock: Bool,
        onLockTap: @escaping () -> Void,
        subtitle: SubtitleState,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconBackground = iconBackground
        self.showLock = showLock
        self.onLockTap = onLockTap
        self.subtitle = subtitle
        self.trailing = trailing
        self.content = content
    }

    var body: some View {
        VStack(spacing: 21) {
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 16) {
                        iconView
                        Text(title)
                            .font(.custom("Montserrat", size: 20).weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if showLock {
                        LockButton(action: onLockTap)
                    }
                }

                HStack {
                    SubtitleView(state: subtitle)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    trailing()
                }
            }

            content()
        }
        .padding(8)
    }

    private var iconView: some View {
        Image(icon)
            .resizable()
            .frame(width: 16, height: 16)
            .padding(4)
            .background(iconBackground)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private struct SubtitleState {
    let isLoading: Bool
    let text: String
}

private struct SubtitleView: View {
    let state: SubtitleState

    var body: some View {
        if state.isLoading {
            HStack(spacing: 4) {
                ProgressView()
                Text("Calculating...")
                    .font(.callout)
                    .foregroundStyle(.gray700)
            }
        } else {
            Text(state.text)
                .font(.callout)
                .foregroundStyle(.gray700)
        }
    }
}

private struct LockButton: View {
    let action: () -> Void

    var body: some View {
        Image(.lockFilled)
            .padding(6)
            .background(.red100)
            .clipShape(Circle())
            .onTapGesture(perform: action)
    }
}

private struct TrailingActionView: View {
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            Image(systemName: "chevron.right")
                .fontWeight(.semibold)
        }
        .font(.callout)
        .foregroundStyle(.gray700)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}

