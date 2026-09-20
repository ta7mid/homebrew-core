class Sorbet < Formula
  desc "Fast, powerful type checker designed for Ruby"
  homepage "https://sorbet.org"
  url "https://github.com/sorbet/sorbet/archive/refs/tags/0.6.13506.20260917151229-0eac3406f.tar.gz"
  version "0.6.13506"
  sha256 "de0473d2b8f015750bc3d1806fc2ebb3b1dca151f029f0da370c62c964a1d994"
  license "Apache-2.0"
  head "https://github.com/sorbet/sorbet.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)\.\d+-\h+$/i)
  end

  depends_on "bazel@7" => :build
  depends_on "llvm@15" => :build

  def install
    # Build with brew Bazel rather than the wrapper script downloading its own
    rm [".bazelversion", "tools/bazel"]

    # Build with brew LLVM and the active SDK rather than the toolchain download
    inreplace "WORKSPACE" do |s|
      s.gsub! <<~OLD, <<~NEW
        llvm_version = "15.0.7",
      OLD
        llvm_version = "#{Formula["llvm@15"].version}",
        toolchain_roots = {"": "#{formula_opt_prefix("llvm@15")}"},
      NEW
      s.gsub! "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", MacOS.sdk_path if OS.mac?
    end

    # Tarballs have no git metadata, so stamp the version from the tag ourselves
    sha = stable.url[/-(\h+)\.tar\.gz$/, 1]
    (buildpath/"workspace_status").write <<~SH
      #!/bin/bash
      echo "STABLE_BUILD_SCM_REVISION #{sha}"
      echo "STABLE_BUILD_SCM_COMMIT_COUNT #{version.to_s.split(".").last}"
      echo "STABLE_BUILD_SCM_CLEAN 1"
    SH
    chmod 0755, buildpath/"workspace_status"

    # `--config=release-linux` hard-codes `-march=sandybridge` and `-fno-PIC`, so use `release-common` alone
    args = %W[
      --config=#{OS.mac? ? "release-mac" : "release-common"}
      --strip=always
      --curses=no
      --verbose_failures
      --jobs=#{ENV.make_jobs}
      --workspace_status_command=#{buildpath}/workspace_status
    ]
    system "bazel", "--output_user_root=#{buildpath}/user_root", "build", *args, "//main:sorbet"
    bin.install "bazel-bin/main/sorbet"
  end

  test do
    assert_match "Sorbet typechecker #{version}", shell_output("#{bin}/sorbet --version")

    (testpath/"ok.rb").write <<~RUBY
      # typed: true
      T.let(1, Integer)
    RUBY
    system bin/"sorbet", "--silence-dev-message", testpath/"ok.rb"

    (testpath/"bad.rb").write <<~RUBY
      # typed: true
      T.let(1, String)
    RUBY
    assert_match "does not have asserted type `String`",
                 shell_output("#{bin}/sorbet --silence-dev-message #{testpath}/bad.rb 2>&1", 100)
  end
end
