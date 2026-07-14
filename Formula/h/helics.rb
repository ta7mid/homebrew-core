class Helics < Formula
  desc "Hierarchical Engine for Large-scale Infrastructure Co-Simulation"
  homepage "https://helics.org/"
  url "https://github.com/GMLC-TDC/HELICS/releases/download/v3.6.1/Helics-v3.6.1-source.tar.gz"
  sha256 "d607c1b47dd5ae32f3076c4aa4aa584d37b6056a9bd049234494698ed95cd70f"
  license "BSD-3-Clause"

  depends_on "boost" => :no_linkage
  depends_on "cmake" => :build
  depends_on "fmt"
  depends_on "spdlog"
  depends_on "zeromq"

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DHELICS_BUILD_CXX_SHARED_LIB=ON
      -DHELICS_BUILD_APP_LIBRARY=ON
      -DHELICS_ENABLE_SUBMODULE_UPDATE=OFF
      -DHELICS_DISABLE_GIT_OPERATIONS=ON
      -DHELICS_DISABLE_VCPKG=ON
      -DHELICS_USE_POSITION_INDEPENDENT_CODE=ON
      -DHELICS_USE_EXTERNAL_FMT=ON
      -DHELICS_USE_EXTERNAL_SPDLOG=ON
      -DHELICS_USE_SYSTEM_ZEROMQ_ONLY=ON
      -DBoost_ROOT=#{Formula["boost"].prefix}
      -Dfmt_ROOT=#{Formula["fmt"].prefix}
      -Dspdlog_ROOT=#{Formula["spdlog"].prefix}
      -DZeroMQ_INSTALL_PATH=#{Formula["zeromq"].prefix}
    ]
    system "cmake", "-S", ".", "-B", "build-shared", *args, *std_cmake_args
    system "cmake", "--build", "build-shared"
    system "cmake", "--install", "build-shared"

    args = args[3...] + %W[
      -DBUILD_SHARED_LIBS=OFF
      -DHELICS_BUILD_CXX_SHARED_LIB=OFF
      -DHELICS_DISABLE_C_SHARED_LIB=ON
      -DCMAKE_INSTALL_PREFIX=#{libexec}
    ]
    system "cmake", "-S", ".", "-B", "build-static", *args, *std_cmake_args
    system "cmake", "--build", "build-static"
    system "cmake", "--install", "build-static"
  end
end
