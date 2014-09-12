//
//  ASCView.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/11/14.
//
//

//  ASCView.h

#import "ASCView.h"

@implementation ASCView

- (void)loadScene {
    
    self.backgroundColor = [UIColor clearColor];
    self.allowsCameraControl = YES;
    [self loadSceneAndAnimations];
}


#pragma mark - Animation loading

- (void)loadSceneAndAnimations {
    // Load the character from one of our dae documents, for instance "idle.dae"
    //NSURL    *idleURL   = [[NSBundle mainBundle] URLForResource:@"idle" withExtension:@"dae"];
    //SCNScene *idleScene = [SCNScene sceneWithURL:idleURL options:nil error:nil];
    
    SCNScene *scene = [SCNScene sceneNamed:@"Untitled.dae"];
    self.scene = scene;
    //self.scene = [SCNScene scene];

    NSLog(@"scene: %@", self.scene);
    
    
    
    // ambient light
//    SCNLight * ambientLight = [[SCNLight alloc] init];
//    SCNNode * ambientLightNode = [[SCNNode alloc] init];
//    ambientLight.type=@"SCNLightTypeAmbient";
//    ambientLight.color = [UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
//    ambientLightNode.Light = ambientLight;
//    [self.scene.rootNode addChildNode:ambientLightNode];
//    
    
    SCNCamera *camera = [[SCNCamera alloc] init];
    camera.xFov=190;
    camera.yFov=190;
    SCNNode * cameraNode=[[SCNNode alloc] init];
    cameraNode.position=SCNVector3Make(0, 0, 800);
    cameraNode.camera=camera;
    [self.scene.rootNode addChildNode:cameraNode];
    
//    // Create two cameras - one for each scene
//    SCNCamera *leftCamera = [SCNCamera camera];
//    leftCamera.xFov = 45;   // Degrees, not radians
//    leftCamera.yFov = 45;
//    SCNNode *leftCameraNode = [SCNNode node];
//    leftCameraNode.camera = leftCamera;
//    leftCameraNode.position = SCNVector3Make(0, 0, 60);
//    [self.scene.rootNode addChildNode:leftCameraNode];
    
    
    // Create a torus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:8 pipeRadius:3];
    SCNNode *torusNode = [SCNNode nodeWithGeometry:torus];
    [self.scene.rootNode addChildNode:torusNode];
    
    // Create ambient light
    SCNLight *ambientLight = [SCNLight light];
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = [UIColor colorWithRed:.5 green:0 blue:0 alpha:1];
    ambientLightNode.light = ambientLight;
    [self.scene.rootNode addChildNode:ambientLightNode];
    
    // Create a diffuse light
    SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
    diffuseLightNode.position = SCNVector3Make(-30, 30, 50);
    [self.scene.rootNode addChildNode:diffuseLightNode];
    
//    CAKeyframeAnimation* animation;
//    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    
//    animation.duration = 2;
//    animation.repeatCount = 1;
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
//    
//    animation.values = [NSArray arrayWithObjects:
//                        [NSNumber numberWithFloat:(10.0 / 180.0) * M_PI],
//                        [NSNumber numberWithFloat:(20.0 / 180.0) * M_PI],
//                        [NSNumber numberWithFloat:(30.0 / 180.0) * M_PI], nil];
//    
//    [torusNode addAnimation:animation forKey:@"transform"];
    
    //self.scene = self.scene;
    //self.pointOfView = leftCameraNode;

    
    
    
    /*
    CGFloat cubeSide = .05;
    CGFloat halfSide = cubeSide/2.0;
    
    SCNVector3 positions[] = {
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide)
    };
    
    SCNVector3 normals[] = {
        
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        
        
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
    };
    
    
    // The indices for the 12 triangles that make up the cubes sides
    // Note the ordering to control the frontside and backside of each
    // surface.
    
    int indices[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
        // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
        // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
        // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
        // top
        4, 5, 6,
        5, 7, 6
    };
    
    
    // Create sources for the vertices and normals
    
    SCNGeometrySource *vertexSource =
    [SCNGeometrySource geometrySourceWithVertices:positions
                                            count:24];
    SCNGeometrySource *normalSource =
    [SCNGeometrySource geometrySourceWithNormals:normals
                                           count:24];
    
    
    
    
    
    NSData *indexData = [NSData dataWithBytes:indices
                                       length:sizeof(indices)];
    
    // Note that there is still only 12 indices for the 12 triangles
    // even though there are 24 vertices
    
    SCNGeometryElement *element =
    [SCNGeometryElement geometryElementWithData:indexData
                                  primitiveType:SCNGeometryPrimitiveTypeTriangles
                                 primitiveCount:12
                                  bytesPerIndex:sizeof(int)];
    
    
    SCNGeometry *geometry =
    [SCNGeometry geometryWithSources:@[vertexSource, normalSource]
                            elements:@[element]];
    
    */
    //SCNNode *cubeNode = [SCNNode nodeWithGeometry:geometry];

    //[self.scene.rootNode addChildNode:cubeNode];
    
    
    // Merge the loaded scene into our main scene in order to
    //   place the character in our own scene
    //for (SCNNode *child in idleScene.rootNode.childNodes) [self.scene.rootNode addChildNode:child];
    
    // Load and start run animation
    // The animation identifier can be found in the Node Properties inspector of the Scene Kit editor integrated into Xcode
    //[self loadAndStartAnimation:@"run" withIdentifier:@"RunID"];
    
}

- (void)loadAndStartAnimation:(NSString *)sceneName withIdentifier:(NSString *)animationIdentifier {
    NSURL          *sceneURL        = [[NSBundle mainBundle] URLForResource:sceneName withExtension:@"dae"];
    SCNSceneSource *sceneSource     = [SCNSceneSource sceneSourceWithURL:sceneURL options:nil];
    CAAnimation    *animationObject = [sceneSource entryWithIdentifier:animationIdentifier withClass:[CAAnimation class]];
    
    
    NSLog(@"duration: %f", [animationObject duration]); //0.9
    
    animationObject.duration = 1.0;
    animationObject.repeatCount = INFINITY;
    
    
    [self.scene.rootNode addAnimation:animationObject forKey:@"foofoofoo"];
    
    NSLog(@"animation: %@",[self.scene.rootNode animationForKey: @"foofoofoo"]);
    NSLog(@"is paused: %@",[self.scene.rootNode isAnimationForKeyPaused: @"foofoofoo"] ? @"yes" : @"no"); //NO
}



@end