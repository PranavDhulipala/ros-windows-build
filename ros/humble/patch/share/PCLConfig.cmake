# ------------------------------------------------------------------------------------
# Helper to use PCL from outside project
#
# target_link_libraries(my_fabulous_target PCL_XXX_LIBRARIES) where XXX is the
# upper cased xxx from :
# 
# - common
# - kdtree
# - octree
# - search
# - sample_consensus
# - filters
# - 2d
# - geometry
# - io
# - features
# - ml
# - segmentation
# - surface
# - registration
# - keypoints
# - tracking
# - recognition
# - stereo
#
# PCL_INCLUDE_DIRS is filled with PCL and available 3rdparty headers
# PCL_LIBRARY_DIRS is filled with PCL components libraries install directory and
# 3rdparty libraries paths
#
#                                   www.pointclouds.org
#------------------------------------------------------------------------------------

if(POLICY CMP0074)
  # TODO: update *_ROOT variables to be PCL_*_ROOT or equivalent.
  # CMP0074 directly affects how Find* modules work and *_ROOT variables.  Since
  # this is a config file that will be consumed by parent projects with (likely)
  # NEW behavior, we need to push a policy stack.
  cmake_policy(PUSH)
  cmake_policy(SET CMP0074 OLD)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules")

### ---[ some useful macros
macro(pcl_report_not_found _reason)
  unset(PCL_FOUND)
  unset(PCL_LIBRARIES)
  unset(PCL_COMPONENTS)
  unset(PCL_INCLUDE_DIRS)
  unset(PCL_LIBRARY_DIRS)
  unset(PCL_DEFINITIONS)
  if(PCL_FIND_REQUIRED)
    message(FATAL_ERROR ${_reason})
  elseif(NOT PCL_FIND_QUIETLY)
    message(WARNING ${_reason})
  endif()
  if(POLICY CMP0074)
    cmake_policy(POP)
  endif()
  return()
endmacro(pcl_report_not_found)

macro(pcl_message)
  if(NOT PCL_FIND_QUIETLY)
    message(${ARGN})
  endif(NOT PCL_FIND_QUIETLY)
endmacro(pcl_message)

# Remove duplicate libraries
macro(pcl_remove_duplicate_libraries _unfiltered_libraries _filtered_libraries)
  set(${_filtered_libraries})
  set(_debug_libraries)
  set(_optimized_libraries)
  set(_other_libraries)
  set(_waiting_for_debug 0)
  set(_waiting_for_optimized 0)
  set(_library_position -1)
  foreach(library ${${_unfiltered_libraries}})
    if("${library}" STREQUAL "debug")
      set(_waiting_for_debug 1)
    elseif("${library}" STREQUAL "optimized")
      set(_waiting_for_optimized 1)
    elseif(_waiting_for_debug)
      list(FIND _debug_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} debug ${library})
        list(APPEND _debug_libraries ${library})
      endif()
      set(_waiting_for_debug 0)
    elseif(_waiting_for_optimized)
      list(FIND _optimized_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} optimized ${library})
        list(APPEND _optimized_libraries ${library})
      endif()
      set(_waiting_for_optimized 0)
    else("${library}" STREQUAL "debug")
      list(FIND _other_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} ${library})
        list(APPEND _other_libraries ${library})
      endif()
    endif("${library}" STREQUAL "debug")
  endforeach(library)
endmacro(pcl_remove_duplicate_libraries)

### ---[ 3rd party libraries
macro(find_boost)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(BOOST_ROOT "${PCL_ROOT}/3rdParty/Boost")
  elseif(NOT BOOST_INCLUDEDIR)
    set(BOOST_INCLUDEDIR "${_IMPORT_PREFIX}/include")
  endif(PCL_ALL_IN_ONE_INSTALLER)
  # use static Boost in Windows
  if(WIN32)
    set(Boost_USE_STATIC_LIBS OFF)
    set(Boost_USE_STATIC OFF)
    set(Boost_USE_MULTITHREAD ON)
  endif(WIN32)
  if(${CMAKE_VERSION} VERSION_LESS 2.8.5)
    set(Boost_ADDITIONAL_VERSIONS
      "1.47.0" "1.47" "1.46.1"
      "1.46.0" "1.46" "1.45.0" "1.45" "1.44.0" "1.44" "1.43.0" "1.43")
  else(${CMAKE_VERSION} VERSION_LESS 2.8.5)
    set(Boost_ADDITIONAL_VERSIONS
      "1.73.0" "1.73"
      "1.68.0" "1.68" "1.67.0" "1.67" "1.66.0" "1.66" "1.65.1" "1.65.0" "1.65"
      "1.64.0" "1.64" "1.63.0" "1.63" "1.62.0" "1.62" "1.61.0" "1.61" "1.60.0" "1.60"
      "1.59.0" "1.59" "1.58.0" "1.58" "1.57.0" "1.57" "1.56.0" "1.56" "1.55.0" "1.55"
      "1.54.0" "1.54" "1.53.0" "1.53" "1.52.0" "1.52" "1.51.0" "1.51"
      "1.50.0" "1.50" "1.49.0" "1.49" "1.48.0" "1.48" "1.47.0" "1.47")
  endif(${CMAKE_VERSION} VERSION_LESS 2.8.5)
  # Disable the config mode of find_package(Boost)
  set(Boost_NO_BOOST_CMAKE ON)
  find_package(Boost 1.40.0 ${QUIET_} COMPONENTS system filesystem thread date_time iostreams chrono)

  set(BOOST_FOUND ${Boost_FOUND})
  set(BOOST_INCLUDE_DIRS "${Boost_INCLUDE_DIR}")
  set(BOOST_LIBRARY_DIRS "${Boost_LIBRARY_DIRS}")
  set(BOOST_LIBRARIES ${Boost_LIBRARIES})
  if(WIN32 AND NOT MINGW)
    set(BOOST_DEFINITIONS ${BOOST_DEFINITIONS} -DBOOST_ALL_NO_LIB)
  endif(WIN32 AND NOT MINGW)
endmacro(find_boost)

#remove this as soon as eigen is shipped with FindEigen.cmake
macro(find_eigen)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(EIGEN_ROOT "${PCL_ROOT}/3rdParty/Eigen")
  elseif(NOT EIGEN_ROOT)
    get_filename_component(EIGEN_ROOT "${_IMPORT_PREFIX}/include/eigen3" ABSOLUTE)
  endif(PCL_ALL_IN_ONE_INSTALLER)
  find_package(Eigen)
  set(EIGEN_DEFINITIONS ${EIGEN_DEFINITIONS})
endmacro(find_eigen)

#remove this as soon as qhull is shipped with FindQhull.cmake
macro(find_qhull)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(QHULL_ROOT "${PCL_ROOT}/3rdParty/Qhull")
  elseif(NOT QHULL_ROOT)
    get_filename_component(QHULL_ROOT "${_IMPORT_PREFIX}/include" PATH)
  endif(PCL_ALL_IN_ONE_INSTALLER)

  set(QHULL_USE_STATIC )
  find_package(Qhull)
endmacro(find_qhull)

#remove this as soon as libopenni is shipped with FindOpenni.cmake
macro(find_openni)
  if(PCL_FIND_QUIETLY)
    set(OpenNI_FIND_QUIETLY TRUE)
  endif()

  if(NOT OPENNI_ROOT AND ("" STREQUAL "TRUE"))
    set(OPENNI_INCLUDE_DIRS_HINT "")
    get_filename_component(OPENNI_LIBRARY_HINT "OPENNI_LIBRARY-NOTFOUND" PATH)
  endif()

  find_package(OpenNI)
endmacro(find_openni)

#remove this as soon as libopenni2 is shipped with FindOpenni2.cmake
macro(find_openni2)
  if(PCL_FIND_QUIETLY)
	set(OpenNI2_FIND_QUIETLY TRUE)
  endif()

  if(NOT OPENNI2_ROOT AND ("" STREQUAL "TRUE"))
    set(OPENNI2_INCLUDE_DIRS_HINT "")
    get_filename_component(OPENNI2_LIBRARY_HINT "" PATH)
  endif()

  find_package(OpenNI2)
endmacro(find_openni2)

#remove this as soon as the Ensenso SDK is shipped with FindEnsenso.cmake
macro(find_ensenso)
  if(PCL_FIND_QUIETLY)
	set(ensenso_FIND_QUIETLY TRUE)
  endif()

  if(NOT ENSENSO_ROOT AND ("" STREQUAL "TRUE"))
    get_filename_component(ENSENSO_ABI_HINT "ENSENSO_INCLUDE_DIR-NOTFOUND" PATH)
  endif()

  find_package(Ensenso)
endmacro(find_ensenso)

#remove this as soon as the davidSDK is shipped with FinddavidSDK.cmake
macro(find_davidSDK)
  if(PCL_FIND_QUIETLY)
	set(DAVIDSDK_FIND_QUIETLY TRUE)
  endif()

  if(NOT davidSDK_ROOT AND ("" STREQUAL "TRUE"))
    get_filename_component(DAVIDSDK_ABI_HINT DAVIDSDK_INCLUDE_DIR-NOTFOUND PATH)
  endif()

  find_package(davidSDK)
endmacro(find_davidSDK)

macro(find_dssdk)
  if(PCL_FIND_QUIETLY)
	set(DSSDK_FIND_QUIETLY TRUE)
  endif()
  if(NOT DSSDK_DIR AND ("" STREQUAL "TRUE"))
    get_filename_component(DSSDK_DIR_HINT "" PATH)
  endif()

  find_package(DSSDK)
endmacro(find_dssdk)

macro(find_rssdk)
  if(PCL_FIND_QUIETLY)
	set(RSSDK_FIND_QUIETLY TRUE)
  endif()
  if(NOT RSSDK_DIR AND ("" STREQUAL "TRUE"))
    get_filename_component(RSSDK_DIR_HINT "" PATH)
  endif()

  find_package(RSSDK)
endmacro(find_rssdk)

#remove this as soon as flann is shipped with FindFlann.cmake
macro(find_flann)
  set(FLANN_USE_STATIC ON)
  find_package(FLANN)
endmacro(find_flann)

macro(find_VTK)
  if(PCL_ALL_IN_ONE_INSTALLER AND NOT ANDROID)
    if(EXISTS "${PCL_ROOT}/3rdParty/VTK/lib/cmake")
      set(VTK_DIR "${PCL_ROOT}/3rdParty/VTK/lib/cmake/vtk-." CACHE PATH "The directory containing VTKConfig.cmake")
    else()
      set(VTK_DIR "${PCL_ROOT}/3rdParty/VTK/lib/vtk-." CACHE PATH "The directory containing VTKConfig.cmake")
    endif()
  elseif(NOT VTK_DIR AND NOT ANDROID)
    set(VTK_DIR "" CACHE PATH "The directory containing VTKConfig.cmake")
  endif(PCL_ALL_IN_ONE_INSTALLER AND NOT ANDROID)
  if(NOT ANDROID)
    find_package(VTK ${QUIET_})
  endif()
endmacro(find_VTK)

macro(find_libusb)
  if(NOT WIN32)
    find_path(LIBUSB_1_INCLUDE_DIR
      NAMES libusb-1.0/libusb.h
      PATHS /usr/include /usr/local/include /opt/local/include /sw/include
      PATH_SUFFIXES libusb-1.0)

    find_library(LIBUSB_1_LIBRARY
      NAMES usb-1.0
      PATHS /usr/lib /usr/local/lib /opt/local/lib /sw/lib)
    find_package_handle_standard_args(libusb-1.0 LIBUSB_1_LIBRARY LIBUSB_1_INCLUDE_DIR)
  endif(NOT WIN32)
endmacro(find_libusb)

macro(find_glew)
  find_package(GLEW)
endmacro(find_glew)

# Finds each component external libraries if any
# The functioning is as following
# try to find _lib
# |--> _lib found ==> include the headers,
# |                   link to its library directories or include _lib_USE_FILE
# `--> _lib not found
#                   |--> _lib is optional ==> disable it (thanks to the guardians)
#                   |                         and warn
#                   `--> _lib is required
#                                       |--> component is required explicitly ==> error
#                                       `--> component is induced ==> warn and remove it
#                                                                     from the list

macro(find_external_library _component _lib _is_optional)
  if("${_lib}" STREQUAL "boost")
    find_boost()
  elseif("${_lib}" STREQUAL "eigen")
    find_eigen()
  elseif("${_lib}" STREQUAL "flann")
    find_flann()
  elseif("${_lib}" STREQUAL "qhull")
    find_qhull()
  elseif("${_lib}" STREQUAL "openni")
    find_openni()
  elseif("${_lib}" STREQUAL "openni2")
    find_openni2()
  elseif("${_lib}" STREQUAL "ensenso")
    find_ensenso()
  elseif("${_lib}" STREQUAL "davidSDK")
    find_davidSDK()
  elseif("${_lib}" STREQUAL "dssdk")
    find_dssdk()
  elseif("${_lib}" STREQUAL "rssdk")
    find_rssdk()
  elseif("${_lib}" STREQUAL "vtk")
    find_VTK()
  elseif("${_lib}" STREQUAL "libusb-1.0")
    find_libusb()
  elseif("${_lib}" STREQUAL "glew")
    find_glew()
  elseif("${_lib}" STREQUAL "opengl")
    find_package(OpenGL)
  endif("${_lib}" STREQUAL "boost")

  string(TOUPPER "${_component}" COMPONENT)
  string(TOUPPER "${_lib}" LIB)
  string(REGEX REPLACE "[.-]" "_" LIB ${LIB})
  if(${LIB}_FOUND)
    list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS ${${LIB}_INCLUDE_DIRS})
    if(${LIB}_USE_FILE)
      include(${${LIB}_USE_FILE})
    else(${LIB}_USE_FILE)
      list(APPEND PCL_${COMPONENT}_LIBRARY_DIRS "${${LIB}_LIBRARY_DIRS}")
    endif(${LIB}_USE_FILE)
    if(${LIB}_LIBRARIES)
      list(APPEND PCL_${COMPONENT}_LIBRARIES "${${LIB}_LIBRARIES}")
    endif(${LIB}_LIBRARIES)
    if(${LIB}_DEFINITIONS AND NOT ${LIB} STREQUAL "VTK")
      list(APPEND PCL_${COMPONENT}_DEFINITIONS ${${LIB}_DEFINITIONS})
    endif(${LIB}_DEFINITIONS AND NOT ${LIB} STREQUAL "VTK")
  else(${LIB}_FOUND)
    if("${_is_optional}" STREQUAL "OPTIONAL")
      list(APPEND PCL_${COMPONENT}_DEFINITIONS "-DDISABLE_${LIB}")
      pcl_message("** WARNING ** ${_component} features related to ${_lib} will be disabled")
    elseif("${_is_optional}" STREQUAL "REQUIRED")
      if((NOT PCL_FIND_ALL) OR (PCL_FIND_ALL EQUAL 1))
        pcl_report_not_found("${_component} is required but ${_lib} was not found")
      elseif(PCL_FIND_ALL EQUAL 0)
        # raise error and remove _component from PCL_TO_FIND_COMPONENTS
        string(TOUPPER "${_component}" COMPONENT)
        pcl_message("** WARNING ** ${_component} will be disabled cause ${_lib} was not found")
        list(REMOVE_ITEM PCL_TO_FIND_COMPONENTS ${_component})
      endif((NOT PCL_FIND_ALL) OR (PCL_FIND_ALL EQUAL 1))
    endif("${_is_optional}" STREQUAL "OPTIONAL")
  endif(${LIB}_FOUND)
endmacro(find_external_library)

macro(pcl_check_external_dependency _component)
endmacro(pcl_check_external_dependency)

#flatten dependencies recursivity is great \o/
macro(compute_dependencies TO_FIND_COMPONENTS)
  foreach(component ${${TO_FIND_COMPONENTS}})
    set(pcl_component pcl_${component})
    if(${pcl_component}_int_dep AND (NOT PCL_FIND_ALL))
      foreach(dependency ${${pcl_component}_int_dep})
        list(FIND ${TO_FIND_COMPONENTS} ${component} pos)
        list(FIND ${TO_FIND_COMPONENTS} ${dependency} found)
        if(found EQUAL -1)
          set(pcl_dependency pcl_${dependency})
          if(${pcl_dependency}_int_dep)
            list(INSERT ${TO_FIND_COMPONENTS} ${pos} ${dependency})
            if(pcl_${dependency}_ext_dep)
              list(APPEND pcl_${component}_ext_dep ${pcl_${dependency}_ext_dep})
            endif(pcl_${dependency}_ext_dep)
            if(pcl_${dependency}_opt_dep)
              list(APPEND pcl_${component}_opt_dep ${pcl_${dependency}_opt_dep})
            endif(pcl_${dependency}_opt_dep)
            compute_dependencies(${TO_FIND_COMPONENTS})
          else(${pcl_dependency}_int_dep)
            list(INSERT ${TO_FIND_COMPONENTS} 0 ${dependency})
          endif(${pcl_dependency}_int_dep)
        endif(found EQUAL -1)
      endforeach(dependency)
    endif(${pcl_component}_int_dep AND (NOT PCL_FIND_ALL))
  endforeach(component)
endmacro(compute_dependencies)

### ---[ Find PCL

if(PCL_FIND_QUIETLY)
  set(QUIET_ QUIET)
else(PCL_FIND_QUIETLY)
  set(QUIET_)
endif(PCL_FIND_QUIETLY)

find_package(PkgConfig QUIET)

file(TO_CMAKE_PATH "${PCL_DIR}" PCL_DIR)
if(WIN32 AND NOT MINGW)
# PCLConfig.cmake is installed to PCL_ROOT/cmake
  get_filename_component(PCL_ROOT "${PCL_DIR}" PATH)
  get_filename_component(PCL_ROOT "${PCL_ROOT}" PATH)
else(WIN32 AND NOT MINGW)
# PCLConfig.cmake is installed to PCL_ROOT/share/pcl-x.y
  get_filename_component(PCL_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
endif(WIN32 AND NOT MINGW)

# check whether PCLConfig.cmake is found into a PCL installation or in a build tree
if(EXISTS "${PCL_ROOT}/include/pcl/pcl_config.h")
  # Found a PCL installation
  # pcl_message("Found a PCL installation")
  set(PCL_INCLUDE_DIRS "${PCL_ROOT}/include")
  set(PCL_LIBRARY_DIRS "${PCL_ROOT}/Lib" "${PCL_ROOT}/debug/lib")
  if(EXISTS "${PCL_ROOT}/3rdParty")
    set(PCL_ALL_IN_ONE_INSTALLER ON)
  endif(EXISTS "${PCL_ROOT}/3rdParty")
elseif(EXISTS "${PCL_DIR}/include/pcl/pcl_config.h")
  # Found PCLConfig.cmake in a build tree of PCL
  # pcl_message("PCL found into a build tree.")
  set(PCL_INCLUDE_DIRS "${PCL_DIR}/include") # for pcl_config.h
  set(PCL_LIBRARY_DIRS "${PCL_DIR}/lib")
  set(PCL_SOURCES_TREE "D:/bld/pcl/src/pcl-1.9.1-f2ec88a858.clean")
else(EXISTS "${PCL_ROOT}/include/pcl/pcl_config.h")
  pcl_report_not_found("PCL can not be found on this machine")
endif(EXISTS "${PCL_ROOT}/include/pcl/pcl_config.h")

#set a suffix for debug libraries
set(PCL_DEBUG_SUFFIX "_debug")
set(PCL_RELEASE_SUFFIX "_release")

#set SSE flags used compiling PCL
list(APPEND PCL_DEFINITIONS )
list(APPEND PCL_COMPILE_OPTIONS )

set(pcl_all_components  common kdtree octree search sample_consensus filters 2d geometry io features ml segmentation surface registration keypoints tracking recognition stereo )
list(LENGTH pcl_all_components PCL_NB_COMPONENTS)

#list each component dependencies IN PCL
set(pcl_kdtree_int_dep common )
set(pcl_octree_int_dep common )
set(pcl_search_int_dep common kdtree octree )
set(pcl_sample_consensus_int_dep common search )
set(pcl_filters_int_dep common sample_consensus search kdtree octree )
set(pcl_2d_int_dep common filters )
set(pcl_geometry_int_dep common )
set(pcl_io_int_dep common octree )
set(pcl_features_int_dep common search kdtree octree filters 2d )
set(pcl_ml_int_dep common )
set(pcl_segmentation_int_dep common geometry search sample_consensus kdtree octree features filters ml )
set(pcl_surface_int_dep common search kdtree octree )
set(pcl_registration_int_dep common octree kdtree search sample_consensus features filters )
set(pcl_keypoints_int_dep common search kdtree octree features filters )
set(pcl_tracking_int_dep common search kdtree filters octree )
set(pcl_recognition_int_dep common io search kdtree octree features filters registration sample_consensus ml )
set(pcl_stereo_int_dep common io )


#list each component external dependencies (ext means mandatory and opt means optional)
set(pcl_common_ext_dep eigen boost )
set(pcl_kdtree_ext_dep flann )
set(pcl_search_ext_dep flann )


set(pcl_2d_opt_dep )
set(pcl_io_opt_dep png )
set(pcl_surface_opt_dep qhull )


set(pcl_header_only_components 2d cuda_common geometry gpu_tracking modeler in_hand_scanner point_cloud_editor cloud_composer optronic_viewer)

include(FindPackageHandleStandardArgs)

#check if user provided a list of components
#if no components at all or full list is given set PCL_FIND_ALL
if(PCL_FIND_COMPONENTS)
  list(LENGTH PCL_FIND_COMPONENTS PCL_FIND_COMPONENTS_LENGTH)
  if(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
    set(PCL_TO_FIND_COMPONENTS ${pcl_all_components})
    set(PCL_FIND_ALL 1)
  else(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
    set(PCL_TO_FIND_COMPONENTS ${PCL_FIND_COMPONENTS})
  endif(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
else(PCL_FIND_COMPONENTS)
  set(PCL_TO_FIND_COMPONENTS ${pcl_all_components})
  set(PCL_FIND_ALL 1)
endif(PCL_FIND_COMPONENTS)

compute_dependencies(PCL_TO_FIND_COMPONENTS)

# We do not need to find components that have been found already, e.g. during previous invocation
# of find_package(PCL). Filter them out.
foreach(component ${PCL_TO_FIND_COMPONENTS})
  string(TOUPPER "${component}" COMPONENT)
  if(NOT PCL_${COMPONENT}_FOUND)
    list(APPEND _PCL_TO_FIND_COMPONENTS ${component})
  endif()
endforeach()
set(PCL_TO_FIND_COMPONENTS ${_PCL_TO_FIND_COMPONENTS})
unset(_PCL_TO_FIND_COMPONENTS)

if(NOT PCL_TO_FIND_COMPONENTS)
  if(POLICY CMP0074)
    cmake_policy(POP)
  endif()
  return()
endif()

# compute external dependencies per component
foreach(component ${PCL_TO_FIND_COMPONENTS})
    foreach(opt ${pcl_${component}_opt_dep})
      find_external_library(${component} ${opt} OPTIONAL)
    endforeach(opt)
    foreach(ext ${pcl_${component}_ext_dep})
      find_external_library(${component} ${ext} REQUIRED)
    endforeach(ext)
endforeach(component)

foreach(component ${PCL_TO_FIND_COMPONENTS})
  set(pcl_component pcl_${component})
  string(TOUPPER "${component}" COMPONENT)

  pcl_message(STATUS "looking for PCL_${COMPONENT}")

  string(REGEX REPLACE "^cuda_(.*)$" "\\1" cuda_component "${component}")
  string(REGEX REPLACE "^gpu_(.*)$" "\\1" gpu_component "${component}")

  find_path(PCL_${COMPONENT}_INCLUDE_DIR
    NAMES pcl/${component}
          pcl/apps/${component}
          pcl/cuda/${cuda_component} pcl/cuda/${component}
          pcl/gpu/${gpu_component} pcl/gpu/${component}
    HINTS ${PCL_INCLUDE_DIRS}
          "${PCL_SOURCES_TREE}"
    PATH_SUFFIXES
          ${component}/include
          apps/${component}/include
          cuda/${cuda_component}/include
          gpu/${gpu_component}/include
    DOC "path to ${component} headers"
    NO_DEFAULT_PATH)
  mark_as_advanced(PCL_${COMPONENT}_INCLUDE_DIR)

  if(PCL_${COMPONENT}_INCLUDE_DIR)
    list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS "${PCL_${COMPONENT}_INCLUDE_DIR}")
  else(PCL_${COMPONENT}_INCLUDE_DIR)
    #pcl_message("No include directory found for pcl_${component}.")
  endif(PCL_${COMPONENT}_INCLUDE_DIR)

  # Skip find_library for header only modules
  list(FIND pcl_header_only_components ${component} _is_header_only)
  if(_is_header_only EQUAL -1)
    find_library(PCL_${COMPONENT}_LIBRARY ${pcl_component}
      HINTS ${PCL_LIBRARY_DIRS}
      DOC "path to ${pcl_component} library"
      NO_DEFAULT_PATH)
    get_filename_component(${component}_library_path
      ${PCL_${COMPONENT}_LIBRARY}
      PATH)
    mark_as_advanced(PCL_${COMPONENT}_LIBRARY)

    find_library(PCL_${COMPONENT}_LIBRARY_DEBUG ${pcl_component}${PCL_DEBUG_SUFFIX}
      HINTS ${PCL_LIBRARY_DIRS}
      DOC "path to ${pcl_component} library debug"
      NO_DEFAULT_PATH)
    mark_as_advanced(PCL_${COMPONENT}_LIBRARY_DEBUG)

    if(PCL_${COMPONENT}_LIBRARY_DEBUG)
      get_filename_component(${component}_library_path_debug
        ${PCL_${COMPONENT}_LIBRARY_DEBUG}
        PATH)
    endif(PCL_${COMPONENT}_LIBRARY_DEBUG)

    # Restrict this to Windows users
    if(NOT PCL_${COMPONENT}_LIBRARY AND WIN32)
      # might be debug only
      set(PCL_${COMPONENT}_LIBRARY ${PCL_${COMPONENT}_LIBRARY_DEBUG})
    endif(NOT PCL_${COMPONENT}_LIBRARY AND WIN32)

    find_package_handle_standard_args(PCL_${COMPONENT} DEFAULT_MSG
      PCL_${COMPONENT}_LIBRARY PCL_${COMPONENT}_INCLUDE_DIR)
  else(_is_header_only EQUAL -1)
    find_package_handle_standard_args(PCL_${COMPONENT} DEFAULT_MSG
      PCL_${COMPONENT}_INCLUDE_DIR)
  endif(_is_header_only EQUAL -1)

  if(PCL_${COMPONENT}_FOUND)
    if(NOT "${PCL_${COMPONENT}_INCLUDE_DIRS}" STREQUAL "")
      set(_filtered "")
      foreach(_inc ${PCL_${COMPONENT}_INCLUDE_DIRS})
        if(EXISTS ${_inc})
          list(APPEND _filtered "${_inc}")
        endif()
      endforeach()
      list(REMOVE_DUPLICATES _filtered)
      set(PCL_${COMPONENT}_INCLUDE_DIRS ${_filtered})
      list(APPEND PCL_INCLUDE_DIRS ${_filtered})
    endif(NOT "${PCL_${COMPONENT}_INCLUDE_DIRS}" STREQUAL "")
    mark_as_advanced(PCL_${COMPONENT}_INCLUDE_DIRS)
    if(_is_header_only EQUAL -1)
      list(APPEND PCL_DEFINITIONS ${PCL_${COMPONENT}_DEFINITIONS})
      list(APPEND PCL_LIBRARY_DIRS ${component_library_path})
      if(PCL_${COMPONENT}_LIBRARY_DEBUG)
        list(APPEND PCL_LIBRARY_DIRS ${component_library_path_debug})
      endif()
      list(APPEND PCL_COMPONENTS ${pcl_component})
      mark_as_advanced(PCL_${COMPONENT}_LIBRARY PCL_${COMPONENT}_LIBRARY_DEBUG)
    endif()
    # Append internal dependencies
    foreach(int_dep ${pcl_${component}_int_dep})
      string(TOUPPER "${int_dep}" INT_DEP)
      if(PCL_${INT_DEP}_FOUND)
        list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS ${PCL_${INT_DEP}_INCLUDE_DIRS})
        if(PCL_${INT_DEP}_LIBRARIES)
          list(APPEND PCL_${COMPONENT}_LINK_LIBRARIES "${PCL_${INT_DEP}_LIBRARIES}")
        endif(PCL_${INT_DEP}_LIBRARIES)
      endif(PCL_${INT_DEP}_FOUND)
    endforeach(int_dep)
    if(_is_header_only EQUAL -1)
      add_library(${pcl_component} SHARED IMPORTED)
      if(PCL_${COMPONENT}_LIBRARY_DEBUG)
        set_target_properties(${pcl_component}
          PROPERTIES
            IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
            IMPORTED_LOCATION_RELEASE "${PCL_${COMPONENT}_LIBRARY}"
            IMPORTED_LOCATION_DEBUG "${PCL_${COMPONENT}_LIBRARY_DEBUG}"
            IMPORTED_IMPLIB_RELEASE "${PCL_${COMPONENT}_LIBRARY}"
            IMPORTED_IMPLIB_DEBUG "${PCL_${COMPONENT}_LIBRARY_DEBUG}"
        )
      else()
        set_target_properties(${pcl_component}
          PROPERTIES
            IMPORTED_LOCATION "${PCL_${COMPONENT}_LIBRARY}"
            IMPORTED_IMPLIB "${PCL_${COMPONENT}_LIBRARY}"
        )
      endif()
      foreach(def ${PCL_DEFINITIONS})
        string(REPLACE " " ";" def2 ${def})
        string(REGEX REPLACE "^-D" "" def3 "${def2}")
        list(APPEND definitions ${def3})
      endforeach()
      if(CMAKE_VERSION VERSION_LESS 3.3)
        set_target_properties(${pcl_component}
          PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "${definitions}"
            INTERFACE_COMPILE_OPTIONS "${PCL_COMPILE_OPTIONS}"
            INTERFACE_INCLUDE_DIRECTORIES "${PCL_${COMPONENT}_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${PCL_${COMPONENT}_LINK_LIBRARIES}"
        )
      elseif(CMAKE_VERSION VERSION_LESS 3.11)
        set_target_properties(${pcl_component}
          PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "${definitions}"
            INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:CXX>:${PCL_COMPILE_OPTIONS}>"
            INTERFACE_INCLUDE_DIRECTORIES "${PCL_${COMPONENT}_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${PCL_${COMPONENT}_LINK_LIBRARIES}"
        )
      else()
        set_target_properties(${pcl_component}
          PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "${definitions}"
            INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:CXX>:${PCL_COMPILE_OPTIONS}>"
            INTERFACE_INCLUDE_DIRECTORIES "${PCL_${COMPONENT}_INCLUDE_DIRS}"
        )
        # If possible, we use target_link_libraries to avoid problems with link-type keywords,
        # see https://github.com/PointCloudLibrary/pcl/issues/2989
        # target_link_libraries on imported libraries is supported only since CMake 3.11
        target_link_libraries(${pcl_component} INTERFACE ${PCL_${COMPONENT}_LINK_LIBRARIES})
      endif()
      set(PCL_${COMPONENT}_LIBRARIES ${pcl_component})
    endif()
  endif(PCL_${COMPONENT}_FOUND)
endforeach(component)

if(NOT "${PCL_INCLUDE_DIRS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_INCLUDE_DIRS)
endif(NOT "${PCL_INCLUDE_DIRS}" STREQUAL "")

if(NOT "${PCL_LIBRARY_DIRS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_LIBRARY_DIRS)
endif(NOT "${PCL_LIBRARY_DIRS}" STREQUAL "")

if(NOT "${PCL_DEFINITIONS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_DEFINITIONS)
endif(NOT "${PCL_DEFINITIONS}" STREQUAL "")

pcl_remove_duplicate_libraries(PCL_COMPONENTS PCL_LIBRARIES)

# Add 3rd party libraries, as user code might include our .HPP implementations
list(APPEND PCL_LIBRARIES ${BOOST_LIBRARIES} ${QHULL_LIBRARIES} ${OPENNI_LIBRARIES} ${OPENNI2_LIBRARIES} ${ENSENSO_LIBRARIES} ${davidSDK_LIBRARIES} ${DSSDK_LIBRARIES} ${RSSDK_LIBRARIES} ${VTK_LIBRARIES})
if(TARGET flann::flann_cpp)
  list(APPEND PCL_LIBRARIES flann::flann_cpp)
endif()

find_package_handle_standard_args(PCL DEFAULT_MSG PCL_LIBRARIES PCL_INCLUDE_DIRS)
mark_as_advanced(PCL_LIBRARIES PCL_INCLUDE_DIRS PCL_LIBRARY_DIRS)

if(POLICY CMP0074)
  cmake_policy(POP)
endif()
