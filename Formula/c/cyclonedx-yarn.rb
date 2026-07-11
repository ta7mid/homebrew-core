class CyclonedxYarn < Formula
  desc "Creates CycloneDX Software Bill of Materials (SBOM) from Yarn projects"
  homepage "https://github.com/CycloneDX/cyclonedx-node-yarn"
  url "https://github.com/CycloneDX/cyclonedx-node-yarn.git",
      tag:      "v3.3.2",
      revision: "f6d20918f0525207806652a64a082d6ad86ab693"
  license "Apache-2.0"
  head "https://github.com/CycloneDX/cyclonedx-node-yarn.git", branch: "main"

  depends_on "corepack" => [:build, :test]
  depends_on "node"

  def install
    system "corepack", "yarn", "install", "--immutable"
    system "corepack", "yarn", "run", "build"
    system "corepack", "yarn", "run", "make-dist"

    libexec.install %w[
      dist/bin
      dist/bom.json
      dist/index.js
      dist/package.json
      dist/yarn-plugin-cyclonedx.cjs
      dist/yarn.lock
    ]
    prefix.install Dir["dist/*"]
    bin.install_symlink libexec/"bin/cyclonedx-yarn-cli.js" => "cyclonedx-yarn"
  end

  test do
    (testpath/"package.json").write <<~JSON
      {
        "name": "homebrew-test-package",
        "version": "1.0.0",
        "dependencies": {
          "hello-world-npm": "1.1.1"
        }
      }
    JSON
    ENV["COREPACK_ENABLE_DOWNLOAD_PROMPT"] = "0"
    ENV["YARN_PLUGINS"] = "#{libexec}/yarn-plugin-cyclonedx.cjs"
    system "cyclonedx-yarn"
  end
end
