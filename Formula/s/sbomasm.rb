class Sbomasm < Formula
  desc "Comprehensive toolkit for managing Software Bills of Materials (SBOMs)"
  homepage "https://github.com/interlynk-io/sbomasm"
  url "https://github.com/interlynk-io/sbomasm.git",
      tag:      "v2.0.8",
      revision: "b1c2caefc58ada6ff0630623d2721625718e0402"
  license "Apache-2.0"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-s -w")

    generate_completions_from_executable bin/"sbomasm", shell_parameter_format: :cobra
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sbomasm version")
  end
end
