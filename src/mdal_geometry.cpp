#include <cpp11.hpp>
#include <mdal.h>

using namespace cpp11;

// Forward declaration of release function from mdal_load.cpp
void mdal_mesh_release(void* mesh);

[[cpp11::register]]
doubles_matrix<> mdal_mesh_vertices_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  int nv = MDAL_M_vertexCount(mesh);

  // Allocate output matrix (N x 3)
  writable::doubles_matrix<> result(nv, 3);

  // Get vertex iterator
  MDAL_MeshVertexIteratorH it = MDAL_M_vertexIterator(mesh);
  if (!it) {
    stop("Failed to create vertex iterator");
  }

  // Read all vertices in one go
  // MDAL returns coords as x1,y1,z1,x2,y2,z2,...
  std::vector<double> coords(nv * 3);
  int read = MDAL_VI_next(it, nv, coords.data());
  MDAL_VI_close(it);

  if (read != nv) {
    stop("Expected %d vertices but read %d", nv, read);
  }

  // Copy to matrix (row-major in R)
  for (int i = 0; i < nv; i++) {
    result(i, 0) = coords[i * 3];      // x
    result(i, 1) = coords[i * 3 + 1];  // y
    result(i, 2) = coords[i * 3 + 2];  // z
  }

  // Set column names
  result.attr("dimnames") = writable::list({
    R_NilValue,
    writable::strings({"x", "y", "z"})
  });

  return result;
}

[[cpp11::register]]
list mdal_mesh_faces_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  int nf = MDAL_M_faceCount(mesh);

  if (nf == 0) {
    return writable::list(static_cast<R_xlen_t>(0));
  }

  int max_verts = MDAL_M_faceVerticesMaximumCount(mesh);

  // Get face iterator
  MDAL_MeshFaceIteratorH it = MDAL_M_faceIterator(mesh);
  if (!it) {
    stop("Failed to create face iterator");
  }

  // Allocate buffers
  // faceOffsets[i] gives the cumulative count of vertices up to face i
  std::vector<int> faceOffsets(nf);
  std::vector<int> vertexIndices(nf * max_verts);  // Upper bound

  // Read all faces
  int faces_read = MDAL_FI_next(it, nf, faceOffsets.data(),
                                nf * max_verts, vertexIndices.data());
  MDAL_FI_close(it);

  if (faces_read != nf) {
    stop("Expected %d faces but read %d", nf, faces_read);
  }

  // Convert to R list
  // faceOffsets is cumulative, so:
  // face 0 vertices: vertexIndices[0 : faceOffsets[0]]
  // face i vertices: vertexIndices[faceOffsets[i-1] : faceOffsets[i]]
  writable::list result(nf);

  int start = 0;
  for (int i = 0; i < nf; i++) {
    int end = faceOffsets[i];
    int face_size = end - start;

    writable::integers face_verts(face_size);
    for (int j = 0; j < face_size; j++) {
      // Convert to 1-based indexing for R
      face_verts[j] = vertexIndices[start + j] + 1;
    }
    result[i] = face_verts;
    start = end;
  }

  return result;
}

[[cpp11::register]]
integers_matrix<> mdal_mesh_edges_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  int ne = MDAL_M_edgeCount(mesh);

  // Allocate output matrix (N x 2)
  writable::integers_matrix<> result(ne, 2);

  if (ne == 0) {
    result.attr("dimnames") = writable::list({
      R_NilValue,
      writable::strings({"start", "end"})
    });
    return result;
  }

  // Get edge iterator
  MDAL_MeshEdgeIteratorH it = MDAL_M_edgeIterator(mesh);
  if (!it) {
    stop("Failed to create edge iterator");
  }

  // Allocate buffers
  std::vector<int> startIndices(ne);
  std::vector<int> endIndices(ne);

  // Read all edges
  int edges_read = MDAL_EI_next(it, ne, startIndices.data(), endIndices.data());
  MDAL_EI_close(it);

  if (edges_read != ne) {
    stop("Expected %d edges but read %d", ne, edges_read);
  }

  // Copy to matrix with 1-based indexing
  for (int i = 0; i < ne; i++) {
    result(i, 0) = startIndices[i] + 1;
    result(i, 1) = endIndices[i] + 1;
  }

  result.attr("dimnames") = writable::list({
    R_NilValue,
    writable::strings({"start", "end"})
  });

  return result;
}
