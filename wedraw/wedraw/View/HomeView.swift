//
//  HomeView.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 22/06/25.
//

import UIKit

class HomeView: UIView {
    
    
    weak var controller: HomeViewController?
    let threeDObjectView = ObjectListView()
    var recentDrawView = MyDrawView()
    let segmentedCardView = SegmentedCardView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    var modelsStackView: UIStackView {
        return threeDObjectView.modelsStackView
    }

    var recentStackView: UIStackView {
        return recentDrawView.recentStackView
    }
    
    var learnMoreButton: UIButton {
        return threeDObjectView.learnMoreButton
    }
    
//
    private func setupLayout() {
        backgroundColor = .white
        addSubview(threeDObjectView.pageTitleLabel)
        addSubview(threeDObjectView.bannerCard)
        threeDObjectView.bannerCard.addSubview(learnMoreButton)

        addSubview(threeDObjectView.sectionLabel)
        addSubview(threeDObjectView.modelsScrollView)
        threeDObjectView.modelsScrollView.addSubview(threeDObjectView.modelsStackView)
        
        addSubview(segmentedCardView)
        
        NSLayoutConstraint.activate([
            threeDObjectView.pageTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            threeDObjectView.pageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            threeDObjectView.pageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            threeDObjectView.bannerCard.topAnchor.constraint(equalTo: threeDObjectView.pageTitleLabel.bottomAnchor, constant: 16),
            threeDObjectView.bannerCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            threeDObjectView.bannerCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            threeDObjectView.bannerCard.heightAnchor.constraint(equalToConstant: 120),

            threeDObjectView.sectionLabel.topAnchor.constraint(equalTo: threeDObjectView.bannerCard.bottomAnchor, constant: 16),
            threeDObjectView.sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            threeDObjectView.modelsScrollView.topAnchor.constraint(equalTo: threeDObjectView.sectionLabel.bottomAnchor, constant: 16),
            threeDObjectView.modelsScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            threeDObjectView.modelsScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            threeDObjectView.modelsScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            
            threeDObjectView.modelsStackView.leadingAnchor.constraint(equalTo: threeDObjectView.modelsScrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            threeDObjectView.modelsStackView.trailingAnchor.constraint(equalTo: threeDObjectView.modelsScrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            threeDObjectView.modelsStackView.topAnchor.constraint(equalTo: threeDObjectView.modelsScrollView.contentLayoutGuide.topAnchor),
            threeDObjectView.modelsStackView.bottomAnchor.constraint(equalTo: threeDObjectView.modelsScrollView.contentLayoutGuide.bottomAnchor),
            
            segmentedCardView.topAnchor.constraint(equalTo: threeDObjectView.modelsScrollView.bottomAnchor, constant: 0),
            segmentedCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedCardView.heightAnchor.constraint(equalToConstant: 210)

        ])
    }
    

}
