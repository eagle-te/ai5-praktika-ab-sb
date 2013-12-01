package aufgabe5;

import aufgabe2.triangle.ITriangleMesh;
import aufgabe2.triangle.Triangle;
import aufgabe2.triangle.TriangleMesh;
import aufgabe3.TessellationUtils;

import javax.vecmath.Point3d;

/**
 * Created with IntelliJ IDEA.
 * User: abg667
 * Date: 07.11.13
 * Time: 16:02
 * To change this template use File | Settings | File Templates.
 */
public class Plane {
    public static ITriangleMesh create() {
        ITriangleMesh triangleMesh = new TriangleMesh();
        Point3d p0 = new Point3d(0, 0, 0);
        Point3d p1 = new Point3d(1, 0, 0);
        Point3d p2 = new Point3d(1, 1, 0);
        Point3d p3 = new Point3d(0, 1, 0);

        triangleMesh.addVertex(p0);
        triangleMesh.addVertex(p1);
        triangleMesh.addVertex(p2);
        triangleMesh.addVertex(p3);

        Triangle a = new Triangle(2, 3, 0);
        Triangle b = new Triangle(0, 1, 2);

        a.computeNormal(p2,p1,p0);
        b.computeNormal(p0,p1,p3);

        triangleMesh.addTriangle(a);
        triangleMesh.addTriangle(b);

        double boundingBox_x_low = 0.f, boundingBox_y_low = 0.f,
              boundingBox_x_max = 0.f, boundingBox_y_max = 0.f;

        Point3d vertex;
        for (int i = 0; i < triangleMesh.getNumberOfVertices(); i++) {
            vertex = triangleMesh.getVertex(i);

            if (vertex.x <= boundingBox_x_low) {
                boundingBox_x_low = vertex.x;
            }else if(vertex.x >= boundingBox_x_max){
                boundingBox_x_max = vertex.x;
            }

            if (vertex.y <= boundingBox_y_low) {
                boundingBox_y_low = vertex.y;
            }else if(vertex.y >= boundingBox_y_max){
                boundingBox_y_max = vertex.y;
            }
        }

        TessellationUtils.addTextureCoordinates(triangleMesh);

        return triangleMesh;
    }
}
