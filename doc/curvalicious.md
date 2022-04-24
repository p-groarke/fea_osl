# Curvalicious
Curvalicious is a fast (no raytracing) screen-space curvature OSL shader. It outputs various maps related to curvature, edge detection and concave / convex faces.

It is implemented using [Vergne et al. 2009](#citation) with additional processes to improve detection at silhouette and for invalid samples (samples perpendicular to camera). These additions make the detection much more stable at different viewing angles.

### Curvature Map
A red/blue map. Red curves are concave, blue curves are convex, black denotes little curvature.

<img src="doc/img/curvalicious_curvature_crab.png" width="49%" title="Curvature Map" alt="Shader Example"> <img src="doc/img/curvalicious_curvature.png" width="49%" title="Curvature Map" alt="Shader Example">

### Curvature Grayscale Map
Same as curvature map, but in grayscale. Ignores concave / convex differentiation.

<img src="doc/img/curvalicious_curvature_grayscale_crab.png" width="49%" title="Curvature Grayscale Map" alt="Shader Example"> <img src="doc/img/curvalicious_curvature_grayscale.png" width="49%" title="Curvature Grayscale Map" alt="Shader Example">

### Edge Detect Map
A typical edge detect algorithm, ran using the screen-space curvature extracted at previous stages.

<img src="doc/img/curvalicious_edge_detect_crab.png" width="49%" title="Edge Detect Map" alt="Shader Example"> <img src="doc/img/curvalicious_edge_detect.png" width="49%" title="Edge Detect Map" alt="Shader Example">

### Concave Triangles Map
Marks concave triangles in white (convex in black).

<img src="doc/img/curvalicious_concave_tris_crab.png" width="49%" title="Concave Tris Map" alt="Shader Example"> <img src="doc/img/curvalicious_concave_tris.png" width="49%" title="Concave Tris Map" alt="Shader Example">

## Known Issues
- Currently unsupported in Arnold.
  - The shader use OSL derivative functionality (`Dx`, `Dy`, `filterwidth`), which isn't supported in Arnold currently.

## Algorithmic Improvements
### Silhouette elimination in screen-space normal field curvature analysis
The Vergne et al. technique includes silhouettes as extra curvature. This biases the curvature detection and leads to inconsistent curvature detection at different viewing angles.
To correct this, we multiple the gradient (gx, gy) by a correction factor. We use the absolute value of camera space Normal z. Nz is equivalent to the dot product of our current sample with the camera. By doing so, we effectively "flatten" the 3d mesh in screen-space, which allows us to extract its local height information without silhouette bias. The gradient is also normalized to pixel size, to scale with camera distance.

### Epsilon edge case
The algorithm cannot divide by zero. When Normal z is below an epsilon threshold, we assign Nz = epsilon. Doing so, and using the new value throughout the evaluation, fixes visual errors for invalid samples (very bright pixels). Without this correction, the edge detection will identify lines at neighboring samples of invalid Nz, which causes visual artifacting. We cannot simply set invalid samples to 0, or use diverging if statements due to `Dx` and how it works on GPUs. By re-interpreting the below epsilon Nz as epsilon, we create "incorrect" / approximated samples, but this fixes the visual problems.

## Citation
Romain Vergne, Romain Pacanowski, Pascal Barla, Xavier Granier, Christophe Schlick.
Light Warping for Enhanced Surface Depiction.
ACM Transactions on Graphics, Association for Computing Machinery, 2009, 28 (3), pp.25:1–25:8.
ff10.1145/1531326.1531331ff. ffinria-00400829
[https://hal.inria.fr/inria-00400829](https://hal.inria.fr/inria-00400829)
