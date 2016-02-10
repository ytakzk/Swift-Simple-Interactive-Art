//
//  ViewController.swift
//  Swift-Simple-Interactive-Art
//
//  Created by ytakzk on 2014/06/03.
//  Copyright (c) 2014年 ytakzk. All rights reserved.
//


import UIKit

var screenWidth: CGFloat  = 320
var screenHeight: CGFloat = 568

func getRandomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
    
    let random = CGFloat(arc4random_uniform(10000))
    
    return min + (max - min) * random/10000.0
    
}

class Ball {
    
    var position: CGPoint
    var velocity: CGPoint
    var radius: CGFloat
    var view: UIView
    
    init(position: CGPoint, velocity: CGPoint, radius: CGFloat, color: UIColor, view: UIView) {
        
        self.position = position
        self.velocity = velocity
        self.radius   = radius
        self.view     = view
        view.center   = position
    }
    
    func update() {
        
        position.x += velocity.x
        position.y += velocity.y
        
        if position.x < -radius {
            
            position.x = radius + screenWidth
            
        } else if position.x > screenWidth + radius {
            
            position.x = -radius
        }
        
        if position.y < -radius {
            
            position.y = radius + screenHeight
            
        } else if position.y > screenHeight + radius {
            
            position.y = -radius
        }
        
        view.center = CGPoint(x: position.x, y: position.y)
    }
    
    func addRadius() {
        
        radius *= 1.1
        view.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        view.layer.cornerRadius = radius
        
    }
    
    func changeVelocity() {
        
        let vx = getRandomFloat(-3, max: 3)
        let vy = getRandomFloat(-3, max: 3)
        
        velocity = CGPoint(x: vx, y: vy)
    }
    
    func addVelocity(velDiff: CGPoint) {
        
        velocity = CGPoint(x: velocity.x + velDiff.x, y: velocity.y + velDiff.y)
    }
}

class ViewController: UIViewController {
    
    var displayLink: CADisplayLink?
    
    var balls      = [Ball]()
    var numOfBalls = 100
    var radius     = 10
    var baseHue    = getRandomFloat(0.0, max: 1.0)
    var saturation = getRandomFloat(0.5, max: 1.0)
    var brightness = getRandomFloat(0.7, max: 1.0)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        screenWidth  = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
        for var i = 0 ; i < numOfBalls; i++ {
            
            let px = getRandomFloat(0.0, max: screenWidth)
            let py = getRandomFloat(0.0, max: screenHeight)
            let position = CGPoint(x: px, y: py)
            let vx = getRandomFloat(-3, max: 3)
            let vy = getRandomFloat(-3, max: 3)
            let velocity = CGPoint(x: vx, y: vy)
            let radius = getRandomFloat(1, max: 20)
            let hue = baseHue + getRandomFloat(-0.12, max: 0.12)
            let color = UIColor(hue:hue, saturation:saturation, brightness:brightness, alpha:1.0)
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
            view.backgroundColor = color
            view.layer.cornerRadius = CGFloat(radius)
            self.view.addSubview(view)
            
            let ball = Ball(position: position, velocity: velocity, radius: radius, color: color, view: view)
            balls.append(ball)
        }
        
        if displayLink == nil {
            
            displayLink = CADisplayLink(target: self, selector: "update:")
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(displayLink: CADisplayLink) {
        
        for ball in balls {
            
            ball.update()
        }
    }
    
    @IBAction func tapGestureRecognized(sender : UITapGestureRecognizer) {
        
        for ball in balls {
            
            ball.addRadius()
            ball.changeVelocity()
        }
    }
    
    @IBAction func panGestureRecognized(sender : UIPanGestureRecognizer) {
        
        let p = sender.translationInView(self.view)
        let ratio: Float = 0.15
        
        if (sender.state == UIGestureRecognizerState.Changed) {
            
            var length = sqrtf(powf(Float(p.x), 2) + powf(Float(p.y), 2))
            length = (length < 0.01) ? 1 : length
            let normalized = CGPoint(x: CGFloat(ratio) * p.x / CGFloat(length), y: CGFloat(ratio) * p.y / CGFloat(length))
            
            for ball in balls {
                ball.addVelocity(normalized)
            }
        }
        
        sender.setTranslation(CGPointZero, inView:self.view)
    }
}
