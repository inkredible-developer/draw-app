import UIKit

protocol CameraTesterViewDelegate: AnyObject {
    func cameraTesterViewDidTapCancel(_ view: CameraTesterView)
    func cameraTesterViewDidTapNext(_ view: CameraTesterView)
}

class CameraTesterView: UIView {
    weak var delegate: CameraTesterViewDelegate?
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        addSubview(cancelButton)
        addSubview(nextButton)
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 24)
        ])
    }
    
    @objc private func cancelTapped() {
        delegate?.cameraTesterViewDidTapCancel(self)
    }
    
    @objc private func nextTapped() {
        delegate?.cameraTesterViewDidTapNext(self)
    }
} 

#Preview {
    CameraTesterView()
}
