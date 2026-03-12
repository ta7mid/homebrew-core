class Oxfmt < Formula
  desc "High-performance formatting tool for JavaScript and TypeScript"
  homepage "https://oxc.rs/"
  url "https://registry.npmjs.org/oxfmt/-/oxfmt-0.39.0.tgz"
  sha256 "8ecf77b68300a5b1589aee4c507059b2e081583fadbde7e177706d43ec93e423"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "da4d0230446581c3124007c3c802e46e5f1eaf319037e11471bb930564d5c5c6"
    sha256 cellar: :any,                 arm64_sequoia: "e72d13d78a9931ae44c91033eefde476a5a23918542b7c321e58390930be2c88"
    sha256 cellar: :any,                 arm64_sonoma:  "e72d13d78a9931ae44c91033eefde476a5a23918542b7c321e58390930be2c88"
    sha256 cellar: :any,                 sonoma:        "ed7ad9befe8e57ecb159a5eb0ed7b8de6210cf37fe1bd69e511722f02bed042c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4245469148637ac941ca554288ce05e5a9f980e37ae376721fb56ba356b9928c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "594c34a3d216a482c1c24d827a49ae3197283bcee0e2e00bed578695c6993665"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    (testpath/"test.js").write("const arr = [1,2];")
    system bin/"oxfmt", "test.js"
    assert_equal "const arr = [1, 2];\n", (testpath/"test.js").read
  end
end
