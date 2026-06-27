class Ants < Formula
  desc "Advanced Normalization Tools (ANTs)  "
  homepage "https://stnava.github.io/ANTs/"
  url "https://github.com/ANTsX/ANTs/archive/refs/tags/v2.6.5.tar.gz"
  sha256 "c089cb8deac83cad51605299f38c418fdf2023c2e4d924cf4ccbe1a6f376740f"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "fftw"
  depends_on "itk"
  depends_on "vtk"

  def install
    fftw = Formula["fftw"]
    args = %W[
      -D ANTS_SUPERBUILD=OFF
      -D BUILD_ALL_ANTS_APPS=ON
      -D BUILD_TESTING=OFF
      -D FFTW_DIR=#{fftw.lib/"cmake/fftw#{fftw.version.major}"}
      -D ITK_USE_FFTWD=ON
      -D ITK_USE_FFTWF=ON
      -D ITK_USE_SYSTEM_FFTW=ON
      -D ITK_VERSION_MAJOR=#{Formula["itk"].version.major}
      -D USE_SYSTEM_ITK=ON
      -D USE_SYSTEM_VTK=ON
      -D USE_VTK=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test ANTs`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
