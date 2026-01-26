# rgl mesh3d Format Reference

## Structure

A `mesh3d` object is just a list with class `c("mesh3d", "shape3d")`:

```r
list(
  # REQUIRED: Vertices in homogeneous coordinates (4 x n matrix)
  vb = matrix(c(x1, x2, ...,     # row 1: x coordinates
                y1, y2, ...,     # row 2: y coordinates  
                z1, z2, ...,     # row 3: z coordinates
                1,  1,  ...),    # row 4: w (always 1 for our use)
              nrow = 4),
  
  # GEOMETRY (at least one required):
  ip = matrix(..., nrow = 1),    # Point indices (1 x n)
  is = matrix(..., nrow = 2),    # Segment indices (2 x n) - for wireframe
  it = matrix(..., nrow = 3),    # Triangle indices (3 x n)
  ib = matrix(..., nrow = 4),    # Quad indices (4 x n)
  
  # OPTIONAL:
  normals = NULL,                 # 4 x n normal vectors (homogeneous)
  texcoords = NULL,               # 2 x n texture coordinates
  material = list(),              # color, alpha, texture, etc.
  meshColor = "vertices"          # How colors apply: "vertices", "edges", "faces"
)
```

## Key Points

1. **Vertices are columns, not rows** - `vb` has 4 rows (x,y,z,w) and n columns

2. **Indices are 1-based** (R convention)

3. **Homogeneous coordinates** - the 4th row is always 1 for standard use (allows transformation matrices)

4. **Index matrices are also column-oriented**:
   - `is[,i]` gives the two vertex indices for segment i
   - `it[,i]` gives the three vertex indices for triangle i
   - `ib[,i]` gives the four vertex indices for quad i

## Example: Creating a Simple Triangle

```r
# Triangle with vertices at (0,0,0), (1,0,0), (0.5,1,0)
m3d <- list(
  vb = matrix(c(
    0,   1,   0.5,  # x
    0,   0,   1,    # y
    0,   0,   0,    # z
    1,   1,   1     # w
  ), nrow = 4, byrow = TRUE),
  it = matrix(c(1, 2, 3), nrow = 3),  # One triangle using all 3 vertices
  material = list(),
  normals = NULL,
  texcoords = NULL
)
class(m3d) <- c("mesh3d", "shape3d")

# Render with rgl
rgl::shade3d(m3d)
```

## Example: Wireframe from MDAL Mesh

For MDAL meshes with mixed face sizes (triangles + quads + n-gons), wireframe is the safe choice:

```r
# Each face [v1, v2, v3, v4] contributes edges:
# v1-v2, v2-v3, v3-v4, v4-v1

# The `is` matrix has 2 rows:
# is[1,] = start vertex indices
# is[2,] = end vertex indices

m3d <- list(
  vb = ...,  # 4 x nvertices
  is = matrix(c(
    1, 2, 3, 4,  # start vertices of edges
    2, 3, 4, 1   # end vertices of edges  
  ), nrow = 2, byrow = TRUE),
  material = list(),
  normals = NULL,
  texcoords = NULL
)
class(m3d) <- c("mesh3d", "shape3d")

# Render wireframe
rgl::wire3d(m3d)
```

## MDAL to mesh3d Mapping

| MDAL | mesh3d | Notes |
|------|--------|-------|
| Vertices (Nx3) | vb (4xN) | Transpose + add row of 1s |
| Triangular faces | it (3xN) | Direct mapping |
| Quad faces | ib (4xN) | Direct mapping |
| Mixed faces | is (2xN) | Extract face boundaries as edges |
| 1D edges | is (2xN) | Direct mapping to segments |

## Data Model Fidelity

```
MDAL (full model)
├── vertices + faces + edges + volumes + temporal datasets
│
├─► mesh3d solid (it/ib)
│   └── Loses: temporal data, mixed topology, volumes
│       Only works for pure triangles OR pure quads
│
└─► mesh3d wireframe (is)  
    └── Loses: temporal data, volumes, face semantics
        Works for ANY topology
        Natural for 1D meshes

    ↓ Further conversion
    
wk/sf polygons
    └── Loses: true 3D, face indices, mesh topology
        Triangles become "polygons"
```

## References

- rgl docs: https://dmurdoch.github.io/rgl/reference/mesh3d.html
- Source: https://github.com/dmurdoch/rgl/blob/master/R/mesh3d.R
