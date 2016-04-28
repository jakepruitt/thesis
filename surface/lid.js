function lid(mesh, z) {
    var clippedEdges = findEdges(mesh, z);
    var avg = clippedEdges.reduce(function(avg, edge) {
        return {
            x: avg.x + mesh.vertices[edge[0]].x/clippedEdges.length,
            y: avg.y + mesh.vertices[edge[0]].y/clippedEdges.length
        };
    },{x:0,y:0});
    var clockwiseEdges = reverse(clippedEdges);
    var middlepoint = mesh.vertices.length;
    var faces = clockwiseEdges.map(function(edge) {
        return {
            a: edge[0],
            b: edge[1],
            c: middlepoint
        };
    });

    mesh.vertices.push({x:avg.x,y:avg.y,z:z});
    return {
        faces: mesh.faces.slice().concat(faces),
        vertices: mesh.vertices.slice()
    };
}

function reverse(edges) {
    return edges.map(function(edge) {
        return [edge[1],edge[0]];
    }).reverse();
}

// Finds the edges (with the right ordering)
function findEdges(mesh, z) {
    var threshold = 0.00000000001;
    return mesh.faces.reduce(function(topEdges, face, i) {
        var aTop = Math.abs(mesh.vertices[face.a].z - z) < threshold;
        var bTop = Math.abs(mesh.vertices[face.b].z - z) < threshold;
        var cTop = Math.abs(mesh.vertices[face.c].z - z) < threshold;

        if (aTop && bTop) return topEdges.concat([[face.a, face.b]]);
        else if (bTop && cTop) return topEdges.concat([[face.b, face.c]]);
        else if (cTop && aTop) return topEdges.concat([[face.c, face.a]]);
        else return topEdges;
    }, []);
}
