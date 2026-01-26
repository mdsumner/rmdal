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


// ============================================================================
// Dataset Group functions
// ============================================================================

[[cpp11::register]]
std::string mdal_dataset_group_name_(sexp mesh_xptr, int index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, index);
  if (!dg) return "";

  const char* name = MDAL_G_name(dg);
  return name ? std::string(name) : "";
}

[[cpp11::register]]
int mdal_dataset_group_dataset_count_(sexp mesh_xptr, int group_index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, group_index);
  if (!dg) return 0;

  return MDAL_G_datasetCount(dg);
}

[[cpp11::register]]
std::string mdal_dataset_group_location_(sexp mesh_xptr, int group_index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, group_index);
  if (!dg) return "";

  MDAL_DataLocation loc = MDAL_G_dataLocation(dg);
  switch (loc) {
  case MDAL_DataLocation::DataOnVertices: return "vertices";
  case MDAL_DataLocation::DataOnFaces: return "faces";
  case MDAL_DataLocation::DataOnVolumes: return "volumes";
  case MDAL_DataLocation::DataOnEdges: return "edges";
  default: return "unknown";
  }
}



[[cpp11::register]]
doubles mdal_dataset_values_(sexp mesh_xptr, int group_index, int dataset_index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, group_index);
  if (!dg) stop("Invalid dataset group index");

  MDAL_DatasetH ds = MDAL_G_dataset(dg, dataset_index);
  if (!ds) stop("Invalid dataset index");

  int count = MDAL_D_valueCount(ds);
  writable::doubles out(count);

  // MDAL_D_data fills the buffer with values
  // For scalar data: one value per vertex/face
  // For vector data: would need x,y components (handle separately)
  MDAL_D_data(ds, 0, count, MDAL_DataType::SCALAR_DOUBLE, REAL(out));

  return out;
}

[[cpp11::register]]
double mdal_dataset_time_(sexp mesh_xptr, int group_index, int dataset_index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, group_index);
  if (!dg) return NA_REAL;

  MDAL_DatasetH ds = MDAL_G_dataset(dg, dataset_index);
  if (!ds) return NA_REAL;

  return MDAL_D_time(ds);
}


[[cpp11::register]]
bool mdal_dataset_group_is_scalar_(sexp mesh_xptr, int group_index) {
  auto ptr = as_cpp<external_pointer<void, mdal_mesh_release>>(mesh_xptr);
  MDAL_MeshH mesh = static_cast<MDAL_MeshH>(ptr.get());

  MDAL_DatasetGroupH dg = MDAL_M_datasetGroup(mesh, group_index);
  if (!dg) return true;

  return MDAL_G_hasScalarData(dg);
}
