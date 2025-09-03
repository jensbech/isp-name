class IspOrgMenuBarApp < Formula
  desc "Simple macOS menu bar app to show ISP organization name"
  homepage "https://github.com/jensbech/isp-name"
  url "https://github.com/jensbech/isp-name/releases/download/v1.0.0/ISPOrgMenuBarApp-1.0.0-arm64-apple-darwin.tar.gz"
  sha256 "e1eefcacd8c22f51ebabd795b17e5c28b92eddd76d20de0c2fe57b9f89f6b3fe"
  version "1.0.0"

  depends_on :macos => :ventura
  depends_on arch: :arm64

  def install
    bin.install "ISPOrgMenuBarApp"
  end

  test do
    # Since this is a GUI app, we can only test that it exists and is executable
    assert_predicate bin/"ISPOrgMenuBarApp", :exist?
    assert_predicate bin/"ISPOrgMenuBarApp", :executable?
  end
end
