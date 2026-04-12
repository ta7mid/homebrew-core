class Ocicl < Formula
  desc "OCI-based ASDF system distribution and management tool for Common Lisp"
  homepage "https://github.com/ocicl/ocicl"
  url "https://github.com/ocicl/ocicl/archive/refs/tags/v2.16.8.tar.gz"
  sha256 "9ba4b0f7e0faecad4cae9c34f79d9dbd72cfe248f27011f5167fc1225858b723"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0fdc2a9cd33ac2d8a8e51a72ebd879359ad2e29091f12001da72cae38154a03b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b4197f77bbb5f489b60055207cacb8e4ee8e9e2a8faa3c61bde81125e29a3b37"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a343df7ba6c9c44937a778e3bbcad68af7225dc90ae05d87bf11cab6de499240"
    sha256 cellar: :any_skip_relocation, sonoma:        "0928ace8992144539eda67b9e2ff9894c80dd7241136e87b1e2fc983c3807c9c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c296f1f20869fdfb81ceb0dcfb90af9a4cfe0e0c74273fa322a4ca27499335c1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8b669848124848fc39c3ae013516244c497ce9f7a8e40f9b7ab96cc3aedc36ab"
  end

  depends_on "sbcl"
  depends_on "zstd"

  def install
    mkdir_p [libexec, bin]

    # ocicl's setup.lisp generates an executable that is the binding
    # of the sbcl executable to the ocicl image core.  Unfortunately,
    # on Linux, homebrew somehow manipulates the resulting ELF file in
    # such a way that the sbcl part of the binary can't find the image
    # cores.  For this reason, we are generating our own image core as
    # a separate file and loading it at runtime.
    system "sbcl", "--dynamic-space-size", "3072", "--no-userinit",
           "--eval", "(load \"runtime/asdf.lisp\")", "--eval", <<~LISP
             (progn
               (asdf:initialize-source-registry
                 (list :source-registry
                       :inherit-configuration (list :tree (uiop:getcwd))))
               (asdf:load-system :ocicl)
               (asdf:clear-source-registry)
               (sb-ext:save-lisp-and-die "#{libexec}/ocicl.core"))
           LISP

    # Write a shell script to wrap ocicl
    (bin/"ocicl").write <<~LISP
      #!/usr/bin/env -S sbcl --core #{libexec}/ocicl.core --script
      (uiop:restore-image)
      (ocicl:main)
    LISP
  end

  test do
    system bin/"ocicl", "install", "chat"
    assert_path_exists testpath/"ocicl.csv"

    version_files = testpath.glob("ocicl/cl-chat*/_00_OCICL_VERSION")
    assert_equal 1, version_files.length, "Expected exactly one _00_OCICL_VERSION file"

    (testpath/"init.lisp").write shell_output("#{bin}/ocicl setup")
    system "sbcl", "--non-interactive", "--load", "init.lisp",
           "--eval", "(progn (asdf:load-system :chat) (sb-ext:quit))"
  end
end
