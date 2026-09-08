import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @AppStorage(FeatureVisibility.cleanerStorageKey) private var cleanerEnabled = true
    @AppStorage(FeatureVisibility.developerModeStorageKey) private var developerModeEnabled = false
    @State private var selection: MainTab = .home
    @State private var showSettings = false
    @State private var showLogs = false

    enum MainTab: String, CaseIterable, Identifiable {
        case home, patches, cleaner
        var id: String { rawValue }
        var title: String {
            switch self {
            case .home: return "Home"
            case .patches: return "Patch Projects"
            case .cleaner: return "Cleaner"
            }
        }
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .patches: return "shippingbox.fill"
            case .cleaner: return "sparkles"
            }
        }
    }

    var body: some View {
        ZStack {
            TnCheatsBackground()

            Group {
                switch selection {
                case .home:
                    HomeDashboard(
                        onOpenSettings: { showSettings = true },
                        onOpenLogs: { showLogs = true }
                    )
                case .patches:
                    PatchProjectsView(
                        onOpenSettings: { showSettings = true },
                        onOpenLogs: { showLogs = true }
                    )
                case .cleaner:
                    CleanerView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                MainGlassTabBar(selection: $selection, cleanerEnabled: cleanerEnabled)
            }
        }
        .tint(AppTheme.accent)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLogs) { LogView() }
        .patchStorePresentation(patchStore)
        .onChange(of: developerModeEnabled) { enabled in
            if !enabled && selection == .patches {
                // Patch Projects remains available to shared users for prebuilt projects.
            }
        }
        .onChange(of: patchDraftCoordinator.request?.id) { requestID in
            if requestID != nil { selection = .patches }
        }
        .onChange(of: patchDraftCoordinator.importRequest?.id) { requestID in
            if requestID != nil { selection = .patches }
        }
    }
}

private struct HomeDashboard: View {
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    @State private var selectedPatchID: String?
    @State private var patchStates: [String: Bool] = [:]

    private let games = [
        GameDefinition(
            id: "ffth",
            name: "Free Fire",
            bundleID: "com.dts.freefireth",
            icon: "gamecontroller.fill",
            patches: [
                GamePatch(id: "ffth.drag", name: "Aim Drag FFTH", icon: "scope"),
                GamePatch(id: "ffth.chest", name: "Aim Chest FFTH", icon: "target"),
                GamePatch(id: "ffth.neck", name: "Aim Neck FFTH", icon: "circle.dotted"),
                GamePatch(id: "ffth.body", name: "Aim Body FFTH", icon: "figure.stand"),
                GamePatch(id: "ffth.fps", name: "Unlock FPS 144", icon: "speedometer")
            ]
        ),
        GameDefinition(
            id: "ffmax",
            name: "Free Fire Max",
            bundleID: "com.dts.freefiremax",
            icon: "gamecontroller.fill",
            patches: [
                GamePatch(id: "ffmax.drag", name: "Aim Drag FFMAX", icon: "scope"),
                GamePatch(id: "ffmax.chest", name: "Aim Chest FFMAX", icon: "target"),
                GamePatch(id: "ffmax.neck", name: "Aim Neck FFMAX", icon: "circle.dotted")
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    dashboardHeader

                    sectionTitle("GAMES")
                    ForEach(games) { game in
                        NavigationLink {
                            GamePatchListView(
                                game: game,
                                patchStates: $patchStates,
                                selectedPatchID: $selectedPatchID,
                                onOpenApp: { openGame(game) }
                            )
                        } label: {
                            GlassCard(cornerRadius: 26) {
                                HStack(spacing: 15) {
                                    iconTile(game.icon, size: 58)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(game.name)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text(game.bundleID)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundStyle(AppTheme.silver.opacity(0.52))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(AppTheme.silver.opacity(0.42))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    GlassCard(cornerRadius: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("App Features", systemImage: "slider.horizontal.3")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("READY")
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(1.5)
                                    .foregroundStyle(AppTheme.accent)
                            }
                            featureRow("Cleaner", icon: "sparkles")
                            featureRow("Logs", icon: "terminal")
                            featureRow("Settings", icon: "gearshape.fill")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 22)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var dashboardHeader: some View {
        HStack(spacing: 12) {
            AppLogo(size: 50)
            VStack(alignment: .leading, spacing: 3) {
                Text("TnCheats")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.white, AppTheme.silver], startPoint: .top, endPoint: .bottom))
                Text("CONTROL PANEL")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3.4)
                    .foregroundStyle(AppTheme.silver.opacity(0.60))
            }
            Spacer()
            HStack(spacing: 8) {
                circleTool("terminal.fill", action: onOpenLogs)
                circleTool("gearshape.fill", action: onOpenSettings)
            }
        }
        .padding(.top, 4)
    }

    private func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 10, weight: .heavy))
                .tracking(2.6)
                .foregroundStyle(AppTheme.silver.opacity(0.56))
            Spacer()
        }
        .padding(.horizontal, 3)
    }

    private func iconTile(_ systemName: String, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(AppTheme.accent.opacity(0.12))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppTheme.silver.opacity(0.20), lineWidth: 0.8))
            .overlay(Image(systemName: systemName).font(.system(size: 22, weight: .semibold)).foregroundStyle(AppTheme.accent))
            .frame(width: size, height: size)
    }

    private func circleTool(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.silver)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(AppTheme.silver.opacity(0.18), lineWidth: 0.7))
        }
        .buttonStyle(.plain)
    }

    private func featureRow(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppTheme.accent).frame(width: 26)
            Text(title).foregroundStyle(.white)
            Spacer()
            Text("READY").font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundStyle(AppTheme.silver.opacity(0.45))
        }
    }

    private func openGame(_ game: GameDefinition) {
        // iOS does not provide a generic bundle-ID launcher. The app can open a
        // target only when its URL scheme is known and registered by that app.
        let scheme = game.id == "ffth" ? "freefireth" : "freefiremax"
        guard let url = URL(string: "\(scheme)://") else { return }
        UIApplication.shared.open(url)
    }
}

private struct GamePatchListView: View {
    let game: GameDefinition
    @Binding var patchStates: [String: Bool]
    @Binding var selectedPatchID: String?
    let onOpenApp: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(game.name)
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(game.bundleID)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(AppTheme.silver.opacity(0.48))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

                ForEach(game.patches) { patch in
                    let enabled = patchStates[patch.id] ?? false
                    Button {
                        selectedPatchID = enabled ? nil : patch.id
                        patchStates[patch.id] = !enabled
                    } label: {
                        GlassCard(cornerRadius: 22) {
                            HStack(spacing: 13) {
                                Image(systemName: patch.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(enabled ? AppTheme.accent : AppTheme.silver.opacity(0.62))
                                    .frame(width: 48, height: 48)
                                    .background(AppTheme.accent.opacity(enabled ? 0.13 : 0.05), in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(patch.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text(enabled ? "Đang bật" : "Sẵn sàng")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(enabled ? AppTheme.accent : AppTheme.silver.opacity(0.45))
                                }
                                Spacer()
                                GlassToggle(isOn: Binding(
                                    get: { patchStates[patch.id] ?? false },
                                    set: { newValue in
                                        patchStates[patch.id] = newValue
                                        selectedPatchID = newValue ? patch.id : nil
                                    }
                                ))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if selectedPatchID != nil {
                    Button(action: onOpenApp) {
                        HStack {
                            Image(systemName: "arrow.up.right.square.fill")
                            Text("MỞ APP")
                        }
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(colors: [AppTheme.accent, AppTheme.accentSoft], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .shadow(color: AppTheme.accent.opacity(0.22), radius: 16, y: 8)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(TnCheatsBackground())
        .navigationTitle("Patches")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GlassToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? AppTheme.accent.opacity(0.78) : AppTheme.silver.opacity(0.16))
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.silver.opacity(isOn ? 0.34 : 0.18), lineWidth: 0.7)
                    )
                    .frame(width: 50, height: 30)

                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
                    .padding(3)
            }
            .frame(width: 50, height: 30)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "Patch đang bật" : "Patch đang tắt")
    }
}

private struct MainGlassTabBar: View {
    @Binding var selection: ContentView.MainTab
    let cleanerEnabled: Bool

    var body: some View {
        HStack(spacing: 8) {
            tab(.home)
            tab(.patches)
            if cleanerEnabled { tab(.cleaner) }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(AppTheme.silver.opacity(0.18), lineWidth: 0.8))
        .shadow(radius: 18, y: 7)
        .padding(.horizontal, 22)
        .padding(.bottom, 6)
    }

    private func tab(_ item: ContentView.MainTab) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.18)) { selection = item } } label: {
            VStack(spacing: 4) {
                Image(systemName: item.icon).font(.system(size: 16, weight: .semibold))
                Text(item.title).font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(selection == item ? AppTheme.accent : AppTheme.silver.opacity(0.58))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(selection == item ? AppTheme.accent.opacity(0.11) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct GameDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleID: String
    let icon: String
    let patches: [GamePatch]
}

private struct GamePatch: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
}

private struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    init(cornerRadius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(17)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(LinearGradient(colors: [AppTheme.silver.opacity(0.055), AppTheme.accent.opacity(0.025), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)).allowsHitTesting(false))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(LinearGradient(colors: [AppTheme.silver.opacity(0.28), AppTheme.accent.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.8))
    }
}
