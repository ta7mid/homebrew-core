class Tectonic < Formula
  desc "Modernized, complete, self-contained TeX/LaTeX engine"
  homepage "https://tectonic-typesetting.github.io/"
  url "https://github.com/tectonic-typesetting/tectonic/archive/refs/tags/tectonic@0.16.0.tar.gz"
  sha256 "b4eda21afa1ccc6a0d32cc3cd970acbedf9fe95bd13c8e5fc44bd6aac1cfe84d"
  license "MIT"
  head "https://github.com/tectonic-typesetting/tectonic.git", branch: "master"

  # As of writing, only the tags starting with `tectonic@` are release versions.
  # NOTE: The `GithubLatest` strategy cannot be used here because the "latest"
  # release on GitHub sometimes points to a tag that isn't a release version.
  livecheck do
    url :stable
    regex(/^tectonic@v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "7fbfd97cfb3e84a0959f32472c684487e328825659eaf476c54a596acf682f07"
    sha256 cellar: :any,                 arm64_sequoia: "1a05713fee4e4c8218d93fb54600382d47504487934192da2648c9c7517da891"
    sha256 cellar: :any,                 arm64_sonoma:  "20270b77e9d90ad4f5b549731a04ba7bada496dd1d4959e8ea5a50ff91f84189"
    sha256 cellar: :any,                 sonoma:        "3a4ee303aedb41e5f06d9098ab1f1a7912050aa39b01212200e65a5cdad2b5e6"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "25ad71dd8158bba5607f071680dadca10c42f660203d0afafe31bfdedc1b19e6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6ea5920f52be18fafc043942d910708426ee5d09587d4d9a83b3d3c9a1b380e1"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "freetype"
  depends_on "graphite2"
  depends_on "harfbuzz"
  depends_on "icu4c@78"
  depends_on "libpng"
  depends_on "openssl@3"

  on_linux do
    depends_on "fontconfig"
    depends_on "zlib-ng-compat"
  end

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version.to_s if OS.mac? # needed for CLT-only builds

    # Ensure that the `openssl` crate picks up the intended library.
    # https://crates.io/crates/openssl#manual-configuration
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix

    system "cargo", "install", *std_cargo_args(features: "external-harfbuzz")
    bin.install_symlink bin/"tectonic" => "nextonic"
  end

  test do
    (testpath/"test.tex").write 'Hello, World!\bye'
    system bin/"tectonic", "-o", testpath, "--format", "plain", testpath/"test.tex"
    assert_path_exists testpath/"test.pdf", "Failed to create test.pdf"
    assert_match "PDF document", shell_output("file test.pdf")

    system bin/"nextonic", "new", "."
    system bin/"nextonic", "build"
    assert_path_exists testpath/"build/default/default.pdf", "Failed to create default.pdf"
  end
end
