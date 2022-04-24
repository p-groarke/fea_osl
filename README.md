# fea_osl
3ds Max OSL shaders

## Shader Installation
- Download the [latest release](https://github.com/p-groarke/fea_osl/releases/latest) and unzip.
- In 3dsMax, add a user plugin folder (Customize > Configure User and System Paths > 3rd Party Plug-Ins).
- Add an `OSL` folder in that plugin folder.
- Copy the `FeaOSL` folder to your `OSL` directory.
- You should see the shader in your material editor drop-down on next 3dsMax launch.

## Curvalicious
Curvalicious is a fast (no raytracing) screen-space curvature shader. It outputs various maps related to curvature, edge detection and concave / convex faces.

<img src="doc/img/curvalicious_curvature_crab.png" width="49%" title="Curvature Map" alt="Shader Example">

[More details](doc/curvalicious.md)

## SimpleOcean
SimpleOcean is a Gerstner Wave implementation to simulate ocean vector displacement. It isn't highly complex, but should do the job when you need a quick & dirty ocean. The shader outputs a main vector displacement map and multiple utility maps, like foam maps, above sea map, etc.

<img src="doc/img/simpleocean_test1.png" width="49%" title="Test Render 1" alt="Shader Example">

[More details](doc/simple_ocean.md)