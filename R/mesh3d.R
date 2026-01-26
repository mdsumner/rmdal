#' Convert MDAL Mesh to mesh3d Object
#'
#' Creates a mesh3d object (compatible with the rgl package) from an MDAL mesh.
#' The mesh3d format is created directly without requiring rgl as a dependency.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#' @param type Type of mesh3d to create:
#'   \describe{
#'     \item{`"wire"`}{Wireframe using face edges as line segments (default).
#'       Works for any face topology (triangles, quads, n-gons).}
#'     \item{`"solid"`}{Solid mesh for filled rendering. Requires uniform
#'       face sizes (all triangles or all quads).
#'       Mixed meshes will error - use `type = "wire"` instead.}
#'   }
#'
#' @return A list of class `c("mesh3d", "shape3d")` with components:
#'   \describe{
#'     \item{vb}{4 x n matrix of vertices in homogeneous coordinates (x, y, z, 1)}
#'     \item{is}{2 x n matrix of segment indices (for wireframe)}
#'     \item{it}{3 x n matrix of triangle indices (for solid triangles)}
#'     \item{ib}{4 x n matrix of quad indices (for solid quads)}
#'     \item{material}{list of material properties (empty by default)}
#'     \item{normals}{NULL (not computed)}
#'     \item{texcoords}{NULL (not computed)}
#'   }
#'
#' @details
#' The mesh3d object can be visualized with rgl functions like `wire3d()`,
#' `shade3d()`, or `dot3d()` if rgl is installed, but rgl is not required
#' to create the object.
#'
#' For `type = "wire"`, edges are extracted from face boundaries. Each face
#' contributes edges connecting consecutive vertices, forming a closed ring.
#' This is the safest option as it works regardless of face topology.
#'
#' For `type = "solid"`, faces must be either all triangles (3 vertices) or
#' all quads (4 vertices). Mixed meshes or faces with more than 4 vertices
#' will raise an error.
#'
#' @export
#' @seealso [mdal_load()], [mdal_mesh_vertices()], [mdal_mesh_faces()]
#' @examples
#' \dontrun{
#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
#' m3d <- mdal_as_mesh3d(mesh)
#'
#' # Visualize with rgl (if installed)
#' if (requireNamespace("rgl", quietly = TRUE)) {
#'   rgl::wire3d(m3d)
#' }
#'
#' # Or solid rendering for triangle meshes
#' m3d_solid <- mdal_as_mesh3d(mesh, type = "solid")
#' rgl::shade3d(m3d_solid)
#' }
mdal_as_mesh3d <- function(mesh, type = c("wire", "solid")) {
  type <- match.arg(type)


  # Get vertices as Nx3 matrix
  verts <- mdal_mesh_vertices(mesh)
  nv <- nrow(verts)

  # Convert to 4xN homogeneous coordinates (x, y, z, 1)
  # mesh3d wants columns as vertices
  vb <- rbind(t(verts), rep(1, nv))
  rownames(vb) <- c("x", "y", "z", "w")

  if (type == "wire") {
    # Get faces and extract edges
    faces <- mdal_mesh_faces(mesh)

    # Extract edges from face boundaries
    # Also include any 1D edges from the mesh
    face_edges <- extract_face_edges(faces)
    mesh_edges <- mdal_mesh_edges(mesh)

    # Combine face boundary edges and 1D mesh edges
    if (nrow(mesh_edges) > 0) {
      all_edges <- rbind(face_edges, mesh_edges)
    } else {
      all_edges <- face_edges
    }

    # mesh3d uses 2 x n matrix for segments (is)
    # Transpose so columns are edges
    is_matrix <- t(all_edges)
    rownames(is_matrix) <- NULL

    result <- list(
      vb = vb,
      is = is_matrix,
      material = list(),
      normals = NULL,
      texcoords = NULL,
      meshColor = "vertices"
    )

  } else {
    # Solid mesh - check face sizes
    faces <- mdal_mesh_faces(mesh)
    sizes <- lengths(faces)
    unique_sizes <- unique(sizes)

    if (length(unique_sizes) > 1) {
      stop("Solid mesh3d requires uniform face sizes. ",
           "Found faces with ", paste(sort(unique_sizes), collapse = ", "),
           " vertices. Use type = 'wire' for mixed meshes.")
    }

    if (length(unique_sizes) == 0) {
      stop("Mesh has no faces")
    }

    face_size <- unique_sizes[1]

    if (face_size == 3) {
      # Triangles -> it matrix (3 x n)
      it <- matrix(unlist(faces), nrow = 3)
      result <- list(
        vb = vb,
        it = it,
        primitivetype = "triangle",
        material = list(),
        normals = NULL,
        texcoords = NULL,
        meshColor = "vertices"
      )

    } else if (face_size == 4) {
      # Quads -> ib matrix (4 x n)
      ib <- matrix(unlist(faces), nrow = 4)
      result <- list(
        vb = vb,
        ib = ib,
        primitivetype = "quad",
        material = list(),
        normals = NULL,
        texcoords = NULL,
        meshColor = "vertices"
      )

    } else {
      stop("Solid mesh3d only supports triangles (3 vertices) or quads (4 vertices). ",
           "Found faces with ", face_size, " vertices. ",
           "Use type = 'wire' for other face types.")
    }
  }

  class(result) <- c("mesh3d", "shape3d")
  result
}

#' Extract Edge Indices from Face List
#'
#' Internal function to extract edges from a list of face vertex indices.
#' Each face contributes edges connecting consecutive vertices (closing the ring).
#'
#' @param faces List of integer vectors, each giving vertex indices for a face.
#' @return Matrix with n rows and 2 columns (start, end) of edge vertex indices.
#' @keywords internal
#' @noRd
extract_face_edges <- function(faces) {
  if (length(faces) == 0) {
    return(matrix(integer(0), ncol = 2, dimnames = list(NULL, c("start", "end"))))
  }

  # Pre-allocate: each face with k vertices has k edges
  total_edges <- sum(lengths(faces))
  edges <- matrix(0L, nrow = total_edges, ncol = 2)

  idx <- 1L
  for (face in faces) {
    n <- length(face)
    if (n < 2) next

    for (i in seq_len(n)) {
      # Edge from vertex i to vertex i+1 (wrapping to 1)
      j <- if (i == n) 1L else i + 1L
      edges[idx, 1] <- face[i]
      edges[idx, 2] <- face[j]
      idx <- idx + 1L
    }
  }

  colnames(edges) <- c("start", "end")
  edges
}

#' Get Mesh Vertices
#'
#' Returns all vertex coordinates from a mesh as an Nx3 matrix.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#' @return Numeric matrix with N rows (vertices) and 3 columns (x, y, z).
#' @export
#' @seealso [mdal_load()], [mdal_mesh_faces()], [mdal_mesh_edges()]
#' @examples
#' \dontrun{
#' mesh <- mdal_load("mesh.2dm")
#' v <- mdal_mesh_vertices(mesh)
#' head(v)
#' #>          x        y z
#' #> [1,] 0.000    0.000 0
#' #> [2,] 1.000    0.000 0
#' }
mdal_mesh_vertices <- function(mesh) {
  mdal_mesh_vertices_(mesh)
}

#' Get Mesh Faces
#'
#' Returns all face definitions from a mesh as a list of vertex index vectors.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#' @return List of integer vectors, each giving the 1-based vertex indices
#'   that define a face. Faces may have varying numbers of vertices
#'   (triangles, quads, or n-gons).
#' @export
#' @seealso [mdal_load()], [mdal_mesh_vertices()], [mdal_mesh_edges()]
#' @examples
#' \dontrun{
#' mesh <- mdal_load("mesh.2dm")
#' f <- mdal_mesh_faces(mesh)
#' f[[1]]  # First face vertex indices
#' #> [1] 1 2 5 4
#' lengths(f)  # Vertices per face
#' #> [1] 4 4 3 3
#' }
mdal_mesh_faces <- function(mesh) {
  mdal_mesh_faces_(mesh)
}

#' Get Mesh Edges (1D Elements)
#'
#' Returns the 1D edge elements from a mesh. These are distinct from face
#' boundaries - they represent explicit 1D mesh elements (e.g., channels,
#' rivers in 1D/2D coupled models).
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#' @return Integer matrix with N rows (edges) and 2 columns (start, end)
#'   giving the 1-based vertex indices for each edge.
#' @export
#' @seealso [mdal_load()], [mdal_mesh_vertices()], [mdal_mesh_faces()]
#' @examples
#' \dontrun{
#' mesh <- mdal_load("mesh_with_1d.nc")
#' e <- mdal_mesh_edges(mesh)
#' nrow(e)  # Number of 1D edges
#' }
mdal_mesh_edges <- function(mesh) {
  mdal_mesh_edges_(mesh)
}
