# Test file paths helper
mdal_test_file <- function(path) {
  system.file(file.path("extdata/MDAL/tests/data", path),
              package = "rmdal", mustWork = TRUE)
}

# ============================================================================
# Basic loading and driver tests
# ============================================================================

test_that("mdal_version returns a version string", {
  v <- mdal_version()
  expect_type(v, "character")
  expect_match(v, "^[0-9]+\\.[0-9]+")
})

test_that("mdal_last_status returns integer", {
  expect_type(mdal_last_status(), "integer")
})

test_that("mdal_drivers returns a data frame", {
  drv <- mdal_drivers()
  expect_s3_class(drv, "data.frame")
  expect_true("name" %in% names(drv))
  expect_true("can_read_mesh" %in% names(drv))
  expect_gt(nrow(drv), 0)
})

# ============================================================================
# 2DM format tests
# ============================================================================

test_that("load 2DM with mixed triangles and quads", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))

  expect_equal(mdal_mesh_vertex_count(mesh), 5)
  expect_equal(mdal_mesh_face_count(mesh), 2)
  expect_equal(mdal_mesh_edge_count(mesh), 0)
  expect_equal(mdal_mesh_driver_name(mesh), "2DM")

  # Check faces have different sizes (tri + quad)
  faces <- mdal_mesh_faces(mesh)
  expect_equal(length(faces), 2)
  sizes <- sort(lengths(faces))
  expect_equal(sizes, c(3, 4))
})

test_that("load 2DM with pure 1D edges (lines)", {
  mesh <- mdal_load(mdal_test_file("2dm/lines.2dm"))

  expect_equal(mdal_mesh_face_count(mesh), 0)
  expect_equal(mdal_mesh_edge_count(mesh), 3)
  expect_gt(mdal_mesh_vertex_count(mesh), 0)

  # Check edge data
  edges <- mdal_mesh_edges(mesh)
  expect_equal(nrow(edges), 3)
  expect_equal(ncol(edges), 2)
  #expect_equal(colnames(edges), c("start", "end"))
})

test_that("load 2DM with hexagonal faces", {
  mesh <- mdal_load(mdal_test_file("2dm/triangleE6T.2dm"))

  faces <- mdal_mesh_faces(mesh)
  sizes <- unique(lengths(faces))
  expect_true(6 %in% sizes)  # Has hexagons
})

test_that("load 2DM with mixed faces and edges", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_line.2dm"))

  expect_gt(mdal_mesh_face_count(mesh), 0)
  expect_gt(mdal_mesh_edge_count(mesh), 0)
  expect_gt(mdal_mesh_dataset_group_count(mesh), 1)
})

# ============================================================================
# Other driver tests
# ============================================================================

test_that("load Mike21 mesh with CRS", {
  mesh <- mdal_load(mdal_test_file("mike21/small.mesh"))

  expect_equal(mdal_mesh_driver_name(mesh), "Mike21")
  expect_gt(mdal_mesh_vertex_count(mesh), 0)

  # Mike21 should have CRS
  crs <- mdal_mesh_projection(mesh)
  expect_type(crs, "character")
  expect_gt(nchar(crs), 0)
})

test_that("load PLY mesh with multiple dataset groups", {
  mesh <- mdal_load(mdal_test_file("ply/all_features.ply"))

  expect_equal(mdal_mesh_driver_name(mesh), "PLY")
  expect_gt(mdal_mesh_dataset_group_count(mesh), 5)
})

test_that("load UGRID NetCDF mesh", {
  mesh <- mdal_load(mdal_test_file("ugrid/time_integer/simple_time_integer.nc"))

  expect_equal(mdal_mesh_driver_name(mesh), "Ugrid")
  expect_gt(mdal_mesh_vertex_count(mesh), 0)
})

test_that("load ESRI TIN (multi-file format)", {
  mesh <- mdal_load(mdal_test_file("esri_tin/mesh_simple/tdenv9.adf"))

  expect_equal(mdal_mesh_driver_name(mesh), "ESRI_TIN")
  expect_equal(mdal_mesh_vertex_count(mesh), 8)
  expect_equal(mdal_mesh_face_count(mesh), 7)
})

# ============================================================================
# Geometry extraction tests
# ============================================================================

test_that("mdal_mesh_vertices returns correct matrix", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))
  v <- mdal_mesh_vertices(mesh)

  expect_true(is.matrix(v))
  expect_equal(nrow(v), 5)
  expect_equal(ncol(v), 3)
  #expect_equal(colnames(v), c("x", "y", "z"))
})

test_that("mdal_mesh_faces returns list of indices", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))
  f <- mdal_mesh_faces(mesh)

  expect_type(f, "list")
  expect_equal(length(f), 2)

  # All indices should be valid (1-based, <= vertex count)
  all_idx <- unlist(f)
  expect_true(all(all_idx >= 1))
  expect_true(all(all_idx <= 5))
})

test_that("mdal_mesh_edges returns correct matrix for 1D mesh", {
  mesh <- mdal_load(mdal_test_file("2dm/lines.2dm"))
  e <- mdal_mesh_edges(mesh)

  expect_true(is.matrix(e))
  expect_equal(ncol(e), 2)
  #expect_equal(colnames(e), c("start", "end"))

  # All indices should be valid
  nv <- mdal_mesh_vertex_count(mesh)
  expect_true(all(e >= 1))
  expect_true(all(e <= nv))
})

test_that("mdal_mesh_edges returns empty matrix for 2D-only mesh", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))
  e <- mdal_mesh_edges(mesh)

  expect_true(is.matrix(e))
  expect_equal(nrow(e), 0)
})

test_that("mdal_mesh_extent returns valid bbox", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))
  ext <- mdal_mesh_extent(mesh)

  expect_type(ext, "list")
  expect_true(all(c("xmin", "xmax", "ymin", "ymax") %in% names(ext)))
  expect_true(ext$xmax >= ext$xmin)
  expect_true(ext$ymax >= ext$ymin)
})

# ============================================================================
# mesh3d conversion tests
# ============================================================================

test_that("mdal_as_mesh3d wireframe works for mixed topology", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))
  m3d <- mdal_as_mesh3d(mesh, type = "wire")

  expect_s3_class(m3d, "mesh3d")
  expect_s3_class(m3d, "shape3d")

  # Check vb structure (4 x n homogeneous coords)
  expect_equal(nrow(m3d$vb), 4)
  expect_equal(ncol(m3d$vb), 5)
  expect_equal(rownames(m3d$vb), c("x", "y", "z", "w"))
  expect_true(all(m3d$vb[4, ] == 1))  # w = 1

  # Check segment indices
  expect_true(!is.null(m3d$is))
  expect_equal(nrow(m3d$is), 2)
  # 1 triangle (3 edges) + 1 quad (4 edges) = 7 edges
  expect_equal(ncol(m3d$is), 7)
})

test_that("mdal_as_mesh3d wireframe works for hexagons", {
  mesh <- mdal_load(mdal_test_file("2dm/triangleE6T.2dm"))
  m3d <- mdal_as_mesh3d(mesh, type = "wire")

  expect_s3_class(m3d, "mesh3d")
  expect_true(!is.null(m3d$is))
})

test_that("mdal_as_mesh3d wireframe includes 1D edges", {
  mesh <- mdal_load(mdal_test_file("2dm/lines.2dm"))
  m3d <- mdal_as_mesh3d(mesh, type = "wire")

  expect_s3_class(m3d, "mesh3d")
  # Should have segments from the 1D edges
  expect_true(!is.null(m3d$is))
  expect_gt(ncol(m3d$is), 0)
})

test_that("mdal_as_mesh3d solid fails for mixed topology", {
  mesh <- mdal_load(mdal_test_file("2dm/quad_and_triangle.2dm"))

  expect_error(mdal_as_mesh3d(mesh, type = "solid"),
               "uniform face sizes")
})

test_that("mdal_as_mesh3d solid fails for hexagons", {
  mesh <- mdal_load(mdal_test_file("2dm/triangleE6T.2dm"))

  expect_error(mdal_as_mesh3d(mesh, type = "solid"))
})

test_that("mdal_as_mesh3d solid works for pure triangles", {
  mesh <- mdal_load(mdal_test_file("esri_tin/mesh_simple/tdenv9.adf"))

  faces <- mdal_mesh_faces(mesh)
  sizes <- unique(lengths(faces))

  # Only proceed if all triangles
  if (length(sizes) == 1 && sizes == 3) {
    m3d <- mdal_as_mesh3d(mesh, type = "solid")

    expect_s3_class(m3d, "mesh3d")
    expect_true(!is.null(m3d$it))
    expect_equal(nrow(m3d$it), 3)
  }
})

# ============================================================================
# Error handling tests
# ============================================================================

test_that("mdal_load fails gracefully for missing file", {
  expect_error(mdal_load("nonexistent_file.2dm"))
})

test_that("mesh functions fail gracefully with invalid input",
          {
            expect_error(mdal_mesh_vertex_count(NULL))
            expect_error(mdal_mesh_faces(NULL))
          })
