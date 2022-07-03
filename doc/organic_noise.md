# Organic Noise
This shader filters and modulates a Simplex noise to generate new organicy looking noises. There are many knobs and dials, so you should be able to tweak to your heart's content.

Fundamentally, the algorithm uses the noise gradient, its magnitude and direction to morph the simplex in various ways. This seemed like a neat thing to do.

<!-- <a href="https://www.youtube.com/watch?v=hg3oJkCNjzg"><img src="img/curvalicious_play.png" width="98.5%" title="Play Demo"></a> -->

### Possible Noises
A collection of noise maps generated using the shader.

<img src="img/organic_noise.png" width="49%" title="Organic Noise" alt="Shader Example">

## Known Issues
- So far there aren't any, but since the shader must sample Simplex many times, I guess it may be a bit slow in some circumstances. TBD.
- Zap I need Dx and Dy in Arnold pleaaaase.
