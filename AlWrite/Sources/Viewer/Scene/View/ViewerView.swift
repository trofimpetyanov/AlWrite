import UIKit

class ViewerView: UIView {
    
    // MARK: - Properties
    var onRecognitionRequested: (() -> Void)?
    var onModeChanged: ((ViewerState.ViewerRecognitionMode) -> Void)?

    // MARK: - UI Components
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var recognizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Распознать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(recognizeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var modeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Текст", for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)

        let textAction = UIAction(
            title: "Текст",
            image: UIImage(systemName: "text.alignleft"),
            state: .on
        ) { [weak self] _ in
            self?.onModeChanged?(.text)
        }
        
        let mathAction = UIAction(
            title: "Формула",
            image: UIImage(systemName: "function"),
            state: .off
        ) { [weak self] _ in
            self?.onModeChanged?(.math)
        }
        
        let menu = UIMenu(
            title: "Выберите режим распознавания",
            children: [textAction, mathAction]
        )
        
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        
        return button
    }()
    
    private let textContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with state: ViewerState) {
        modeButton.menu = createModeMenu(currentMode: state.recognitionMode)
        modeButton.setTitle(state.recognitionMode.rawValue, for: .normal)

        let isLoading = state.isLoading
        loadingIndicator.isHidden = !isLoading
        recognizeButton.isEnabled = !isLoading
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        if !state.recognizedText.isEmpty {
            textLabel.text = state.recognizedText
            textLabel.isHidden = false
            textContainer.isHidden = false
        } else {
            textLabel.text = "Текст будет отображаться здесь после распознавания"
            textLabel.isHidden = false 
            textContainer.isHidden = false
        }
    }
    
    // MARK: - Private methods
    private func setupViews() {
        backgroundColor = .systemGroupedBackground
        
        addSubview(contentView)
        contentView.addSubview(textContainer)
        textContainer.addSubview(textLabel)
        
        addSubview(recognizeButton)
        addSubview(modeButton)
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            recognizeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            recognizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            recognizeButton.heightAnchor.constraint(equalToConstant: 36),
            recognizeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])

        NSLayoutConstraint.activate([
            modeButton.centerYAnchor.constraint(equalTo: recognizeButton.centerYAnchor),
            modeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            modeButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: recognizeButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: recognizeButton.leadingAnchor, constant: -8)
        ])

        NSLayoutConstraint.activate([
            textContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            textLabel.widthAnchor.constraint(equalTo: textContainer.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func recognizeButtonTapped() {
        onRecognitionRequested?()
    }
    
    private func createModeMenu(currentMode: ViewerState.ViewerRecognitionMode) -> UIMenu {
        let textAction = UIAction(
            title: "Текст",
            state: currentMode == .text ? .on : .off
        ) { [weak self] _ in
            self?.onModeChanged?(.text)
        }
        
        let mathAction = UIAction(
            title: "Формула",
            state: currentMode == .math ? .on : .off
        ) { [weak self] _ in
            self?.onModeChanged?(.math)
        }
        
        return UIMenu(title: "Режим распознавания", children: [textAction, mathAction])
    }
} 
