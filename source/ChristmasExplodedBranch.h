//
//

#import "CC3MeshNode.h"
#import "CGPointExtension.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3VertexArrayMesh.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3Light.h"


@interface ChristmasExplodedBranch : NSObject {
    CC3MeshNode* mesh;
    CC3Vector speed;
    CC3Vector rotationSpeed;
    float twistTotal;
    float twistAdd;
}

@property (assign,readwrite) CC3MeshNode* mesh;
@property (readwrite) CC3Vector rotationSpeed;
@property (readwrite) CC3Vector speed;

- (void) updateStep; // Update one step.

@end

