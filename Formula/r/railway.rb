class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v4.37.1.tar.gz"
  sha256 "6814f4ce3958457c9a99a0211f3df2a352a870f0cb6d68fe58ef915b999c8f4e"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d28a8600b65fecb77e2eab4582fdb5c275ba56a3c9066f6f0783e19eaa0c2f35"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3743d4933640ef2e9f3460b289de6c74af1a3fc40d8c14d417bcd7fd0fd7d750"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "456aa4c28144717fce5def991b5b90f19bf91386426f91ec82f175868d5813d1"
    sha256 cellar: :any_skip_relocation, sonoma:        "def9499c74b0a16dc544248a6af72c0134a2e87f7e41c4618e184851f006a922"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "61c77b4b7dae20bd5d7eed2504f49cbe12b8fa8ad9ad09a5c218edd322f3be90"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1716dcbb4eef243a990c79e9bb9def353fec7868b7306813b0dfcdb02af391f8"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"railway", "completion")
  end

  test do
    output = shell_output("#{bin}/railway init 2>&1", 1).chomp
    assert_match "Unauthorized. Please login with `railway login`", output

    assert_equal "railway #{version}", shell_output("#{bin}/railway --version").strip
  end
end
