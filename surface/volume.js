function volume(geom) {
    var v = geom.vertices;
    return Math.abs(geom.faces.reduce(function(V,f) {
        return V + 1/6*(-v[f.c].x*v[f.b].y*v[f.a].z +
            v[f.b].x*v[f.c].y*v[f.a].z +
            v[f.c].x*v[f.a].y*v[f.b].z -
            v[f.a].x*v[f.c].y*v[f.b].z -
            v[f.b].x*v[f.a].y*v[f.c].z +
            v[f.a].x*v[f.b].y*v[f.c].z
            );
    }, 0));
}

/*
if (module) module.exports = volume;
*/
