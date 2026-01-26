# tests/testthat/test-mesh3d.R

test_that("wireframe works for mixed tri+quad", {
  f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm", package = "rmdal")
  mesh <- mdal_load(f)
  m3d <- mdal_as_mesh3d(mesh, type = "wire")


  expect_s3_class(m3d, "mesh3d")
  expect_equal(nrow(m3d$vb), 4)  # homogeneous coords
  expect_equal(ncol(m3d$vb), 5)  # 5 vertices
  expect_true(!is.null(m3d$is)) # has segments
})

test_that("wireframe works for hexagons", {
  f <- system.file("extdata/MDAL/tests/data/2dm/triangleE6T.2dm", package = "rmdal")
  mesh <- mdal_load(f)
  m3d <- mdal_as_mesh3d(mesh, type = "wire")

  expect_s3_class(m3d, "mesh3d")
  # solid should fail for hexagons
  expect_error(mdal_as_mesh3d(mesh, type = "solid"))
})

test_that("1D edges work", {
  f <- system.file("extdata/MDAL/tests/data/2dm/lines.2dm", package = "rmdal")
  mesh <- mdal_load(f)

  expect_equal(mdal_mesh_edge_count(mesh), 3)
  expect_equal(mdal_mesh_face_count(mesh), 0)
})

test_that("TIN format works", {
  f <- system.file("extdata/MDAL/tests/data/esri_tin/mesh_simple/tnz.adf", package = "rmdal")
  mesh <- mdal_load(f)

  expect_equal(mdal_mesh_driver_name(mesh), "ESRI_TIN")
  expect_equal(mdal_mesh_vertex_count(mesh), 8)
})
