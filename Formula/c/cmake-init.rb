class CmakeInit < Formula
  include Language::Python::Virtualenv

  desc "Opinionated CMake project initializer"
  homepage "https://github.com/friendlyanon/cmake-init"
  url "https://github.com/friendlyanon/cmake-init/archive/refs/tags/v0.41.1.tar.gz"
  sha256 "fa6ab1e39c2f20ccd5dc5e254d66059b9123a92c5af984bebc9950cec6715fad"
  license "GPL-3.0-or-later"
  head "https://github.com/friendlyanon/cmake-init.git", branch: "master"

  depends_on "python-setuptools" => :build
  depends_on "python@3.14"

  deny_network_access!

  def install
    buildpath.install "package/setup.py"
    inreplace "setup.py", "../", ""

    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install_and_link buildpath, build_isolation: false
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cmake-init --version")

    system bin/"cmake-init", "--std=20", "-p=conan", "test-project"

    some_expected_files = %w[CMakeLists.txt conanfile.py source/main.cpp docs/ test/]
    some_expected_files.each { |f| assert_path_exists "test-project/#{f}" }
  end
end
