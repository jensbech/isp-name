#!/bin/bash
set -e

# Build script for creating GitHub releases
VERSION=${1:-"1.0.0"}
BINARY_NAME="ISPOrgMenuBarApp"

echo "Building release $VERSION..."

# Clean and build release
swift build -c release

# Create release directory
mkdir -p "release/$VERSION"

# Copy binary
cp ".build/arm64-apple-macosx/release/$BINARY_NAME" "release/$VERSION/"

# Create tarball
cd release
tar -czf "$BINARY_NAME-$VERSION-arm64-apple-darwin.tar.gz" "$VERSION/$BINARY_NAME"

# Calculate SHA256
SHA256=$(shasum -a 256 "$BINARY_NAME-$VERSION-arm64-apple-darwin.tar.gz" | cut -d' ' -f1)

echo "Release created: release/$BINARY_NAME-$VERSION-arm64-apple-darwin.tar.gz"
echo "SHA256: $SHA256"

# Create a sample Homebrew formula
cat > "../homebrew-formula-template.rb" << EOF
class IspOrgMenuBarApp < Formula
  desc "Simple macOS menu bar app to show ISP organization name"
  homepage "https://github.com/jensbech/isp-name"
  url "https://github.com/jensbech/isp-name/releases/download/v$VERSION/$BINARY_NAME-$VERSION-arm64-apple-darwin.tar.gz"
  sha256 "$SHA256"
  version "$VERSION"

  depends_on :macos => :ventura
  depends_on arch: :arm64

  def install
    bin.install "$BINARY_NAME"
  end

  test do
    # Since this is a GUI app, we can only test that it exists and is executable
    assert_predicate bin/"$BINARY_NAME", :exist?
    assert_predicate bin/"$BINARY_NAME", :executable?
  end
end
EOF

echo "Homebrew formula template created: homebrew-formula-template.rb"
echo ""
echo "Next steps:"
echo "1. Create a GitHub release with tag v$VERSION"
echo "2. Upload the tarball: release/$BINARY_NAME-$VERSION-arm64-apple-darwin.tar.gz"
echo "3. Create a tap repository or submit to homebrew/core"
