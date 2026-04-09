import UIKit

enum DS {
    enum Colors {
        static let background = UIColor.systemGroupedBackground
        static let surface = UIColor.secondarySystemBackground
        static let surfaceElevated = UIColor.systemBackground
        static let primary = UIColor.systemIndigo
        static let primaryPressed = UIColor.systemIndigo.withAlphaComponent(0.82)
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textOnPrimary = UIColor.white
        static let error = UIColor.systemRed
        static let separator = UIColor.separator
        static let border = UIColor.separator.withAlphaComponent(0.35)
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let xxxLarge: CGFloat = 40
        static let screenInset: CGFloat = 20
        static let cornerRadius: CGFloat = 14
        static let cornerRadiusLarge: CGFloat = 24
        static let fieldHeight: CGFloat = 52
        static let buttonHeight: CGFloat = 52
        static let cardPadding: CGFloat = 16
        static let heroArtworkSize: CGFloat = 180
    }

    enum Typography {
        static func heroTitle() -> UIFont { .systemFont(ofSize: 30, weight: .bold) }
        static func screenTitle() -> UIFont { .preferredFont(forTextStyle: .title2).withWeight(.semibold) }
        static func body() -> UIFont { .preferredFont(forTextStyle: .body) }
        static func bodyStrong() -> UIFont { .preferredFont(forTextStyle: .body).withWeight(.semibold) }
        static func subheadline() -> UIFont { .preferredFont(forTextStyle: .subheadline) }
        static func caption() -> UIFont { .preferredFont(forTextStyle: .caption1) }
        static func button() -> UIFont { .systemFont(ofSize: 17, weight: .semibold) }
    }

    enum Icons {
        static let playlist = UIImage(systemName: "music.note.list")
        static let empty = UIImage(systemName: "tray")
        static let error = UIImage(systemName: "exclamationmark.circle")
    }
}

enum DSTextStyle {
    case heroTitle
    case screenTitle
    case body
    case bodyStrong
    case subheadline
    case caption
    case error

    var font: UIFont {
        switch self {
        case .heroTitle:
            return DS.Typography.heroTitle()
        case .screenTitle:
            return DS.Typography.screenTitle()
        case .body:
            return DS.Typography.body()
        case .bodyStrong:
            return DS.Typography.bodyStrong()
        case .subheadline:
            return DS.Typography.subheadline()
        case .caption:
            return DS.Typography.caption()
        case .error:
            return DS.Typography.caption()
        }
    }

    var color: UIColor {
        switch self {
        case .heroTitle, .screenTitle, .body, .bodyStrong:
            return DS.Colors.textPrimary
        case .subheadline, .caption:
            return DS.Colors.textSecondary
        case .error:
            return DS.Colors.error
        }
    }
}

extension UILabel {
    func apply(_ style: DSTextStyle) {
        font = style.font
        textColor = style.color
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
