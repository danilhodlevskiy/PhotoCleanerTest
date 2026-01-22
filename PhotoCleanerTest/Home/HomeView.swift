//
//  HomeView.swift
//  PhotoCleanerTest
//
//  Created by danilka on 22.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        VStack {
            HStack() {
                VStack (alignment: .leading) {
                    Text("iPhone Storage")
                    if let totalStorage = vm.totalStorage, let avaliableStorage = vm.usedStorage {
                        (
                            Text(String(format: "%.1f GB", avaliableStorage))
                                .bold()
                            + Text(" of ") +
                            Text(String(format: "%.1f GB", totalStorage))
                        )
                    } else {
                        Text("N/A")
                            .bold()
                        + Text(" of ") +
                        Text("N/A")
                    }
                }
                .foregroundStyle(Color.text)
                .font(.callout)
                
                Spacer()
                
                ZStack {
                    
                    VStack(spacing: 2) {
                        Text(String(format: "%.0f%%", (vm.usedStoragePercent) * 100))
                            .font(.system(size: 24, weight: .semibold))
                            .animation(.none, value: vm.usedStoragePercent)
                        Text("used")
                            .font(.footnote)
                    }
                    .foregroundStyle(.text)
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 14.4)
                            .foregroundStyle(.blue100.opacity(0.5))
                            .shadow(color: .blue800, radius: 6.95)
                        
                        Circle()
                            .trim(from: 0, to: vm.usedStoragePercent)
                            .stroke(style: StrokeStyle(lineWidth: 14.4, lineCap: .round))
                            .rotation(.degrees(-90))
                            .foregroundStyle(.blue950)
                    }
                    .frame(width: 148, height: 148)
                }
                
            }
            .padding(.leading, 12)
            .padding(.trailing, 36)
            .padding(.bottom, 30)
            
            Rectangle()
                .fill(.white)
                .clipShape(.rect(cornerRadii: .init(topLeading: 30, topTrailing: 30)))
                .ignoresSafeArea()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding(.top, 13)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue700)
        .task {
            vm.load()
        }
    }
}

#Preview {
    HomeView()
}
