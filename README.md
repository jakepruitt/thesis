<img width="1392" alt="screenshot 2016-04-02 19 22 26" src="https://cloud.githubusercontent.com/assets/5084263/14230405/4ffce754-f90a-11e5-84ae-1e2489444e9e.png">

# Thesis Prospectus
Currently in the Earth and Space Exploration laboratory, geochronology is an incredibly important part of the work and papers that are produced by the department. In order to calculate the age of a rock, an ablation must be made in the rock’s face and a laser pointed into the ablation map the depth of the entire pit. The important step in this process is the calculation of the volume of the pit, which is done currently in a Matlab function created by the students of the lab. This calculation has been used in publications to date, but there are not currently rigorously tested measures of the algorithm’s accuracy.

The current needs of the project are to improve upon this calculation, rewriting the algorithm to use advanced numerical analysis to gain more insight into the accuracy of the process. The goal of the thesis is to design and develop an intuitive and highly accurate software interface to measure the volume of a rock ablation. The software will allow the user to manually adjust parameters, visually see the algorithm at work, and determine the optimal parameters for minimizing error. The benefits of this work will be an increased visibility to the process of calculating rock ablation volume, as well as creating verifiable accuracy measurements. I also want to make this tool useful and simple, so that it can be maintained and used by the lab long into the future.

I’m interested in this project from the perspective of applying geographical analysis software to a problem that it has not used it before. The problem draws a substantial influence from geographical information systems software, where a very similar algorithm could be used to calculate the volume of a lake or valley. I am very interested in exploring geology, and determining how the tools described in my majors such as numerical analysis and data visualization can be applied to problems outside of my majors.

In order to prepare for this project, I will be spending time working closely with Dr. Hodges and Cameron Mercer to see how they interact with their current tools, as well as learn how the rest of the lab uses tools for geochronological analysis. While spending time researching and sketching how the interface for the tool should optimally be designed, I will be diving into the math and algorithms of the Matlab code, understanding how the operations for volume calculation really work, and porting that algorithm into the target language. There will be research needed in hillshading/depth calculation for other potential algorithms, from GIS research, numerical analysis, and satellite imagery analysis.

My sources and guides will primarily be Dr. Hodges, Cameron Mercer and the rest of the users of this software. I will also be leaning heavily upon research in geographic information systems. I will be asking members of the GIS community for examples of software that are useful for visualizing and analyzing similar problems. In developing a testable measure for the accuracy of the volume calculation I will probably need guidance from papers on numerical analysis, experiment design, and probability theory.

# Resources

- Papers we love SF talk on lidar -> surface algorithms https://www.youtube.com/watch?v=7dc4Tl5ZHRg
- Lorensen & Cline, Marching Cubes, SIGGRAPH 1987
- Paul Bourke, Polygonizing a Scalar Field Using Tetrahedrons, Website
- Ju et al. Dual Contouring of Hermite Data, SIGGRAPH 2002
- Schaefer & Warren. Dual Contouring: "The Secret Sauce", White Paper
- links to many papers: https://swiftcoder.wordpress.com/planets/isosurface-extraction
- http://cesiumjs.org/
- https://github.com/AnalyticalGraphicsInc/cesium
- https://www.mapbox.com/blog/elevation-drone-data-surface-api/
- https://github.com/mapbox/pointcloud
- http://www.geometrictools.com/Documentation/ClipMesh.pdf
- http://research.microsoft.com/en-us/um/people/chazhang/publications/icip01_ChaZhang.pdf
- https://github.com/prototypable/vcglib
- https://github.com/cnr-isti-vclab/meshlabjs
- https://github.com/svn2github/meshlab
- https://github.com/Microsoft/Mesh-processing-library
- https://github.com/mkazhdan/PoissonRecon
- http://www.cs.jhu.edu/~misha/MyPapers/SGP06.pdf
- http://www.cs.jhu.edu/~misha/MyPapers/ToG13.pdf
- https://en.wikipedia.org/wiki/Age_of_the_universe
- http://pubs.usgs.gov/gip/geotime/age.html
- https://www.cs.sfu.ca/~haoz/teaching/cmpt464/references/92_Hoppe_SurfRecon.pdf
- http://ac.els-cdn.com/S1053811998903950/1-s2.0-S1053811998903950-main.pdf?_tid=13f07964-0dd3-11e6-81e9-00000aacb35e&acdnat=1461911270_43faa3e678aa689fa802c3e0efe2a07c
