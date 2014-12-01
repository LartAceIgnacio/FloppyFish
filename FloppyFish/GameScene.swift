//
//  GameScene.swift
//  RunJumpGame
//
//  Created by Lart Ace Ignacio on 11/27/14.
//  Copyright (c) 2014 Ace Ignacio. All rights reserved.
//

import SpriteKit

// Fish
var fish:SKSpriteNode = SKSpriteNode()

// Background
let background:SKNode = SKNode()
var backround_speed: Float = 100.0

// Time Values
var delta:NSTimeInterval = NSTimeInterval(0)
var last_update_time:NSTimeInterval = NSTimeInterval(0)

// Score
var score:Int = 0
var label_score:SKLabelNode = SKLabelNode()

// Floor height
let floor_distance:CGFloat = 30.0

// Weeds Origin
let weeds_origin_x:CGFloat = 682.0

// Whale Origin
let whale_origin_x:CGFloat = 600.0

// Ring Origin
let coin_origin_x:CGFloat = 600.0

// Instructions
var instructions:SKSpriteNode = SKSpriteNode()

// Physics Categories
let FSBoundaryCategory:UInt32 = 1 << 0
let FSPlayerCategory:UInt32   = 1 << 1
let FSWeedsCategory:UInt32    = 1 << 2
let FSWhaleCategory:UInt32    = 1 << 3
let FSCoinCategory:UInt32     = 1 << 4

// Touch Count
var touchCount: Int = 0
var isTouching: Bool = false

// Game States
enum FSGameState: Int {
    case FSGameStateStarting
    case FSGameStatePlaying
    case FSGameStateEnded
}

var state:FSGameState = .FSGameStateStarting

// #pragma mark - Math functions
extension Float {
    static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if(value > max) {
            return max
        } else if(value < min) {
            return min
        } else {
            return value
        }
    }
    
    static func range(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.initWorld()
        self.initFish()
        self.initBackground()
        self.initScoreLabel()
        self.initInstructions()
    }
    
    func initFish() {
        fish = SKSpriteNode(imageNamed: "fish")
        fish.setScale(0.1)
        fish.position = CGPointMake(100, CGRectGetMidY(self.frame))
        
        fish.physicsBody = SKPhysicsBody(circleOfRadius: fish.size.width / 2.5)
        fish.physicsBody?.categoryBitMask = FSPlayerCategory
        fish.physicsBody?.contactTestBitMask = FSWeedsCategory | FSCoinCategory | FSBoundaryCategory | FSWhaleCategory
        fish.physicsBody?.collisionBitMask = FSWeedsCategory | FSBoundaryCategory | FSWhaleCategory
        fish.physicsBody?.restitution = 0.0
        fish.physicsBody?.allowsRotation = false
        fish.zPosition = 20
        
        self.addChild(fish)
    }
    
    func initWorld() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0, floor_distance, self.size.width, self.size.height - floor_distance))
        
        self.physicsBody?.categoryBitMask = FSBoundaryCategory
        self.physicsBody?.collisionBitMask = FSPlayerCategory
    }
    
    func initScoreLabel() {
        label_score = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        label_score.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 100)
        label_score.text = "0"
        label_score.fontColor = UIColor .blackColor()
        label_score.zPosition = 50
        self.addChild(label_score)
        
    }
    
    func initInstructions() {
        instructions = SKSpriteNode(imageNamed: "start_image")
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 10)
        instructions.zPosition = 50
        self.addChild(instructions)
    }
    
    func initCoins() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        var coin:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
        coin = SKSpriteNode(imageNamed: "coin")
        coin.setScale(0.4)
        coin.position = self.convertPoint(CGPointMake(Float.range(coin_origin_x, max: coin_origin_x + 100), floor_distance + Float.range(50, max: screenSize.height - coin.size.height)), toNode: background)
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.5)
        coin.physicsBody?.categoryBitMask = FSCoinCategory
        coin.physicsBody?.contactTestBitMask = FSPlayerCategory
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.dynamic = false
        coin.zPosition = 10
        
        coin.runAction(self.spinAnimation())
        
        background.addChild(coin)
    }
    
    func initWeeds() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        var weeds:SKSpriteNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, 30))
        weeds = SKSpriteNode(imageNamed: "weeds")
        weeds.setScale(0.5)
        weeds.position = self.convertPoint(CGPointMake(Float.range(weeds_origin_x, max: weeds_origin_x + 500), floor_distance + 50), toNode: background)
        
        weeds.physicsBody = SKPhysicsBody(rectangleOfSize: weeds.size)
        weeds.physicsBody?.categoryBitMask = FSWeedsCategory
        weeds.physicsBody?.contactTestBitMask = FSPlayerCategory
        weeds.physicsBody?.collisionBitMask = FSPlayerCategory
        weeds.physicsBody?.dynamic = false
        weeds.zPosition = 20
        
        background.addChild(weeds)
    }
    
    func initWhale() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        var whale:SKSpriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(10, 30))
        whale = SKSpriteNode(imageNamed: "whale")
        whale.setScale(0.5)
        whale.position = self.convertPoint(CGPointMake(Float.range(whale_origin_x, max: whale_origin_x + 500), floor_distance + 220), toNode: background)
        
        whale.physicsBody = SKPhysicsBody(rectangleOfSize: whale.size)
        whale.physicsBody?.categoryBitMask = FSWhaleCategory
        whale.physicsBody?.contactTestBitMask = FSPlayerCategory
        whale.physicsBody?.collisionBitMask = FSPlayerCategory
        whale.physicsBody?.dynamic = false
        whale.zPosition = 21
        
        background.addChild(whale)
    }
    
    func initBackground() {
        self.addChild(background)
        
        for var i: Int = 0; i < 2; i++ {
            let tile = SKSpriteNode(imageNamed: "bg.jpg")
            tile.setScale(2.0)
            tile.anchorPoint = CGPointZero
            tile.position = CGPointMake(CGFloat(i) * 710, 0)
            tile.name = "bg"
            tile.zPosition = 10
            background.addChild(tile)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        
        if collision == (FSPlayerCategory | FSCoinCategory) {
            score++
            label_score.text = "\(score)"
            
            contact.bodyB.node?.removeFromParent()
        }
        
        if collision == (FSPlayerCategory | FSWeedsCategory) {
            self.gameOver()
        }
        
        if collision == (FSPlayerCategory | FSWhaleCategory) {
            self.gameOver()
        }
    }
    
    func gameOver() {
        state = .FSGameStateEnded
        fish.physicsBody?.categoryBitMask = 0
        fish.physicsBody?.collisionBitMask = FSBoundaryCategory
        fish.yScale = fish.yScale * -1
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("restartGame"), userInfo: nil, repeats: false)
    }
    
    func restartGame() {
        state = .FSGameStateStarting
        fish.removeFromParent()
        background.removeAllChildren()
        background.removeFromParent()
        
        instructions.hidden = false
        self.removeActionForKey("weedsGenerator")
        self.removeActionForKey("coinGenerator")
        self.removeActionForKey("whaleGenerator")
        
        score = 0
        label_score.text = "0"
        backround_speed = 100
        
        self.initFish()
        self.initBackground()
    }
    
    
    func moveBackground() {
        let posX: Float = -backround_speed * Float(delta)
        background.position = CGPointMake(background.position.x + CGFloat(posX), 0)
        
        background.enumerateChildNodesWithName("bg") { (node, stop) in
            let backround_screen_position: CGPoint = background.convertPoint(node.position, toNode: self)
            
            if backround_screen_position.x <= -node.frame.size.width {
                node.position = CGPointMake(node.position.x + (node.frame.size.width * 2.0), node.position.y)
            }
        }
    }
    
    func ballPositionCheck() {
        if (fish.position.y < 51) {
            touchCount = 0
        }
    }
    
    func spinAnimation() -> SKAction {
        let spinIn = SKAction.scaleXTo(0.5, duration: 0.5)
        let spinOut = SKAction.scaleXTo(0.0, duration: 0.5)
        let sequence = SKAction.sequence([spinOut, spinIn])
        let spin = SKAction.repeatActionForever(sequence)
        
        return spin
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if state == .FSGameStateStarting {
            state = .FSGameStatePlaying
            
            instructions.hidden = true
            
            fish.physicsBody?.affectedByGravity = true
            fish.physicsBody?.applyImpulse(CGVectorMake(0, 25))
            
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(5.0), SKAction.runBlock { self.initWeeds()}])), withKey: "weedsGenerator")
            
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(3.0), SKAction.runBlock { self.initCoins()}])), withKey: "coinGenerator")
            
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(10.0), SKAction.runBlock { self.initWhale()}])), withKey: "whaleGenerator")
        }
            
        else if state == .FSGameStatePlaying {
            isTouching = true
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        isTouching = false
    }
    
    override func update(currentTime: CFTimeInterval) {
        if last_update_time == 0.0 {
            delta = 0
        } else {
            delta = currentTime - last_update_time
        }
        
        last_update_time = currentTime
        
        backround_speed = backround_speed + (Float(score) * 0.01)
        
        if state != .FSGameStateEnded {
            self.moveBackground()
            self.ballPositionCheck()
            
            if isTouching {
                fish.physicsBody?.applyImpulse(CGVectorMake(0, 1))
            }
          
            let velocity_x = fish.physicsBody?.velocity.dx
            let velocity_y = fish.physicsBody?.velocity.dy
        
            fish.zRotation = Float.clamp(-1, max: 0.0, value: velocity_y! * (velocity_y < 0 ? 0.003 : 0.001))
        } else {
            fish.zRotation = CGFloat(M_PI)
            fish.removeAllActions()
            
        }
        
    }
}
