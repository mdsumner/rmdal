#include <cpp11.hpp>
#include <mdal.h>

using namespace cpp11;

// Release function called when R garbage collects
void mdal_mesh_release(void* mesh) {
  if (mesh) MDAL_CloseMesh(static_cast<MDAL_MeshH>(mesh));
}

[[cpp11::register]]
sexp mdal_load_(std::string uri) {
  MDAL_MeshH mesh = MDAL_LoadMesh(uri.c_str());
  if (!mesh) {
    int status = static_cast<int>(MDAL_LastStatus());
    stop("Failed to load mesh '%s' (status: %d)", uri.c_str(), status);
  }
  
  external_pointer<void, mdal_mesh_release> ptr(mesh);
  return as_sexp(ptr);
}

[[cpp11::register]]
int mdal_mesh_vertex_count_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  return MDAL_M_vertexCount(mesh);
}

[[cpp11::register]]
int mdal_mesh_face_count_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  return MDAL_M_faceCount(mesh);
}

[[cpp11::register]]
int mdal_mesh_edge_count_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  return MDAL_M_edgeCount(mesh);
}

[[cpp11::register]]
std::string mdal_mesh_projection_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  const char* proj = MDAL_M_projection(mesh);
  return proj ? std::string(proj) : "";
}

[[cpp11::register]]
std::string mdal_mesh_driver_name_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  const char* name = MDAL_M_driverName(mesh);
  return name ? std::string(name) : "";
}

[[cpp11::register]]
list mdal_mesh_extent_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  
  double minX, maxX, minY, maxY;
  MDAL_M_extent(mesh, &minX, &maxX, &minY, &maxY);
  
  writable::list out({
    "xmin"_nm = minX,
    "xmax"_nm = maxX,
    "ymin"_nm = minY,
    "ymax"_nm = maxY
  });
  
  return out;
}

[[cpp11::register]]
int mdal_mesh_dataset_group_count_(sexp mesh_xptr) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());
  return MDAL_M_datasetGroupCount(mesh);
}
