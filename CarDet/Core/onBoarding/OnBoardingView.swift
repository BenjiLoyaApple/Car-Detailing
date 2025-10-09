//
//  ContentView.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import SwiftUI

struct OnBoardingView: View {
    @Environment(AppState.self) private var root
    
    var body: some View {
        DrawOnSymbolEffectExample(tint: .blue, data: [
            .init(
                name: "car.side",
                title: "Выберите услугу",
                subtitle: "Мойка, химчистка, полировка\nи многое другое — всё в одном месте",
                preDelay: 0.3
            ),
            .init(
                name: "calendar.badge.clock",
                title: "Запишитесь онлайн",
                subtitle: "Быстрая и удобная запись\nна удобное для вас время",
                preDelay: 1.6
            ),
            .init(
                name: "bell.circle",
                title: "Контролируйте процесс",
                subtitle: "Следите за статусом заказа\nи получайте уведомления",
                symbolSize: 65,
                preDelay: 1.2
            ),
        ]) {
            onFinishButtonPressed()
        }
    }
    
    func onFinishButtonPressed() {
        // other logic to complete onboarding
        root.updateViewState(showTabBarView: true)
    }
}

struct DrawOnSymbolEffectExample: View {
    var tint: Color = .blue
    var buttonTitle: String = "Начать"
    var loopDelay: CGFloat = 1
    @State var data: [SymbolData]
    var onTap: () -> ()
    @State private var currentIndex: Int = 0
    @State private var isDisappeared: Bool = false
    var body: some View {
        VStack(spacing: 25) {
            
            Spacer(minLength: 0)
            
            ZStack {
                ForEach(data) { symbolData in
                    if symbolData.drawOn {
                        Image(systemName: symbolData.name)
                            .font(.system(size: symbolData.symbolSize, weight: .regular))
                            .foregroundStyle(.white)
                            .transition(.symbolEffect(.drawOn.individually))
                    }
                }
            }
            .frame(width: 140, height: 140)
            .background {
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(tint.gradient)
            }
            .geometryGroup()
            .padding(.top, 30)
            
            VStack(spacing: 6) {
                Text(data[currentIndex].title)
                    .font(.title2)
                    .lineLimit(1)
                
                Text(data[currentIndex].subtitle)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .contentTransition(.numericText())
            .animation(.snappy(duration: 1, extraBounce: 0), value: currentIndex)
            .fontDesign(.rounded)
            .frame(maxWidth: 300)
            .frame(height: 80)
            .geometryGroup()
            
            Spacer(minLength: 0)
            
            Button(action: onTap) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding(.vertical, 6)
            }
            .tint(tint.opacity(0.7))
            .buttonStyle(.glassProminent)
        }
        .task {
            await loopSymbols()
        }
        .onDisappear {
            isDisappeared = true
        }
    }
    
    private func loopSymbols() async {
        for index in data.indices {
            await loopSymbol(index)
        }
        
        guard !isDisappeared else { return }
        try? await Task.sleep(for: .seconds(loopDelay))
        await loopSymbols()
    }
    
    private func loopSymbol(_ index: Int) async {
        let symbolData = data[index]
        try? await Task.sleep(for: .seconds(symbolData.preDelay))
        data[index].drawOn = true
        currentIndex = index
        try? await Task.sleep(for: .seconds(symbolData.postDelay))
        data[index].drawOn = false
    }
    
    struct SymbolData: Identifiable {
        var id: UUID = UUID()
        var name: String
        var title: String
        var subtitle: String
        var symbolSize: CGFloat = 70
        var preDelay: CGFloat = 1
        var postDelay: CGFloat = 2
        fileprivate var drawOn: Bool = false
    }
}

#Preview {
    OnBoardingView()
        .environment(AppState())
}
