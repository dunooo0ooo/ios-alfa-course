import UIKit

protocol BDUIViewMapping {
    func makeView(from node: BDUIViewNode, actionHandler: BDUIActionHandling?) -> UIView
}

protocol BDUIActionHandling: AnyObject {
    func handle(action: BDUIAction)
}

final class BDUIViewMapper: BDUIViewMapping {
    func makeView(from node: BDUIViewNode, actionHandler: BDUIActionHandling?) -> UIView {
        switch node.type {
        case .container:
            return makeContainer(node: node, actionHandler: actionHandler)
        case .stack:
            return makeStack(node: node, actionHandler: actionHandler)
        case .label:
            return makeLabel(node: node)
        case .button:
            return makeButton(node: node, actionHandler: actionHandler)
        case .image:
            return makeImage(node: node)
        case .spacer:
            return makeSpacer(node: node)
        }
    }

    private func makeContainer(node: BDUIViewNode, actionHandler: BDUIActionHandling?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        applyContainerStyle(node.content, to: view)

        if !node.subviews.isEmpty {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = node.content.axis?.uiAxis ?? .vertical
            stack.spacing = node.content.spacing?.value ?? 0
            stack.alignment = node.content.alignment?.uiAlignment ?? .fill
            stack.distribution = node.content.distribution?.uiDistribution ?? .fill
            view.addSubview(stack)

            let insets = node.content.padding?.edgeInsets ?? .zero
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
                stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
                stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            ])

            node.subviews
                .map { makeArrangedSubview(from: $0, in: stack, actionHandler: actionHandler) }
                .forEach { stack.addArrangedSubview($0) }
        }

        applySize(node.content, to: view)
        return view
    }

    private func makeStack(node: BDUIViewNode, actionHandler: BDUIActionHandling?) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = node.content.axis?.uiAxis ?? .vertical
        stack.spacing = node.content.spacing?.value ?? 0
        stack.alignment = node.content.alignment?.uiAlignment ?? .fill
        stack.distribution = node.content.distribution?.uiDistribution ?? .fill
        node.subviews
            .map { makeArrangedSubview(from: $0, in: stack, actionHandler: actionHandler) }
            .forEach { stack.addArrangedSubview($0) }
        applySize(node.content, to: stack)
        return stack
    }

    private func makeLabel(node: BDUIViewNode) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = node.content.text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(node.content.textStyle?.dsStyle ?? .body)
        applySize(node.content, to: label)
        return label
    }

    private func makeButton(node: BDUIViewNode, actionHandler: BDUIActionHandling?) -> UIView {
        let button = DSButton(configuration: .init(
            title: node.content.text ?? "",
            style: node.content.buttonStyle?.dsStyle ?? .primary
        ))
        if let action = node.content.action {
            button.addAction(UIAction { _ in
                actionHandler?.handle(action: action)
            }, for: .touchUpInside)
        }
        applySize(node.content, to: button)
        return button
    }

    private func makeImage(node: BDUIViewNode) -> UIView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = node.content.backgroundColor == nil ? DS.Colors.primary : DS.Colors.textOnPrimary
        imageView.image = image(for: node.content.icon)
        imageView.backgroundColor = node.content.backgroundColor?.uiColor ?? DS.Colors.surface
        imageView.layer.cornerRadius = node.content.cornerRadius?.value ?? DS.Spacing.cornerRadius
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        applySize(node.content, to: imageView)
        return imageView
    }

    private func makeSpacer(node: BDUIViewNode) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .clear
        applySize(node.content, to: spacer)
        return spacer
    }

    private func image(for icon: BDUIconToken?) -> UIImage? {
        switch icon {
        case .playlist:
            return DS.Icons.playlist
        case .empty:
            return DS.Icons.empty
        case .error:
            return DS.Icons.error
        case nil:
            return nil
        }
    }

    private func applyContainerStyle(_ content: BDUIViewContent, to view: UIView) {
        view.backgroundColor = content.backgroundColor?.uiColor ?? .clear
        if let radius = content.cornerRadius?.value {
            view.layer.cornerRadius = radius
            view.layer.cornerCurve = .continuous
            view.clipsToBounds = true
        }
    }

    private func applySize(_ content: BDUIViewContent, to view: UIView) {
        if let width = content.width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = content.height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    private func makeArrangedSubview(
        from node: BDUIViewNode,
        in stack: UIStackView,
        actionHandler: BDUIActionHandling?
    ) -> UIView {
        let view = makeView(from: node, actionHandler: actionHandler)
        guard requiresCrossAxisWrapper(for: node.content, in: stack) else {
            return view
        }

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(view)

        switch stack.axis {
        case .vertical:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: wrapper.topAnchor),
                view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
                view.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            ])
        case .horizontal:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                view.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            ])
        @unknown default:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: wrapper.topAnchor),
                view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
                view.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            ])
        }

        return wrapper
    }

    private func requiresCrossAxisWrapper(for content: BDUIViewContent, in stack: UIStackView) -> Bool {
        guard stack.alignment == .fill else { return false }

        switch stack.axis {
        case .vertical:
            return content.width != nil
        case .horizontal:
            return content.height != nil
        @unknown default:
            return false
        }
    }
}
