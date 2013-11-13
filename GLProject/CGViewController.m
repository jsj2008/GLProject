//
//  CGViewController.m
//  GLProject
//
//  Created by Enrique Bermudez on 20/08/13.
//  Copyright (c) 2013 Enrique Bermudez. All rights reserved.
//

#import "CGViewController.h"
#import "CGView.h"
#import "CGObject3D.h"
#import "MeshFactory.h"
#import "TextureManager.h"
#import "CGParticleSystem.h"

#import "CGSimpleRenderProgram.h"
#import "CGSkybox.h"

@interface CGViewController (){

    CGView * cgview;
    CGRenderer* renderer;
    float pos;
    CGObject3D* knight;
    
    float direction;
    CGObject3D* floor;
    
    CGObject3D* plane;
    
    CGLight* light;
    CGLight* floorLight;
    
    double currentTime;
	double renderTime;
    double frameTimestamp;
    
    CGSkybox * skybox;
    
    CGParticleSystem* particleSystem1;
    CGParticleSystem* particleSystem2;
    CGParticleSystem* particleSystem3;
    CGParticleSystem* particleSystem4;
    
    bool iluminated;
    
    CGObject3D* box;

}

@end

@implementation CGViewController




- (void)viewDidLoad
{
    rotUp = false;
    rotDown  = false;
    rotRight = false;
    rotLeft = false;
    
    [super viewDidLoad];
    
    cgview =[[CGView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.glView addSubview:cgview];
    
    renderer = cgview.renderer;
    
    iluminated =YES;
    


    skybox = [[CGSkybox alloc] init];
    [renderer addNode:skybox];
    
    
    floor = [CGObject3D plane];
    
    [floor setTexture: [[TextureManager sharedInstance] textureFromFileName:@"grassTexture.jpg"]];
    [floor rotate:cc3v(-90, 0, 0)];
    [floor translate:cc3v(2.5, -7.1, -2.5)];
    [floor scale:CC3VectorMake(600, 600, 600)];
    floor.textureScale = 30.0f;
    floor.specularFactor = 0.01;
    [renderer addObject:floor];

    
    knight= [CGObject3D MD2ObjectNamed:@"knight"];

    [knight setTexture:[[TextureManager sharedInstance] textureFromFileName:@"knight.jpg"]];
    [knight rotate:cc3v(0, 0, 90)];
    [knight scale:CC3VectorMake(0.3, 0.3, 0.3)];
    //[knight setAnimationWithName:@"Stand"];
    [knight setAnimationWithName:@"Run"];
   // knight.color = (ccColor4F){1,0,0,0.2};
    knight.specularFactor = 0.7;
   [renderer addObject:knight];

    
    light = [[CGLight alloc] init];
    [light translate:cc3v(0,10,30)];
    [renderer addLight:light];
    light.intensity = 0.7f;
    
    renderer.ambientLightIntensity = 0.7f;
    floor.lightAffected = NO;
    
    
    [renderer setClearColor:12.0f/255 g:183.0f/255 b:242.0f/255 a:1.0];
   

    direction =1.0f;

   
    
    CGObject3D* sh = [CGObject3D plane];
    
    [sh setTexture: [[TextureManager sharedInstance] textureFromFileName:@"Shadow.png"]];
    [sh rotate:cc3v(-90, 0, 0)];
    [sh translate:cc3v(0.0, -6.9, 0.0)];
    [sh scale:CC3VectorMake(9, 9, 9)];
    sh.color = (ccColor4F){1,1,1,0.3};
    sh.lightAffected = NO;
    [renderer addObject:sh];

    
    particleSystem1 = [[CGParticleSystem alloc] init];
    [particleSystem1 startEmission];
    [particleSystem1 translate:CC3VectorMake(10, -5, -10)];
    [renderer addNode:particleSystem1];

    particleSystem2 = [[CGParticleSystem alloc] init];
    [particleSystem2 startEmission];
    [particleSystem2 translate:CC3VectorMake(10, -5, 10)];
    [renderer addNode:particleSystem2];
    
    particleSystem3 = [[CGParticleSystem alloc] init];
    [particleSystem3 startEmission];
    [particleSystem3 translate:CC3VectorMake(-10, -5, -10)];
    [renderer addNode:particleSystem3];
    
    particleSystem4 = [[CGParticleSystem alloc] init];
    [particleSystem4 startEmission];
    [particleSystem4 translate:CC3VectorMake(-10, -5, 10)];
    [renderer addNode:particleSystem4];
    
    
    box = [CGObject3D cube];
    
    [box setTexture: [[TextureManager sharedInstance] textureFromFileName:@"tile_floor.png"]];
    [box rotate:cc3v(30, 10, -30)];
    [box scale:CC3VectorMake(9, 9, 9)];
    box.specularFactor = 0.2;
    box.textureScale = 4;
    //[renderer addObject:box];
    
    [self runLoop];
}


- (void)runLoop {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    frameTimestamp = CACurrentMediaTime();
}

- (void)render:(CADisplayLink*)displayLink {
    
    
    currentTime = CFAbsoluteTimeGetCurrent();
    renderTime = (currentTime - frameTimestamp);
    
	frameTimestamp = currentTime;
    
    [renderer clear];
    
    [self hadleEvents:displayLink];
    
    
    [particleSystem1 update:renderTime];
    [particleSystem2 update:renderTime];
    [particleSystem3 update:renderTime];
    [particleSystem4 update:renderTime];
    
    // ANIMATION STUFF ////////////////////////
    //TODO: Clase que maneje las animaciones (Animation manager) por objeto; (animation completation)
    
    float pers = knight.animationCompletePercentage;

    
    if([knight.currentAnimation.name isEqualToString:@"Run"]){
        pers    += 0.3f*renderTime;
        if(pers >=1.0f){
            pers = 0.0f;
        }
    }else if([knight.currentAnimation.name isEqualToString:@"Stand"]){
        pers    += direction*0.01f;
        if(direction == 1.0f && knight.currentAnimation.finalFrame == knight.frameIndex){
            direction = -1.0f;
            pers    += direction*0.02f;
        }
        if(direction == -1.0f && knight.currentAnimation.initialFrame == knight.frameIndex &&pers <0.0f ){
            direction = 1.0f;
            pers    = 0.0f;
        }
    }
    
    [box rotate:cc3v(1, 1, 1)];
    
    knight.animationCompletePercentage = pers;
  // [light translate:cc3v(0.00, 0.0, 0.1)];
  //  [particleSystem translate:cc3v(0.00, 0.0, -0.1)];
    
    ////////////////////////////////////////////////////
    [cgview.renderer render];
}


- (void)hadleEvents:(CADisplayLink*)displayLink{

    if(rotUp || rotDown || rotLeft || rotRight ){
        
        float rotation = 50.0f*renderTime;
        
        CC3Vector p = renderer.camera.position;
        CC3Vector r = renderer.camera.rotation;
        
        [renderer.camera translate:CC3VectorMake(
                                                       -cgview.renderer.camera.position.x,
                                                       -cgview.renderer.camera.position.y,
                                                       -cgview.renderer.camera.position.z)];
        if(rotUp || rotDown ){
        
            //Respect the rotation YXZ order
            
            [renderer.camera.viewMatrix rotateByY:-cgview.renderer.camera.rotation.y];
        
            [renderer.camera rotate:CC3VectorMake(rotUp?-rotation:rotation,0,0)];
            
            [renderer.camera.viewMatrix rotateByY:r.y];

        
        }else if(rotLeft || rotRight ){
            
            [renderer.camera rotate:CC3VectorMake(0,rotLeft?-rotation:rotation,0)];
            
        }
        
        [renderer.camera translate:CC3VectorMake( p.x, p.y, p.z)];
    }

    float movement = 10.0f*renderTime;
    
    if(moveBwd || moveFwd){
        [renderer.camera translate:CC3VectorMake(0, 0, moveFwd?movement:-movement)];
    }
    
    if(moveRight || moveLeft){
        [renderer.camera translate:CC3VectorMake(moveRight?-movement:movement,0, 0)];
    }
}

- (IBAction)changeIlumination:(id)sender {
    
    if(iluminated){
    
        renderer.ambientLightIntensity = 0.4f;
        [skybox setColor:(ccColor4F){0.5,0.5,0.5,1.0}];
        floor.lightAffected = YES;
    }else{
        
        renderer.ambientLightIntensity = 0.7f;
        [skybox setColor:(ccColor4F){1.0,1.0,1.0,1.0}];
        floor.lightAffected = NO;
    }
    
    iluminated = !iluminated;
}

- (IBAction)rotUpTouchUp:(id)sender {rotUp = false;}
- (IBAction)rotUpTouchDown:(id)sender {rotUp = true;}

- (IBAction)rotDownTouchUp:(id)sender{rotDown = false;}
- (IBAction)rotDownTouchDown:(id)sender{rotDown = true;}

- (IBAction)rotRightTouchUp:(id)sender{rotRight = false;}
- (IBAction)rotRightTouchDown:(id)sender{rotRight = true;}

- (IBAction)rotLeftTouchUp:(id)sender{rotLeft = false;}
- (IBAction)rotLeftTouchDown:(id)sender{rotLeft = true;}

- (IBAction)moveUpTouchUp:(id)sender{moveFwd = false;}
- (IBAction)moveUpTouchDown:(id)sender{moveFwd = true;}

- (IBAction)moveDownTouchUp:(id)sender{moveBwd = false;}
- (IBAction)moveDownTouchDown:(id)sender{moveBwd = true;}

- (IBAction)moveRightTouchUp:(id)sender{moveRight = false;}
- (IBAction)moveRightTouchDown:(id)sender{moveRight = true;}

- (IBAction)moveLeftTouchUp:(id)sender{moveLeft = false;}
- (IBAction)moveLeftTouchDown:(id)sender{moveLeft = true;}

@end
