//
//  WidgetPromoModal.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 21.2.2026.
//
//
//import SwiftUI
//
//// MARK: - Modal View
//
//struct WidgetPromoModal: View {
//    @Binding var isPresented: Bool
//    var onUpgrade: () -> Void
//
//    var body: some View {
//        ZStack {
//            // Soft dimmed background
//            Color.black.opacity(0.35)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    dismiss()
//                }
//
//            // Card
//            VStack(spacing: 0) {
//
//                // Top illustration area
//                ZStack {
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(
//                            LinearGradient(
//                                colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.7)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .frame(height: 130)
//
//                    HStack(spacing: 16) {
//                        widgetPreview(icon: "calendar", label: "Tänään Jäljellä")
//                        widgetPreview(icon: "menucard", label: "Ruokalistat")
//                    }
//                    .padding(.horizontal)
//                }
//
//                // Text content
//                VStack(spacing: 10) {
//                    Text("Widgetit kotinäytölle")
//                        .font(.title3)
//                        .fontWeight(.bold)
//
//                    Text("Näe TJ ja päivän ruokalista yhdellä vilkaisulla ilman sovelluksen avaamista.")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//                .padding(.horizontal, 24)
//                .padding(.top, 22)
//                .padding(.bottom, 8)
//
//                // CTAs
//                VStack(spacing: 10) {
//                    Button {
//                        dismiss()
//                        onUpgrade()
//                    } label: {
//                        Text("Hanki Premium")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 14)
//                            .background(Color.indigo.gradient)
//                            .foregroundStyle(.white)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("Älä enää näytä viestiä uudelleen")
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                            .padding(.vertical, 6)
//                    }
//                }
//                .padding(.horizontal, 24)
//                .padding(.top, 8)
//                .padding(.bottom, 24)
//            }
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//            .shadow(color: .black.opacity(0.18), radius: 24, y: 8)
//            .padding(.horizontal, 32)
//        }
//    }
//
//    private func widgetPreview(icon: String, label: String) -> some View {
//        VStack(spacing: 6) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundStyle(.white)
//            Text(label)
//                .font(.system(size: 9, weight: .medium))
//                .foregroundStyle(.white.opacity(0.85))
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//        }
//        .frame(width: 72, height: 80)
//        .background(.white.opacity(0.15))
//        .clipShape(RoundedRectangle(cornerRadius: 14))
//    }
//
//    private func dismiss() {
//        withAnimation(.easeIn(duration: 0.2)) {
//            isPresented = false
//        }
//    }
//}
//
//// MARK: - ViewModifier
//
//struct WidgetPromoModalModifier: ViewModifier {
//    @State private var isPresented = false
//    @State private var navigateToPaywall = false
//    let serviceStartDate: Date?
//
//    private let storageKey = "widgetPromoShown_v1"
//
//    private func daysSinceServiceStart() -> Int {
//        guard let startDate = serviceStartDate else { return 0 }
//        return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .onAppear {
//                if !UserDefaults.standard.bool(forKey: storageKey) && daysSinceServiceStart() >= 7 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                        withAnimation(.spring(duration: 0.4)) {
//                            isPresented = true
//                        }
//                        UserDefaults.standard.set(true, forKey: storageKey)
//                    }
//                }
//            }
//            .overlay {
//                if isPresented {
//                    WidgetPromoModal(isPresented: $isPresented) {
//                        navigateToPaywall = true
//                    }
//                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
//                    .zIndex(100)
//                }
//            }
//            .navigationDestination(isPresented: $navigateToPaywall) {
//             
//                RevenueCatPaywallView()
//            }
//    }
//}
//
//extension View {
//    func widgetPromoModal(serviceStartDate: Date?) -> some View {
//        modifier(WidgetPromoModalModifier(serviceStartDate: serviceStartDate))
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    @Previewable @State var shown = true
//    ZStack {
//        Color(.systemGroupedBackground).ignoresSafeArea()
//        if shown {
//            WidgetPromoModal(isPresented: $shown) {
//                print("Navigate to paywall")
//            }
//        }
//    }
//}

import SwiftUI

// MARK: - Modal View

struct WidgetPromoModal: View {
    @Binding var isPresented: Bool
    var onUpgrade: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 0) {

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 130)

                    HStack(spacing: 16) {
                        widgetPreview(icon: "calendar", label: "Tänään Jäljellä")
                        widgetPreview(icon: "menucard", label: "Ruokalistat")
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 10) {
                    Text("Widgetit kotinäytölle")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Näe TJ ja päivän ruokalista yhdellä vilkaisulla ilman sovelluksen avaamista.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                .padding(.bottom, 8)

                VStack(spacing: 10) {
                    Button {
                        dismiss()
                        onUpgrade()
                    } label: {
                        Text("Hanki Premium")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.indigo.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Älä enää näytä viestiä uudelleen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.18), radius: 24, y: 8)
            .padding(.horizontal, 32)
        }
    }

    private func widgetPreview(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 72, height: 80)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            isPresented = false
        }
    }
}

// MARK: - ViewModifier

struct WidgetPromoModalModifier: ViewModifier {
    @State private var isPresented = false
    @State private var navigateToPaywall = false
    let serviceStartDate: Date?

    private let storageKey = "widgetPromoShown_v1"
    private let firstLaunchKey = "appFirstLaunchDate_v1"

    private func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }

    private func recordFirstLaunchIfNeeded() {
        if UserDefaults.standard.object(forKey: firstLaunchKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchKey)
        }
    }

    private func shouldShowPromo() -> Bool {
        // Already shown once, never show again
        guard !UserDefaults.standard.bool(forKey: storageKey) else { return false }

        // Must be 7+ days into their service period
        guard let startDate = serviceStartDate, daysSince(startDate) >= 7 else { return false }

        // Must also be 7+ days since they first opened the app
        guard let firstLaunch = UserDefaults.standard.object(forKey: firstLaunchKey) as? Date,
              daysSince(firstLaunch) >= 7 else { return false }

        return true
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                recordFirstLaunchIfNeeded()
                if shouldShowPromo() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(duration: 0.4)) {
                            isPresented = true
                        }
                        UserDefaults.standard.set(true, forKey: storageKey)
                    }
                }
            }
            .overlay {
                if isPresented {
                    WidgetPromoModal(isPresented: $isPresented) {
                        navigateToPaywall = true
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(100)
                }
            }
            .navigationDestination(isPresented: $navigateToPaywall) {
                RevenueCatPaywallView()
            }
    }
}

extension View {
    func widgetPromoModal(serviceStartDate: Date?) -> some View {
        modifier(WidgetPromoModalModifier(serviceStartDate: serviceStartDate))
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var shown = true
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        if shown {
            WidgetPromoModal(isPresented: $shown) {
                print("Navigate to paywall")
            }
        }
    }
}
