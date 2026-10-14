class Quickconvert < Formula
  desc "Convert files from Finder's right-click menu: images, video, audio, documents"
  homepage "https://github.com/jgreen417/QuickConvert"
  url "https://github.com/jgreen417/QuickConvert/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "008d1184c1c6738de554e5190c294279ada294d12fb99cf87170248c95f50510"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "imagemagick"
  depends_on "librsvg"
  depends_on macos: :ventura
  depends_on "poppler"

  def install
    # Built on this Mac, so an ad-hoc signature is all macOS needs (no notarization involved).
    ENV["IDENTITY"] = "-"
    ENV["ARCHS"] = Hardware::CPU.arm? ? "arm64" : "x86_64"
    system "./build.sh", "--no-install"
    prefix.install "build/QuickConvert.app"
    inreplace "bin/quickconvert", "@APP@", "#{opt_prefix}/QuickConvert.app"
    bin.install "bin/quickconvert"
  end

  def caveats
    <<~EOS
      To finish installing, run:
        quickconvert setup
      It copies QuickConvert to ~/Applications, enables the Finder extension,
      and relaunches Finder. Run it again after `brew upgrade quickconvert`.

      For Word, Excel, PowerPoint, Keynote and Numbers files (and anything → PDF):
        brew install --cask libreoffice

      To remove everything:
        quickconvert uninstall && brew uninstall quickconvert
    EOS
  end

  test do
    assert_match "quickconvert setup", shell_output("#{bin}/quickconvert --help")
    app = prefix/"QuickConvert.app"
    system "codesign", "--verify", "--deep", "--strict", app
    assert_match "app-sandbox",
      shell_output("codesign -d --entitlements - #{app}/Contents/PlugIns/QuickConvertFinder.appex 2>&1")
  end
end
