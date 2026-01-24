//
//  OnboardingView.swift
//  PhotoCleanerTest
//
//  Created by danilka on 24.01.2026.
//

import SwiftUI

enum OnboardingPage: Int, CaseIterable, Identifiable {
    case cleanStorage, detectSimilar, videoCompressor
    var id: Int { rawValue }
}

struct OnboardingPageModel: Identifiable {
    let id: OnboardingPage
    let imageName: String
    let title: String
    let subtitle: String
    let overlay: AnyView?

    init(
        id: OnboardingPage,
        imageName: String,
        title: String,
        subtitle: String,
        overlay: AnyView? = nil
    ) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.overlay = overlay
    }
}

struct OnboardingView: View {
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @State private var currentPage: OnboardingPage = .cleanStorage

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 30) {
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(
                            pageContent: page,
                            showOverlay: currentPage == .videoCompressor
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                PageIndicatorView(
                    count: pages.count,
                    selectedIndex: currentPage.rawValue
                )
                .padding(.horizontal, 16)
            }

            PrimaryButton(title: "Continue") {
                withAnimation(.smooth) {
                    nextPage()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 44)
        .padding(.bottom, 16)
    }

    private func nextPage() {
        withAnimation {
            switch currentPage {
            case .cleanStorage:
                HapticManager.instance.generateFeedback(.light)
                currentPage = .detectSimilar
            case .detectSimilar:
                HapticManager.instance.generateFeedback(.light)
                currentPage = .videoCompressor
            case .videoCompressor:
                HapticManager.instance.generateFeedback(.success)
                showOnboarding.toggle()
            }
        }

    }
    
    private let pages: [OnboardingPageModel] = [
        .init(
            id: .cleanStorage,
            imageName: "Onboarding_Image_1",
            title: "Clean your Storage",
            subtitle: "Pick the best & delete the rest"
        ),
        .init(
            id: .detectSimilar,
            imageName: "Onboarding_Image_2",
            title: "Detect Similar Photos",
            subtitle: "Clean similar photos & videos, save your storage space on your phone."
        ),
        .init(
            id: .videoCompressor,
            imageName: "Onboarding_Image_3",
            title: "Video Compressor",
            subtitle: "Find large videos or media files and compress them to free up storage space",
            overlay: AnyView(IphoneStorageOverlay())
        )
    ]
}

private struct OnboardingPageView: View {
    let pageContent: OnboardingPageModel
    let showOverlay: Bool

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 31) {
                Image(pageContent.imageName)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .bottom) {
                        if showOverlay, let overlay = pageContent.overlay {
                            overlay
                        }
                    }
                    .animation(.none, value: showOverlay)

                DividerGlow()
                    .padding(.horizontal, 16)
            }

            VStack(spacing: 8) {
                Text(pageContent.title)
                    .font(.system(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text(pageContent.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray600)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct PageIndicatorView: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                let isSelected = index == selectedIndex

                RoundedRectangle(cornerRadius: 50)
                    .fill(isSelected ? .purple700 : .gray200)
                    .frame(width: isSelected ? 16 : 8, height: 8)
                    .animation(.smooth(duration: 0.2), value: selectedIndex)
            }
        }
    }
}

private struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundStyle(.gray50)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(.purple700)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}

private struct DividerGlow: View {
    var body: some View {
        Ellipse()
            .frame(height: 1)
            .blur(radius: 5)
    }
}

fileprivate struct IphoneStorageOverlay: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("Iphone Storage")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.gray950)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ProgressBar(progress: progress, fillColor: .red700)

                HStack {
                    Text("\(Int(progress * 100))% Used")
                        .font(.custom("Montserrat", size: 12).weight(.medium))
                        .foregroundStyle(.gray950)
                        .animation(.none, value: progress)

                    Spacer()

                    (
                        Text("240 GB")
                            .fontWeight(.semibold)
                            .foregroundColor(.purple700)
                        +
                        Text(" Used of 256 GB")
                            .fontWeight(.medium)
                            .foregroundColor(.gray600)
                    )
                    .font(.custom("Montserrat", size: 12))
                }
            }
        }
        .padding(8)
        .frame(width: 284, height: 80)
        .background(.white)
        .clipShape(.rect(cornerRadius: 10))
        .compositingGroup()
        .shadow(color: .gray950.opacity(0.15), radius: 3.8)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                progress = 0.96
            }
        }
    }
}

private struct ProgressBar: View {
    let progress: Double
    let fillColor: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundStyle(.gray200)

                Capsule()
                    .foregroundStyle(fillColor)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    OnboardingView()
}

