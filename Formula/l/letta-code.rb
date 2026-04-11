class LettaCode < Formula
  desc "Memory-first coding agent"
  homepage "https://docs.letta.com/letta-code"
  url "https://registry.npmjs.org/@letta-ai/letta-code/-/letta-code-0.22.1.tgz"
  sha256 "8bc1fa41d3080d967312d2fb32388d860519b7887c6c5f681bd0ebb490d78122"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "6400e9297fdfb38b786f508a7fd321638522047a73c7c14ea8548cfb70aadb74"
    sha256 cellar: :any,                 arm64_sequoia: "3e2fbe8c262e5c95d059f72176979cc3a420b15f68e15a7c80cec52a5912b839"
    sha256 cellar: :any,                 arm64_sonoma:  "3e2fbe8c262e5c95d059f72176979cc3a420b15f68e15a7c80cec52a5912b839"
    sha256 cellar: :any,                 sonoma:        "60c59f32feb9b1b8e05fa6498d33a0e56d5d0f7e2ef28d5a76e22a857e170fc7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4c6a381c14263430708392f0f94e05784e3fc4daa8a592e2d84f1a1356e2015b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7b65f72634eba9ac639d6d06aeb2e31f8e80dff89569b432ae00399b9fc32ad8"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/@letta-ai/letta-code/node_modules"
    (node_modules/"node-pty/prebuilds").glob("*").each do |dir|
      rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/letta --version")

    output = shell_output("#{bin}/letta --info")
    assert_match "Locally pinned agents: (none)", output
  end
end
