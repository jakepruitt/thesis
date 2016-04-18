#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>

using namespace std;

// VCG headers
#include <vcg/complex/complex.h>
#include <vcg/complex/algorithms/pointcloud_normal.h>
#include <wrap/io_trimesh/import.h>
#include <wrap/io_trimesh/export.h>
#include <wrap/io_trimesh/io_mask.h>

using namespace vcg;

class CVertex;
class CFace;

struct MyTypes: public UsedTypes< Use<CVertex>::AsVertexType,Use<CFace>::AsFaceType>{};

class CVertex  : public Vertex< MyTypes, vertex::VFAdj, vertex::Coord3f,vertex::BitFlags, vertex::Normal3f > {};
class CFace    : public Face< MyTypes, face::FFAdj, face::VFAdj, face::VertexRef, face::Normal3f, face::BitFlags, face::Mark > {};
class CMesh    : public vcg::tri::TriMesh< vector<CVertex>, vector<CFace> > {};

int main(int argc, char *argv[]) {
    CMesh m;

    if (argc < 3)
    {
        cout << "Please provide an input file and output file" << endl;
    }

    char *input = argv[1];
    char *output = argv[2];

    int err = tri::io::Importer<CMesh>::Open(m,input);
    if (err)
    {
        printf("\n    Error during loading %s: '%s'\n", input, tri::io::ImporterPLY<CMesh>::ErrorMsg(err));
        return 1;
    } else {
        tri::PointCloudNormal<CMesh>::Param p;
        vcg::CallBackPos * cb=0;
        tri::PointCloudNormal<CMesh>::Compute(m, p,cb);
        int err = tri::io::Exporter<CMesh>::Save(m,output,tri::io::Mask::IOM_VERTNORMAL);
        if (err) {
            printf("\n    Error during writing %s: '%s'\n", output, tri::io::ImporterPLY<CMesh>::ErrorMsg(err));
            return 1;
        } else {
            printf("\n Succefully wrote to %s\n", output);
            return 0;
        }
    }
}
