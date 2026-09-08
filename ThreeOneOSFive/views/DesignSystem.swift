import SwiftUI

// TnCheats visual system — the underlying 3105 functionality remains unchanged.
enum AppTheme {
    static let accent = Color(red: 0.00, green: 0.72, blue: 1.00)
    static let accentSoft = Color(red: 0.08, green: 0.45, blue: 0.78)
    static let silver = Color(red: 0.86, green: 0.88, blue: 0.92)
    static let pageBackground = Color(red: 0.015, green: 0.025, blue: 0.045)
    static let consoleBackground = Color(red: 0.025, green: 0.040, blue: 0.065)
    static let navBarBackground = Color(red: 0.018, green: 0.028, blue: 0.050)
    static let glassFill = Color.white.opacity(0.055)
    static let glassHighlight = Color.white.opacity(0.10)
    static let pageInset: CGFloat = 16
    static let rowIconSize: CGFloat = 17
    static let rowIconFrame: CGFloat = 28
    static let fileRowIconSize: CGFloat = 17
    static let fileRowIconFrame: CGFloat = 30
    static let fileRowHeight: CGFloat = 60
    static let appIconSize: CGFloat = 32
    static let emptyIconSize: CGFloat = 30
    static let selectionIconSize: CGFloat = 18
    static let contentCardCornerRadius: CGFloat = 20
    static let contentCardInset: CGFloat = 16
    static let contentCardPadding: CGFloat = 16
}

struct TnCheatsBackground: View {
    var body: some View {
        ZStack {
            AppTheme.pageBackground.ignoresSafeArea()

            LinearGradient(
                colors: [
                    AppTheme.accent.opacity(0.11),
                    Color.clear,
                    Color.black.opacity(0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.accent.opacity(0.055))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 130, y: -220)
                .allowsHitTesting(false)
        }
    }
}

struct GlassCardBackground: View {
    var cornerRadius: CGFloat = AppTheme.contentCardCornerRadius

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.glassFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.silver.opacity(0.28),
                                AppTheme.accent.opacity(0.20),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
    }
}

struct AppCardBorder: View {
    var body: some View {
        RoundedRectangle(
            cornerRadius: AppTheme.contentCardCornerRadius,
            style: .continuous
        )
        .strokeBorder(
            LinearGradient(
                colors: [
                    AppTheme.silver.opacity(0.28),
                    AppTheme.accent.opacity(0.20),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.8
        )
        .accessibilityHidden(true)
    }
}

struct AppRowIcon: View {
    let systemName: String
    var tint: Color = AppTheme.accent
    var symbolSize: CGFloat = AppTheme.rowIconSize
    var frameSize: CGFloat = AppTheme.rowIconFrame

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tint.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(tint.opacity(0.18), lineWidth: 0.6)
                )
            Image(systemName: systemName)
                .font(.system(size: symbolSize, weight: .medium))
                .foregroundStyle(tint)
        }
        .frame(width: frameSize, height: frameSize)
        .accessibilityHidden(true)
    }
}

struct AppSearchField: View {
    @Binding var text: String
    let prompt: String
    let clearLabel: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.silver.opacity(0.70))
                .accessibilityHidden(true)

            TextField(prompt, text: $text)
                .font(.body)
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(clearLabel)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.silver.opacity(0.13), lineWidth: 0.7)
        )
        .padding(.horizontal, AppTheme.pageInset)
        .padding(.vertical, 8)
        .background(AppTheme.navBarBackground.opacity(0.92))
    }
}

struct AppLogo: View {
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let icon = UIImage(named: "AppIcon60x60")
                ?? Bundle.main.path(forResource: "AppIcon60x60@2x", ofType: "png").flatMap(UIImage.init(contentsOfFile:))
                ?? UIImage(named: "AppIcon") {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "bolt.horizontal.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .stroke(AppTheme.silver.opacity(0.24), lineWidth: 0.7)
        )
        .shadow(color: AppTheme.accent.opacity(0.18), radius: 10)
        .accessibilityHidden(true)
    }
}
