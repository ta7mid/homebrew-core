class LlnlUnits < Formula
  desc "C++ library for dimensional analysis and unit/quantity manipulation and conversion"
  homepage "https://units.readthedocs.io/en/latest/"
  url "https://github.com/llnl/units/archive/refs/tags/v0.13.1.tar.gz"
  sha256 "e6a19f84a139ec6a06458d68778cc4e491a6e07428c8ac57faadcd3d6f81d50e"
  license "BSD-3-Clause"

  depends_on "cmake" => :build

  def install
    args = %w[
      -DUNITS_ENABLE_TESTS=OFF
      -DUNITS_HEADER_ONLY=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.10)
      project(FormulaTest CXX)
      find_package(units REQUIRED)
      add_executable(test test.c++)
      target_link_libraries(test PRIVATE units::header_only)
    CMAKE
    (testpath/"test.c++").write <<~CXX
      #include <cassert>
      #include <units/units.hpp>
      int main()
      {
        constexpr auto speed_unit = units::m / units::s;
        assert(speed_unit * units::s == units::m);
        using namespace units;
        constexpr auto length = 45.25*m;
        constexpr auto breadth = 20*m;
        constexpr auto area = length * breadth;
        assert(area == 905*m*m);
      }
    CXX
    system "cmake", "-S", ".", "-B", "build"
    system "cmake", "--build", "build"
  end
end
