class VercelCli < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-50.32.3.tgz"
  sha256 "91ab40b9a25b08956b502a93455163de2dc2e0165f5239ab728c8ed3ccfd5e2e"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "114aba7d51cfa1217d232a34ea74c2945ad0588921c08c690f3a10863f5512df"
    sha256 cellar: :any,                 arm64_sequoia: "6a478cde9174d673b7fa9a212bee1b2078d8c1cee48a1774b3b02430755a7319"
    sha256 cellar: :any,                 arm64_sonoma:  "6a478cde9174d673b7fa9a212bee1b2078d8c1cee48a1774b3b02430755a7319"
    sha256 cellar: :any,                 sonoma:        "11adcf6999e39e9902feb04c97cd2c69201f49bfdcff27c88e26ed0589447735"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9c741c0640c5f83c498f0fad0503c4a40d13f1d7b25bc7b7a8e14cdcbc9a2f28"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ad571508674ce3d96fda58f352dcf81bba9460b6365c69fe08c3360476983b4"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "await getUpdateCommand()",
                               '"brew upgrade vercel-cli"'

    system "npm", "install", *std_npm_args
    deuniversalize_machos libexec/"lib/node_modules/vercel/node_modules/fsevents/fsevents.node" if OS.mac?
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"vercel", "init", "jekyll"
    assert_path_exists testpath/"jekyll/_config.yml", "_config.yml must exist"
    assert_path_exists testpath/"jekyll/README.md", "README.md must exist"
  end
end
