//
//

#import "CC3MeshNode.h"
#import "CGPointExtension.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3VertexArrayMesh.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3Light.h"
#import "LightrayMesh.h"


@interface ChristmasTree : NSObject {
    CC3MeshNode* mesh;
    CC3MeshNode* twigMesh;
    CC3MeshNode* ballMesh;
    int nodeindex;
    CC3Light* lamp;
    bool starInserted;
    float twistAdd;
    float twistTotal;
    CC3Scene* toScene;
    bool exploded;
    int growingStarStep;
    CC3MeshNode* starNode;
    CC3MeshNode* lightray;
    
    
    NSMutableArray* explodedBranches;
}

@property (assign,readwrite) CC3MeshNode* mesh;

- (void) updateStep; // Update one step.
- (void) create:(CC3Scene*) scene; // Initialize the tree
- (void) snowify:(float) percentage;
- (void) explode;
- (void) addStar;

@end

