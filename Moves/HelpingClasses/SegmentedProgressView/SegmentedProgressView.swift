import UIKit

class SegmentedProgressView: UIView {
    
    //MARK: - Init
    
    // This is the designated initializer.
    override init(frame: CGRect) {
        super.init(frame: frame)
        handleSetup()
    }
    
    // This initializer is required when instantiating from a storyboard.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        handleSetup()
    }
    
    var segmentPoints = [CGFloat]()
    
    //MARK: - Properties
    
    private var width: CGFloat = 0
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    //MARK: - Draw Rect
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }
    
    //MARK: - Handlers
    
    private func handleSetup() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
        setupLayers()
    }
    
    private func setupLayers() {
        shapeLayer.strokeColor = UIColor.rgb(red: 254, green: 44, blue: 85).cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = .round
        
        trackLayer.lineWidth = 6
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1
    }
    
    private func updatePaths() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        
        shapeLayer.path = path.cgPath
        trackLayer.path = path.cgPath
    }
    
    func setProgress(_ progress: CGFloat) {
        shapeLayer.strokeEnd = progress
    }
    
    func pauseProgress() {
        let newSegment = createSegment()
        addSubview(newSegment)
        segmentPoints.append(shapeLayer.strokeEnd)
        positionSegment(newSegment)
    }
    
    private func createSegment() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 6))
        view.backgroundColor = .white
        return view
    }
    
    private func positionSegment(_ segment: UIView) {
        let positionX = shapeLayer.strokeEnd * bounds.width
        segment.center = CGPoint(x: positionX, y: bounds.midY)
    }
    
    func removeLastSegment() {
        guard let lastSegment = subviews.last else { return }
        lastSegment.removeFromSuperview()
        segmentPoints.removeLast()
        shapeLayer.strokeEnd = segmentPoints.last ?? 0
    }
    
    func removeAllSegments() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        segmentPoints.removeAll()
    }
}
