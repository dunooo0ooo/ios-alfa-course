import UIKit

struct BDUIViewNode: Decodable, Equatable {
    let type: BDUIViewType
    let content: BDUIViewContent
    let subviews: [BDUIViewNode]

    private enum CodingKeys: String, CodingKey {
        case type
        case content
        case subviews
    }

    init(type: BDUIViewType, content: BDUIViewContent = .init(), subviews: [BDUIViewNode] = []) {
        self.type = type
        self.content = content
        self.subviews = subviews
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BDUIViewType.self, forKey: .type)
        content = try container.decodeIfPresent(BDUIViewContent.self, forKey: .content) ?? .init()
        subviews = try container.decodeIfPresent([BDUIViewNode].self, forKey: .subviews) ?? []
    }

    func applying(templateValues: [String: String]) -> BDUIViewNode {
        BDUIViewNode(
            type: type,
            content: content.applying(templateValues: templateValues),
            subviews: subviews.map { $0.applying(templateValues: templateValues) }
        )
    }
}

enum BDUIViewType: String, Decodable, Equatable {
    case container
    case stack
    case label
    case button
    case image
    case spacer
}

struct BDUIViewContent: Decodable, Equatable {
    let text: String?
    let textStyle: BDUTextStyleToken?
    let buttonStyle: BDUButtonStyleToken?
    let icon: BDUIconToken?
    let axis: BDUAxis?
    let spacing: BDUSpacingToken?
    let alignment: BDUStackAlignment?
    let distribution: BDUStackDistribution?
    let backgroundColor: BDUColorToken?
    let cornerRadius: BDUCornerRadiusToken?
    let padding: BDUInsets?
    let width: CGFloat?
    let height: CGFloat?
    let action: BDUIAction?

    private enum CodingKeys: String, CodingKey {
        case text
        case textStyle
        case buttonStyle
        case icon
        case axis
        case spacing
        case alignment
        case distribution
        case backgroundColor
        case cornerRadius
        case padding
        case width
        case height
        case action
    }

    init(
        text: String? = nil,
        textStyle: BDUTextStyleToken? = nil,
        buttonStyle: BDUButtonStyleToken? = nil,
        icon: BDUIconToken? = nil,
        axis: BDUAxis? = nil,
        spacing: BDUSpacingToken? = nil,
        alignment: BDUStackAlignment? = nil,
        distribution: BDUStackDistribution? = nil,
        backgroundColor: BDUColorToken? = nil,
        cornerRadius: BDUCornerRadiusToken? = nil,
        padding: BDUInsets? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        action: BDUIAction? = nil
    ) {
        self.text = text
        self.textStyle = textStyle
        self.buttonStyle = buttonStyle
        self.icon = icon
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.width = width
        self.height = height
        self.action = action
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        textStyle = try container.decodeIfPresent(BDUTextStyleToken.self, forKey: .textStyle)
        buttonStyle = try container.decodeIfPresent(BDUButtonStyleToken.self, forKey: .buttonStyle)
        icon = try container.decodeIfPresent(BDUIconToken.self, forKey: .icon)
        axis = try container.decodeIfPresent(BDUAxis.self, forKey: .axis)
        spacing = try container.decodeIfPresent(BDUSpacingToken.self, forKey: .spacing)
        alignment = try container.decodeIfPresent(BDUStackAlignment.self, forKey: .alignment)
        distribution = try container.decodeIfPresent(BDUStackDistribution.self, forKey: .distribution)
        backgroundColor = try container.decodeIfPresent(BDUColorToken.self, forKey: .backgroundColor)
        cornerRadius = try container.decodeIfPresent(BDUCornerRadiusToken.self, forKey: .cornerRadius)
        padding = try container.decodeIfPresent(BDUInsets.self, forKey: .padding)
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
        action = try container.decodeIfPresent(BDUIAction.self, forKey: .action)
    }

    func applying(templateValues: [String: String]) -> BDUIViewContent {
        BDUIViewContent(
            text: text?.applying(templateValues: templateValues),
            textStyle: textStyle,
            buttonStyle: buttonStyle,
            icon: icon,
            axis: axis,
            spacing: spacing,
            alignment: alignment,
            distribution: distribution,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            padding: padding,
            width: width,
            height: height,
            action: action?.applying(templateValues: templateValues)
        )
    }
}

enum BDUTextStyleToken: String, Decodable, Equatable {
    case heroTitle
    case screenTitle
    case body
    case bodyStrong
    case subheadline
    case caption
    case error

    var dsStyle: DSTextStyle {
        switch self {
        case .heroTitle: return .heroTitle
        case .screenTitle: return .screenTitle
        case .body: return .body
        case .bodyStrong: return .bodyStrong
        case .subheadline: return .subheadline
        case .caption: return .caption
        case .error: return .error
        }
    }
}

enum BDUButtonStyleToken: String, Decodable, Equatable {
    case primary
    case secondary

    var dsStyle: DSButton.Style {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        }
    }
}

enum BDUIconToken: String, Decodable, Equatable {
    case playlist
    case empty
    case error
}

enum BDUColorToken: String, Decodable, Equatable {
    case clear
    case background
    case surface
    case surfaceElevated
    case primary
    case textPrimary
    case textSecondary
    case error
    case border

    var uiColor: UIColor {
        switch self {
        case .clear: return .clear
        case .background: return DS.Colors.background
        case .surface: return DS.Colors.surface
        case .surfaceElevated: return DS.Colors.surfaceElevated
        case .primary: return DS.Colors.primary
        case .textPrimary: return DS.Colors.textPrimary
        case .textSecondary: return DS.Colors.textSecondary
        case .error: return DS.Colors.error
        case .border: return DS.Colors.border
        }
    }
}

enum BDUSpacingToken: String, Decodable, Equatable {
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge

    var value: CGFloat {
        switch self {
        case .xSmall: return DS.Spacing.xSmall
        case .small: return DS.Spacing.small
        case .medium: return DS.Spacing.medium
        case .large: return DS.Spacing.large
        case .xLarge: return DS.Spacing.xLarge
        case .xxLarge: return DS.Spacing.xxLarge
        }
    }
}

enum BDUCornerRadiusToken: String, Decodable, Equatable {
    case regular
    case large

    var value: CGFloat {
        switch self {
        case .regular: return DS.Spacing.cornerRadius
        case .large: return DS.Spacing.cornerRadiusLarge
        }
    }
}

enum BDUAxis: String, Decodable, Equatable {
    case horizontal
    case vertical

    var uiAxis: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        }
    }
}

enum BDUStackAlignment: String, Decodable, Equatable {
    case fill
    case leading
    case center
    case trailing

    var uiAlignment: UIStackView.Alignment {
        switch self {
        case .fill: return .fill
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum BDUStackDistribution: String, Decodable, Equatable {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing

    var uiDistribution: UIStackView.Distribution {
        switch self {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .fillProportionally: return .fillProportionally
        case .equalSpacing: return .equalSpacing
        }
    }
}

struct BDUInsets: Decodable, Equatable {
    let top: BDUSpacingToken
    let leading: BDUSpacingToken
    let bottom: BDUSpacingToken
    let trailing: BDUSpacingToken

    var edgeInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: top.value,
            left: leading.value,
            bottom: bottom.value,
            right: trailing.value
        )
    }
}

enum BDUIAction: Decodable, Equatable {
    case print(message: String)
    case reload
    case navigateBack

    private enum CodingKeys: String, CodingKey {
        case type
        case message
    }

    private enum ActionType: String, Decodable {
        case print
        case reload
        case navigateBack
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(ActionType.self, forKey: .type) {
        case .print:
            self = .print(message: try container.decode(String.self, forKey: .message))
        case .reload:
            self = .reload
        case .navigateBack:
            self = .navigateBack
        }
    }

    func applying(templateValues: [String: String]) -> BDUIAction {
        switch self {
        case .print(let message):
            return .print(message: message.applying(templateValues: templateValues))
        case .reload:
            return .reload
        case .navigateBack:
            return .navigateBack
        }
    }
}

private extension String {
    func applying(templateValues: [String: String]) -> String {
        templateValues.reduce(into: self) { result, pair in
            result = result.replacingOccurrences(of: "{{\(pair.key)}}", with: pair.value)
        }
    }
}
