class Kwctl < Formula
  desc "CLI tool for the Kubewarden policy engine for Kubernetes"
  homepage "https://www.kubewarden.io/"
  url "https://github.com/kubewarden/kubewarden-controller/archive/refs/tags/v1.34.1.tar.gz"
  sha256 "f101fbe115a8c543543d5225d3659548206d20b61c4ae1954ed67a828ca8b7be"
  license "Apache-2.0"
  head "https://github.com/kubewarden/kubewarden-controller.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7c02191f7c7e36347987f5e7920313226d1b3ee11d619eed3555fb9cd52d4e2c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5b427ce488a4e28ae66213e49a620d245c5a37196c0626bc667189b8827ba102"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "5ba8c0b32ff1fc390745f68d0fa0b67b97b6281549c08087266b5017867162a4"
    sha256 cellar: :any_skip_relocation, sonoma:        "7fd866d2dc92f71be304a8fccc6bf290ce13ccff529c90281f5f6f665026ac72"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f063fcd6fcf61c5a22e1b5ad62659d2c06ddb7eac2f80785bfb6823f28b163c6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5a15f256403335c9aa6c2859db2f1f4f482c72c93a15069b9b8c80dff386c986"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/kwctl")

    generate_completions_from_executable(bin/"kwctl", "completions", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kwctl --version")

    test_policy = "ghcr.io/kubewarden/policies/safe-labels:v0.1.7"
    system bin/"kwctl", "pull", test_policy
    assert_match test_policy, shell_output("#{bin}/kwctl policies")

    (testpath/"ingress.json").write <<~JSON
      {
        "uid": "1299d386-525b-4032-98ae-1949f69f9cfc",
        "kind": {
          "group": "networking.k8s.io",
          "kind": "Ingress",
          "version": "v1"
        },
        "resource": {
          "group": "networking.k8s.io",
          "version": "v1",
          "resource": "ingresses"
        },
        "name": "foobar",
        "operation": "CREATE",
        "userInfo": {
          "username": "kubernetes-admin",
          "groups": [
            "system:masters",
            "system:authenticated"
          ]
        },
        "object": {
          "apiVersion": "networking.k8s.io/v1",
          "kind": "Ingress",
          "metadata": {
            "name": "tls-example-ingress",
            "labels": {
              "owner": "team"
            }
          },
          "spec": {
          }
        }
      }
    JSON
    (testpath/"policy-settings.json").write <<~JSON
      {
        "denied_labels": [
          "owner"
        ]
      }
    JSON

    output = shell_output(
      "#{bin}/kwctl run " \
      "registry://#{test_policy} " \
      "--request-path #{testpath}/ingress.json " \
      "--settings-path #{testpath}/policy-settings.json",
    )
    assert_match "The following labels are denied: owner", output
  end
end
